import os
import re
import json
import pymysql
import datetime
import requests
from dotenv import load_dotenv
from rasa_sdk.events import SlotSet, ActionExecuted
from rasa_sdk import Action, Tracker
from typing import Any, Text, Dict, List
from rasa_sdk.executor import CollectingDispatcher

load_dotenv()
SERVER = str(os.getenv('SERVER'))
IS_LOCAL = int(os.getenv('IS_LOCAL'))

if IS_LOCAL != 1:
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = "balerion_mysql.json"
    os.environ['INSTANCE_CONNECTION_NAME'] = "balerionchatbot:us-central1:balerion"
    
def database_add_message(user, text): 
    if IS_LOCAL != 1:
        conn = pymysql.connect(
            host=str(os.getenv('DB_host')),
            port=int(os.getenv('DB_port')),
            user=str(os.getenv('DB_user')),
            password=str(os.getenv('DB_password')),
            db=str(os.getenv('DB_database')),
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
            charset='utf8mb4',
            unix_socket='/cloudsql/{}'.format(os.environ['INSTANCE_CONNECTION_NAME']))
    else:
        try:
            conn = pymysql.connect(
                host=str(os.getenv('DB_host')),
                port=int(os.getenv('DB_port')),
                user=str(os.getenv('DB_user')),
                password=str(os.getenv('DB_password')),
                db=str(os.getenv('DB_database')),
                charset='utf8mb4',
                cursorclass=pymysql.cursors.DictCursor)
        except pymysql.err.OperationalError as e:
            database_name = str(os.getenv('DB_database'))
            print(f"Database doesn't exist: {database_name}")
            conn = pymysql.connect(
                host=str(os.getenv('DB_host')),
                port=int(os.getenv('DB_port')),
                user=str(os.getenv('DB_user')),
                password=str(os.getenv('DB_password')),
                charset='utf8mb4',
                cursorclass=pymysql.cursors.DictCursor)
            
            with conn.cursor() as cursor:
                cursor.execute(f"CREATE DATABASE {database_name}")
            
            print(f"Database created: {database_name}")
            conn.commit()
            conn = pymysql.connect(
                host=str(os.getenv('DB_host')),
                port=int(os.getenv('DB_port')),
                user=str(os.getenv('DB_user')),
                password=str(os.getenv('DB_password')),
                db=database_name,
                charset='utf8mb4',
                cursorclass=pymysql.cursors.DictCursor)
    with conn.cursor() as cursor:
        try:
            cursor.execute("""
                SELECT id FROM users WHERE username = %s
            """, (user,))
        except pymysql.err.ProgrammingError as e:
            cursor.execute("""
                CREATE TABLE users (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    username VARCHAR(255) UNIQUE
                )
            """)
            cursor.execute("""
                CREATE TABLE messages (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    timestamp DATETIME,
                    message VARCHAR(255),
                    user_id INT,
                    FOREIGN KEY (user_id) REFERENCES users(id)
                )
            """)
            conn.commit()
            cursor.execute("""
                SELECT id FROM users WHERE username = %s
            """, (user,))
        result = cursor.fetchone()
        if result is not None and len(result) > 0:
            user_id = result["id"]
        else:
            cursor.execute("INSERT INTO users (username) VALUES (%s)", (user,))
            user_id = cursor.lastrowid
        now = datetime.datetime.now()
        now = now.strftime('%Y-%m-%d %H:%M:%S')
        cursor.execute("INSERT INTO messages (user_id, timestamp, message) VALUES (%s, %s, %s)", (user_id, now, text))   
        conn.commit()

    conn.close()                 
def request(url):
    payload={}
    headers = {}
    r = requests.request("GET", url, headers=headers, data=payload)
    if r.status_code != 200:
        return "[Error]["+str(r.status_code)+"] - "  + str(r.json())
    return json.dumps(r.json())

class CustomActionListen(Action):
    def name(self) -> Text:
        return "action_listen"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        database_add_message(tracker.sender_id, (tracker.latest_message)['text'])
        return [ActionExecuted("action_listen")]
class ActionExtractCharacter(Action):
    def name(self) -> Text:
        return "action_extract_character"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:       
        message = tracker.latest_message['text']
        pattern = r'(?<=is\s)(.*?)(?=\?)'
        match = re.search(pattern, message)
        if match:
            character = match.group()
            SlotSet("character", character)
        else:
            dispatcher.utter_message("Sorry, I couldn't find a character name in your message.")
            return []
        characterData = request(SERVER+"/characters?name="+character.replace(" ","%20"))
        dispatcher.utter_message(f"Here is what I know about {character}")
        dispatcher.utter_message(characterData)

class ActionExtractHouse(Action):
    def name(self) -> Text:
        return "action_extract_house"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        message = tracker.latest_message['text']
        pattern = r'(?<=about\s)(.*?)(?=\?)'
        match = re.search(pattern, message)
        if match:
            house = match.group()
            SlotSet("house", house)
        else:
            dispatcher.utter_message("Sorry, I couldn't find a house name in your message.")
            return []
        houseData = request(SERVER+"/houses?name="+house.replace(" ","%20"))
        dispatcher.utter_message(f"Here is what I know about {house}")
        dispatcher.utter_message(houseData)
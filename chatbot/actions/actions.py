import os
import json
import pymysql
import datetime
import requests
from dotenv import load_dotenv
from rasa_sdk.events import SlotSet
from rasa_sdk import Action, Tracker
from typing import Any, Text, Dict, List
from rasa_sdk.executor import CollectingDispatcher

load_dotenv()
SERVER = str(os.getenv('SERVER'))
def database_add_message(user, text): 
    database_name = str(os.getenv('DB_database'))
    conn = None
    databaseExists = True
    try:
        conn = pymysql.connect(
            host=str(os.getenv('DB_host')),
            port=int(os.getenv('DB_port')),
            user=str(os.getenv('DB_user')),
            password=str(os.getenv('DB_password')),
            db=database_name,
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor)
    except pymysql.err.OperationalError as e:
        print(f"Database doesn't exist: {database_name}")
        databaseExists = False
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
        if databaseExists == False:
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
        else:
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

class ActionExtractCharacter(Action):
    def name(self) -> Text:
        return "action_extract_character"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:       
        character = tracker.latest_message['entities'][0]['value']
        SlotSet("character", character)
        characterData = request(SERVER+"/characters?name="+character.replace(" ","%20"))
        database_add_message(tracker.sender_id, (tracker.latest_message)['text'])
        dispatcher.utter_message(f"Here is what I know about {character}")
        dispatcher.utter_message(characterData)
class ActionExtractHouse(Action):
    def name(self) -> Text:
        return "action_extract_house"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        house = tracker.latest_message['entities'][0]['value']
        SlotSet("house", house)
        houseData = request(SERVER+"/houses?name=House%20"+house.replace(" ","%20"))
        database_add_message(tracker.sender_id, (tracker.latest_message)['text'])
        dispatcher.utter_message(f"Here is what I know about House {house}")
        dispatcher.utter_message(houseData)
import os
import json
import requests
from dotenv import load_dotenv
from rasa_sdk.events import SlotSet
from rasa_sdk import Action, Tracker
from typing import Any, Text, Dict, List
from rasa_sdk.executor import CollectingDispatcher
import mysql.connector as mysql

load_dotenv()
SERVER = str(os.getenv('SERVER'))
mycursor = None
def database_init(): 
    global mycursor
    mydb = mysql.connect(
        host=str(os.getenv('DB_host')),
        user=str(os.getenv('DB_user')),
        password=str(os.getenv('DB_password')),
        database=str(os.getenv('DB_name'))
    )
    # Create a cursor
    mycursor = mydb.cursor()
    mycursor.execute("SHOW TABLES LIKE 'messages'")
    result = mycursor.fetchone()
    if result == False:
        mycursor.execute("""
            CREATE TABLE messages (
                username VARCHAR(255) PRIMARY KEY,
                timestamp DATE,
                message VARCHAR(255)
            )
        """)
    return mycursor    
                 
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
        global mycursor 
        if mycursor == None:
            mycursor = database_init()
        character = tracker.latest_message['entities'][0]['value']
        SlotSet("character", character)
        characterData = request(SERVER+"/characters?name="+character.replace(" ","%20"))
        dispatcher.utter_message(f"Here is what I know about {character}")
        dispatcher.utter_message(characterData)
class ActionExtractHouse(Action):
    def name(self) -> Text:
        return "action_extract_house"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        global mycursor 
        if mycursor == None:
            mycursor = database_init()
        house = tracker.latest_message['entities'][0]['value']
        SlotSet("house", house)
        houseData = request(SERVER+"/houses?name=House%20"+house.replace(" ","%20"))
        dispatcher.utter_message(f"Here is what I know about House {house}")
        dispatcher.utter_message(houseData)
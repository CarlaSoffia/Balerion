import os
import requests
from dotenv import load_dotenv
from rasa_sdk.events import SlotSet
from rasa_sdk import Action, Tracker
from typing import Any, Text, Dict, List
from rasa_sdk.executor import CollectingDispatcher

load_dotenv()
SERVER = str(os.getenv('SERVER'))

def request(url):
    payload={}
    headers = {}
    r = requests.request("GET", url, headers=headers, data=payload)
    if r.status_code != 200:
        return "[Error]["+str(r.status_code)+"] - "  + str(r.json())
    return str(r.json())

class ActionExtractCharacter(Action):
    def name(self) -> Text:
        return "action_extract_character"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
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
        house = tracker.latest_message['entities'][0]['value']
        SlotSet("house", house)
        houseData = request(SERVER+"/houses?name=House%20"+house.replace(" ","%20"))
        dispatcher.utter_message(f"Here is what I know about House {house}")
        dispatcher.utter_message(houseData)
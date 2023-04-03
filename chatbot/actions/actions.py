# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions


# This is a simple example for a custom action which utters "Hello World!"

from typing import Any, Text, Dict, List

from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet

class ActionExtractCharacter(Action):
    def name(self) -> Text:
        return "action_extract_character"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        character = tracker.latest_message['entities'][0]['value']
        SlotSet("character", character.replace(" ","%20"))
        dispatcher.utter_message(f"Here is what I know about {character}")
    
class ActionExtractHouse(Action):
    def name(self) -> Text:
        return "action_extract_house"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        house = tracker.latest_message['entities'][0]['value']
        SlotSet("house", house.replace(" ","%20"))
        dispatcher.utter_message(f"Here is what I know about House {house}")
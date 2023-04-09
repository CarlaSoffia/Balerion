#!/bin/bash
rasa run actions &
rasa run -m models --enable-api --cors "*"
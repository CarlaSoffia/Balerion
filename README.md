# Balerion - ASOIAF Chatbot 🐲

A chatbot to provide informations about Characters and Houses from the ASOIAF universe

## Table of Contents

- [Project Goals](#project-goals)
- [Technologies Used](#technologies-used)
- [Local scenario](#localScenario)
- [Cloud scenario](#cloudScenario)
- [Usage](#usage)

## Project Goals

- Development of a chatbot to handle dialogue with the user.
- Development of a frontend webpage to interact with the user.
- Development of a database to store user messages over time.
- Development of an HTTP server to retrieve and process data from an already existing external API (https://www.anapioficeandfire.com/api/) to provide data regarding the ASOIAF universe.
- Provisioning and deployment of all the mentioned services using Docker and Terraform, locally and in the cloud.

## Technologies Used

- Vue.js
- Node.js
- MySQL
- Rasa

The following diagram details the existing services and the communication between them.
<img src="diagrams\Components.png" alt="Chatbot components" width="100%"/>

## Local scenario

<img src="diagrams\Local.png" alt="Chatbot local scenario" width="100%"/>

Getting started:
1. Clone the repository and open the project in a terminal
2. To build the images run: `docker-compose build`
3. To create and start the containers based on the images: `docker-compose up -d`

Cleaning up:
1. Clone the repository and open the project in a terminal
2. Stops and remove containers: `docker-compose down --rmi all`

## Cloud scenario

<img src="diagrams\Cloud.png" alt="Chatbot cloud scenario" width="100%"/>

Raise the infrastructure:
1. Clone the repository and open the project in a terminal
2. Generate execution plan for the infrastructure: `terraform plan` and say 'yes'
3. Create or update the infrastructure: `terraform apply` and say 'yes'

Tear down the infrastructure:
1. Clone the repository and open the project in a terminal
2. Generate execution plan for the infrastructure: `terraform plan` and say 'yes'
3. Create or update the infrastructure: `terraform destroy` and say 'yes'

## Usage

- Open the url: http://localhost:8080/ (locally) or https://frontend-prtrjtsklq-uc.a.run.app/ (cloud)
- Write your name in the popup
- Type: "Hello" in the chat section to see how to interact with Balerion chatbot
- Type: "Who is Rhaenyra Targaryen?" in the chat section
- Observe the character information in the left panel
- Type: "Can you tell me about House Stark of Winterfell?" in the chat section
- Observe the House information in the left panel


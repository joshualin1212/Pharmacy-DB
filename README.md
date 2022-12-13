# CS3200 Project - Pharmacy System by Josh and Dylan

**CLICK [HERE]() FOR VIDEO**
This repo contains the following:

1. A MySQL 8 container for obvious reasons
1. A Python Flask container
1. Bootstrap DDL/DML
1. REST API functions

## How to setup and start the containers

**Important** - you need Docker Desktop installed

1. Clone this repository.  
1. Create a file named `db_root_password.txt` in the `secrets/` folder and put inside of it the root password for MySQL. 
1. Create a file named `db_password.txt` in the `secrets/` folder and put inside of it the password you want to use for the `webapp` user.
1. In a terminal or command prompt, navigate to the folder with the `docker-compose.yml` file.  
1. Build the images with `docker compose build`
1. Start the containers with `docker compose up`.  To run in detached mode, run `docker compose up -d`. 

## File architecture

API code is located within `/flask-app/src`.

- `patient`: contains dashboard `GET` and profile `GET, POST` functions for patients
- `ph_employee`: contains dashboard `GET` functions for pharmacy staff
- `prescriber`: contains dashboard `GET` functions for prescribers

## Default ports

- 8001 for web service (use with ngrok for webapp)
- 3320 for MySQL container (use with DataGrip for debugging)

# CS3200 Project - Pharmacy System by Team Josh and Dylan

- lin.jos@northeastern.edu
- li.dy@northeastern.edu

**CLICK [HERE](https://youtu.be/mojHYHFu-Mg) FOR VIDEO**
Note: the video makes use of plenty of cuts due to `ngrok` restarts.

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
1. Start the containers with `docker compose up`. To run in detached mode, run `docker compose up -d`.

## File architecture

API code is located within `/flask-app/src`.
Note: not all routes are implemented in the AppSmith UI.

- `patient`: contains dashboard `GET` and profile `GET, POST` functions for patients
  - `orders.py`: 3 `GET`, 1 `POST`
  - `patients.py`: 7 `GET`, 2 `POST`
- `ph_employee`: contains dashboard `GET` functions for pharmacy staff
  - `electronicrx.py`: 1 `GET`, 1 `POST`
  - `ph_employee.py`: 3 `GET`
  - `ph_orders.py`: 2 `GET`
- `prescriber`: contains dashboard `GET` functions for prescribers
  - `prescribers.py`: 4 `GET`, 1 `POST`

## Default ports

- 8001 for web service (use with ngrok for webapp)
- 3320 for MySQL container (use with DataGrip for debugging)
- 3200 when connecting to DataGrip

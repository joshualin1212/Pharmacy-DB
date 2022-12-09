from flask import Blueprint, request, jsonify, make_response
import json
from src import db


patients = Blueprint('patients', __name__)

# Get all patients from the DB
@patients.route('/patients', methods=['GET'])
def get_patients():
    cursor = db.get_db().cursor()
    cursor.execute('select patientNumber, patientName,\
        creditLimit from patients')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get patient detail for patient with particular userID
@patients.route('/patients/<userID>', methods=['GET'])
def get_patient(userID):
    cursor = db.get_db().cursor()
    cursor.execute('select * from patients where patientNumber = {0}'.format(userID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response
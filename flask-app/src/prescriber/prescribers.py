from flask import Blueprint, request, jsonify, make_response
import json
from src import db


prescribers = Blueprint('prescribers', __name__)


# Prescriber POSTS a new prescription.
@prescribers.route('/prescribers/<userID>', methods=['POST'])
def add_prescription(userID, patientID):
    current_app.logger.info(request.form)
    cursor = db.get_db().cursor()
    medication = request.form['medication']
    quantity = request.form['quantity']
    directions = request.form['directions']
    query = f'INSERT INTO ElectronicRx(pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (Select pharmacyID from Pharmacy where \"{userID}\" == prescriberID , prescriberID, \"{patientID}\", \"{medication}\", GETDATE(), \"{quantity}\", \"{directions}\")'
    cursor.execute(query)
    db.get_db().commit()
    return "SUCCESS."

# Get all prescribers from the DB
@prescribers.route('/prescribers', methods=['GET'])
def get_prescribers():
    cursor = db.get_db().cursor()
    cursor.execute('select * from prescriber')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get prescriber detail for prescriber with particular userID
@prescribers.route('/prescribers/<userID>', methods=['GET'])
def get_prescriber(userID):
    cursor = db.get_db().cursor()
    cursor.execute('select * from Prescriber where prescriberID = {0}'.format(userID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

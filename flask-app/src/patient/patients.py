from flask import Blueprint, request, jsonify, make_response
import json
from src import db


patients = Blueprint('patients', __name__)

# Get all patients from the DB
@patients.route('/patients', methods=['GET'])
def get_patients():
    cursor = db.get_db().cursor()
    cursor.execute('select * from Patient')
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
    cursor.execute('select * from Patient where patientID = {0}'.format(userID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get patient pharmacy location detail for patient with particular userID
@patients.route('/patients/<userID>/pharmacy', methods=['GET'])
def get_patient_pharmacy(userID):
    cursor = db.get_db().cursor()

    query = f'''
        SELECT ph.*
        FROM Pharmacy ph JOIN Patient pa ON ph.pharmacyID = pa.pharmacyID
        WHERE pa.patientID = {userID}
    '''

    cursor.execute(query)
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get patient prescriber detail for patient with particular userID
@patients.route('/patients/<userID>/prescriber', methods=['GET'])
def get_patient_prescriber(userID):
    cursor = db.get_db().cursor()

    query = f'''
        SELECT pr.firstName, pr.lastName, pr.email, pr.phone,
            h.name, h.street, h.city, h.state
        FROM Prescriber pr JOIN Patient pa ON pr.prescriberID = pa.prescriberID
            JOIN Hospital h ON pr.HID = h.HID
        WHERE pa.patientID = {userID}
    '''

    cursor.execute(query)
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get patient insurance detail for patient with particular userID
@patients.route('/patients/<userID>/insurance', methods=['GET'])
def get_patient_insurance(userID):
    cursor = db.get_db().cursor()

    query = f'''
        SELECT i.*
        FROM Insurance i JOIN Patient pa ON i.InsuranceID = pa.InsuranceID
        WHERE pa.patientID = {userID}
    '''

    cursor.execute(query)
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response


# UPDATE patient detail for patient with particular userID
@patients.route('/patients/<userID>/editinfo', methods=['PATCH'])
def edit_patient(userID):
    current_app.logger.info(request.form)
    cursor = db.get_db().cursor()

    firstName = request.form['firstName']
    lastName = request.form['lastName']
    street = request.form['street']
    city = request.form['city']
    state = request.form['state']

    query = f'''
        UPDATE Patient
        SET
            firstName = {firstName},
            lastName = {lastName},
            street = {street},
            city = {city},
            state = {state}
        WHERE {userID} = patientID
    '''

    cursor.execute(query)
    db.get_db().commit()
    return "SUCCESS."


# # TODO: # UPDATE pharmacy for the patient particular userID
# @patients.route('/patients/<userID>', methods=['PATCH'])
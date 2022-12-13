from flask import Blueprint, request, jsonify, make_response
import json
from src import db


ph_employee = Blueprint('ph_employee', __name__)

# GET all the pharmacy employees from the database
@ph_employee.route('/ph_employee', methods=['GET'])
def get_ph_employees():
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of pharmacy employees
    query = '''
        SELECT phEmployeeID, pharmacyID, certification,
            firstName, lastName from PharmacyEmployee
    '''
    cursor.execute(query)

    # grab the column headers from the returned data
    column_headers = [x[0] for x in cursor.description]

    # create an empty dictionary object to use in 
    # putting column headers together with data
    json_data = []

    # fetch all the data from the cursor
    theData = cursor.fetchall()

    # for each of the rows, zip the data elements together with
    # the column headers. 
    for row in theData:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)

# GET pharmacy employee detail for employee with particular userID
@ph_employee.route('/ph_employee/<userID>', methods=['GET'])
def get_ph_employee(userID):
    cursor = db.get_db().cursor()
    query = f'''
        SELECT *
        FROM PharmacyEmployee
        WHERE PharmacyEmployee.phEmployeeID = {userID}
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

# Get employee pharmacy location detail for patient with particular userID
@ph_employee.route('/ph_employee/<userID>/pharmacy', methods=['GET'])
def get_ph_employee_pharmacy(userID):
    cursor = db.get_db().cursor()
    query = f'''SELECT * from Pharmacy LEFT OUTER JOIN PharmacyEmployee ON Pharmacy.pharmacyID = PharmacyEmployee.pharmacyID where PharmacyEmployee.phEmployeeID = {userID}
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


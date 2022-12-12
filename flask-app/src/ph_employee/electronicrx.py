from flask import Blueprint, request, jsonify, make_response
import json
from src import db


ph_erx = Blueprint('ph_erx', __name__)

# GET electronic rx with matching pharmID from DB
@ph_erx.route('/pharmacy/<pharmID>/electronicrx', methods=['GET'])
def get_ph_order(pharmID):
    cursor = db.get_db().cursor()
    query = f'''
        SELECT *
        FROM ElectronicRx
        WHERE pharmacyID = {pharmID}
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

@ph_erx.route('/pharmacy/<pharmID>/electronicrx/new', methods=['POST'])
def add_prescription(pharmID):
    current_app.logger.info(request.form)
    cursor = db.get_db().cursor()

    paID = request.form['patientID']

    query = f'''
        INSERT INTO PaOrder (
            patientID,
            insuranceID,
            pharmacyID,
            orderDate,
            orderStatus
        )
        VALUES (
            \'{paID}\',
            SELECT insuranceID from Insurance i NATURAL JOIN Patient p WHERE \'{paID}\' == p.patientID,
            \'{pharmID}\',
            GETDATE(),
            \'in progress\'
        )
    '''
    cursor.execute(query)
    db.get_db().commit()
    return "SUCCESS."
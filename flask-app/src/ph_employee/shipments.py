from flask import Blueprint, request, jsonify, make_response
import json
from src import db


ph_shipments = Blueprint('ph_shipments', __name__)

# GET all pending shipments to pharmacy with particular pharmID from the DB
@ph_shipments.route('/shipments/<pharmID>', methods=['GET'])
def get_ph_shipments(pharmID):
    cursor = db.get_db().cursor()

    query = f'''
        SELECT *
        FROM Shipment
        WHERE shipmentPharmacy = {pharmID}
    '''
    cursor.execute(query)

    column_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)

# TODO:
# POST new stock shipment to pharmacy with particular pharmID
@ph_shipments.route('/shipments/<pharmID>/new', methods=['POST'])
def add_ph_shipment(pharmID):
    current_app.logger.info(request.form)
    cursor = db.get_db().cursor()

    total_query = f'''
        SELECT SUM ()
        FROM
    '''
    total = None

    query = f'''
        INSERT INTO Shipment (
            pharmacyID,
            shipDate,
            shipStatus,
            shipTotal
        )
        VALUES (
            '{pharmID}',
            GETDATE(),
            'pending',
            '{total}
        )
    '''
    cursor.execute(query)

    db.get_db().commit()
    return "SUCCESS."

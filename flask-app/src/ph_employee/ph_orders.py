from flask import Blueprint, request, jsonify, make_response
import json
from src import db


ph_orders = Blueprint('ph_orders', __name__)

# GET all orders from pharmacy with particular pharmID from the DB
@ph_orders.route('/pharmacy/<phEmployeeID>/orders', methods=['GET'])
def get_ph_orders(phEmployeeID):
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of pharmacy employees
    query = f'''
        SELECT *
        FROM Pharmacy p
        join 
        PaOrder po on po.pharmacyID = p.pharmacyID
        join PharmacyEmployee pe 
        on p.pharmacyID = pe.pharmacyID
        where phEmployeeID = {phEmployeeID}
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

# GET order detail with pharmID and orderID from the DB
@ph_orders.route('/pharmacy/<pharmID>/<orderID>', methods=['GET'])
def get_ph_order(pharmID, orderID):
    cursor = db.get_db().cursor()
    query = f'''
        SELECT *
        FROM PaOrder
        WHERE pharmacyID = {pharmID} AND orderID = {orderID}
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

# TODO:
# UPDATE order status (ready, canceled, etc)
@ph_orders.route('', methods=['POST'])
def update_ph_employee(userID):
    pass

# TODO:
# UPDATE order item details (quantity, RxID)
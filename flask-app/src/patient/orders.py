from flask import Blueprint, request, jsonify, make_response
import json
from src import db


pa_orders = Blueprint('pa_orders', __name__)

# GET orders from the DB for patient with particular userID
@pa_orders.route('/patients/<userID>/orders', methods=['GET'])
def get_pa_orders(userID):
    cursor = db.get_db().cursor()
    query = f'''
        SELECT *
        FROM `Order`
        WHERE patientID = {userID}
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

# GET ready orders from the DB for patient with particular userID
@pa_orders.route('/patients/<userID>/orders/ready', methods=['GET'])
def get_pa_orders_ready(userID):
    cursor = db.get_db().cursor()
    query = f'''
        SELECT *
        FROM `Order`
        WHERE patientID = {userID} AND orderStatus = 'ready'
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

# GET order from the DB for patient with particular userID, orderID
@pa_orders.route('/patients/<userID>/orders/<orderID>')
def get_pa_order(userID, orderID):
    cursor = db.get_db().cursor()
    query = f'''
        SELECT *
        FROM `Order` o JOIN OrderItem oi ON o.orderID = oi.orderID
        WHERE patientID = {userID} AND o.orderID = {orderID}
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

# UPDATE order status to 'canceled' for particular userID, orderID
@pa_orders.route('/patients/<userID>/orders/<orderID>/cancel', methods=['PUT'])
def cancel_pa_orders(userID, orderID):
    cursor = db.get_db().cursor()
    query = f'''
        UPDATE `Order`
        SET orderStatus = 'canceled'
        WHERE patientID = {userID} AND orderID = {orderID}
    '''
    cursor.execute(query)
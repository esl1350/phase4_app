from flask import Flask, render_template, request, redirect, url_for, session
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re

app = Flask(__name__)
mysql = MySQL(app)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'cs4400#CS4400%'
app.config['MYSQL_DB'] = 'restaurant_supply_express'

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/addOwner', methods = ['GET', 'POST'])
def addOwner():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        username = request.form['username']
        fname = request.form['fname']
        lname = request.form['lname']
        address = request.form['address']
        birthdate = request.form['birthdate']
        if len(username) <= 40 and len(fname) <= 100 and len(lname) <= 100 and len(address) <= 500 and len(birthdate) == 10:
            cursor.execute('call add_owner(% s, % s, % s, % s, % s)', (username, fname, lname, address, birthdate))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('addOwner.html', alert = alert)
@app.route('/addDrone', methods = ['GET' , 'POST'])
def addDrone():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        drone_id = request.form['id']
        drone_tag = request.form['tag']
        fuel = request.form['fuel']
        capacity = request.form['capacity']
        sales = request.form['sales']
        pilot = request.form['pilot']
        if len(drone_id) <= 40 and len(pilot) <= 40 and int(capacity) >= 0 and int(sales) >= 0 and int(fuel) >= 0:
            cursor.execute('call add_drone(% s, % s, % s, % s, % s, %s)', (drone_id, drone_tag, fuel, capacity, sales, pilot))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('addDrone.html', alert = alert)
@app.route('/addIngredient', methods = ['GET', 'POST'])
def addIngredient():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        barcode = request.form['barcode']
        name = request.form['name']
        weight = request.form['weight']
        if len(barcode) <= 40 and len(name) <= 100 and int(weight) >= 0:
            cursor.execute('call add_ingredient(% s, % s, % s)', (barcode, name, weight))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('addIngredient.html', alert = alert)
@app.route('/addRestaurant', methods = ['GET', 'POST'])
def addRestaurant():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        name = request.form['name']
        rating = request.form['rating']
        spent = request.form['spent']
        location = request.form['location']
        if len(name) <= 40 and len(location) <= 40 and int(rating) >= 1 and int(rating) < 6 and int(spent) >= 0:
            cursor.execute('call add_restaurant(% s, % s, % s, %s)', (name, rating, spent, location))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('addRestaurant.html', alert = alert)

@app.route('/removeIngredient', methods = ['GET', 'POST'])
def removeIngredient():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        barcode = (request.form['barcode'])
        if len(barcode) <= 40:
            cursor.execute('call remove_ingredient(% s)', (barcode, ))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('removeIngredient.html', alert = alert)

@app.route('/removeDrone', methods = ['GET', 'POST'])
def removeDrone():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        tag = (request.form['tag'])
        drone_id = request.form['id']
        if len(drone_id) <= 40:
            cursor.execute('call remove_drone(% s, % s)', (drone_id, tag))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('removeDrone.html', alert = alert)


@app.route('/loadDrone', methods = ['GET', 'POST'])
def loadDrone():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        tag = (request.form['tag'])
        drone_id = request.form['id']
        barcode = request.form['barcode']
        quantity = request.form['quantity']
        price = request.form['price']
        if len(drone_id) <= 40:
            cursor.execute('call load_drone(% s, % s, %s, %s, %s)', (drone_id, tag, barcode, quantity, price))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('loadDrone.html', alert = alert)

@app.route('/refuelDrone', methods = ['GET', 'POST'])
def refuelDrone():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        tag = (request.form['tag'])
        drone_id = request.form['id']
        fuel = request.form['fuel']
        if len(drone_id) <= 40:
            cursor.execute('call refuel_drone(% s, % s, %s)', (drone_id, tag, fuel))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('refuelDrone.html', alert = alert)



@app.route('/display')
def display():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('SELECT * FROM display_owner_view;')
    ownerRows = cursor.fetchall()
    cursor.execute('SELECT * FROM display_employee_view;')
    employeeRows = cursor.fetchall()
    return render_template('display.html', ownerRows = ownerRows, employeeRows = employeeRows)
    
@app.route('/flyDrone', methods = ['GET', 'POST'])
def flyDrone():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        ip_id = request.form['ip_id']
        ip_tag = request.form['ip_tag']
        ip_destination = request.form['ip_destination']
        if len(ip_id) <= 40 and len(ip_destination) <= 10:
            cursor.execute('call fly_drone(% s, % s, % s)', (ip_id, ip_tag, ip_destination))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('flyDrone.html', alert = alert)

@app.route('/joinSwarm', methods = ['GET', 'POST'])
def joinSwarm():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        ip_id = request.form['ip_id']
        ip_tag = request.form['ip_tag']
        ip_swarm_leader_tag = request.form['ip_swarm_leader_tag']
        if len(ip_id) <= 40:
            cursor.execute('call join_swarm(% s, % s, % s)', (ip_id, ip_tag, ip_swarm_leader_tag))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('joinSwarm.html', alert = alert)

@app.route('/leaveSwarm', methods = ['GET', 'POST'])
def leaveSwarm():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        ip_id = request.form['ip_id']
        ip_tag = request.form['ip_tag']
        if len(ip_id) <= 40:
            cursor.execute('call leave_swarm(% s, % s)', (ip_id, ip_tag))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('leaveSwarm.html', alert = alert)

@app.route('/startFunding', methods = ['GET', 'POST'])
def startFunding():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        owner = request.form['ip_owner']
        long_name = request.form['ip_long_name']
        if len(owner) <= 40 and len(long_name) <= 40:
            cursor.execute('call start_funding(% s, % s)', (owner, long_name))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('startFunding.html', alert = alert)

@app.route('/takeoverDrone', methods = ['GET', 'POST'])
def takeoverDrone():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        username = request.form['username']
        id = request.form['ip_id']
        tag = request.form['ip_tag']
        if len(username) <= 40 and len(id) <= 40 :
            cursor.execute('call add_owner(% s, % s, % s)', (username, id, tag))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('takeoverDrone.html', alert = alert)


if __name__ == "__main__":
    app.run(debug=True)
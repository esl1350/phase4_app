from flask import Flask, render_template, request, redirect, url_for, session
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re

app = Flask(__name__)
mysql = MySQL(app)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '11212020'
app.config['MYSQL_DB'] = 'restaurant_supply_express'

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/addUser', methods = ['GET', 'POST'])
def addUser():
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
    return render_template('addUser.html', alert = alert)

@app.route('/addPilot', methods = ['GET', 'POST'])
def addPilot():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        username = request.form['username']
        licenseID = request.form['licenseID']
        pilotExperience = request.form['pilotExperience']
        if len(username) <= 40 and len(licenseID) <= 40 and pilotExperience.isdigit():
            cursor.execute('call add_pilot_role(% s, % s, % s)', (username, licenseID, pilotExperience))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('addPilot.html', alert = alert)

@app.route('/purchaseIng', methods = ['GET', 'POST'])
def purchaseIng():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        longName = request.form['longName']
        id = request.form['id']
        tag = request.form['tag']
        barcode = request.form['barcode']
        quantity = request.form['quantity']
        if len(longName) <= 40 and len(id) <= 40 and len(tag) <= 40 and len(barcode) <= 40 and quantity.isdigit():
            cursor.execute('call purchase_ingredient(% s, % s, % s, % s, % s)', (longName, id, tag, barcode, quantity))
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('purchaseIng.html', alert = alert)


@app.route('/addWorker', methods = ['GET', 'POST'])
def addWorker():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        username = request.form['username']
        if len(username) <= 40:
            cursor.execute('call add_worker_role(% s)', [username])
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('addWorker.html', alert = alert)

@app.route('/removePilot', methods = ['GET', 'POST'])
def removePilot():
    alert = ''
    if request.method == 'POST':
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        username = request.form['username']
        if len(username) <= 40:
            cursor.execute('call remove_pilot_role(% s)', [username])
            mysql.connection.commit()
            alert = 'query executed!'
        else:
            alert = 'field lengths incorrect'
    return render_template('removePilot.html', alert = alert)

@app.route('/displayOwner')
def displayOwner():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('SELECT * FROM display_owner_view;')
    rows = cursor.fetchall()
    print(rows)
    return render_template('displayOwner.html', rows = rows)

@app.route('/displayIng')
def displayIng():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('SELECT * FROM display_ingredient_view;')
    rows = cursor.fetchall()
    print(rows)
    return render_template('displayIng.html', rows = rows)

@app.route('/displayService')
def displayService():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('SELECT * FROM display_service_view;')
    rows = cursor.fetchall()
    print(rows)
    return render_template('displayService.html', rows = rows)


if __name__ == "__main__":
    app.run(debug=True)
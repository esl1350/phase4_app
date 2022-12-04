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

@app.route('/displayOwner')
def displayOwner():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('SELECT * FROM display_owner_view;')
    rows = cursor.fetchall()
    print(rows)
    return render_template('displayOwner.html', rows = rows)
if __name__ == "__main__":
    app.run(debug=True)
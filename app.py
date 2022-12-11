from flask import Flask, render_template, request, redirect, url_for, session
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re

app = Flask(__name__)
mysql = MySQL(app)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Simba@316'
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
    return render_template('displayOwner.html', rows = rows)

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

@app.route('/displayEmployee')
def displayEmployee():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('SELECT * FROM display_employee_view;')
    rows = cursor.fetchall()
    return render_template('displayEmployee.html', rows = rows)



if __name__ == "__main__":
    app.run(debug=True)
# phase4_app
CS 4400 Phase 4 Project: Restaurant Supply Express

by: Reuben An, Kenny Hoang, Jeffrey Lei, Elizabeth Liu 
 
## Setup:

This setup is for the Windows operating system. Mac/Linux may differ.

Clone the repo, and run the sql files located in the static folder in your own mySQL workbench (cs4400_phase3_stored_procedures_SHELL_v0_2.sql and restaurant_delivery_schema.sql).

Go into app.py and update the following lines of code with your own mySQL username and password (should be near the top of the file).
```
 app.config['MYSQL_USER'] = 'your username here'
 app.config['MYSQL_PASSWORD'] = 'your password here'
```
Use pip to install the following package and then create and activate a virtual environment by running the activate script in the venv folder.
```
 pip install virtualenv
 python -m venv venv
 venv\Scripts\activate
```
Once inside the virtual environment, your command line should look like this:
```
 (venv) [your path here]>
```
Use pip to install the following packages within the virtual environment.
```
 pip install Flask
 pip install flask-mysqldb
```
Still working inside your virtual environment, use python to run app.py.
```
 python app.py
```
The terminal will run the application locally.

## Technologies used:

To create our application, we used Flask, Flaskmysql, and mysql. The flask framework connects to the mysql database through the flaskmysql package. GitHub was also used for version control so that our group could work on separate parts of the application at the same time. This let us split up the work and complete the application in a timely manner.

## Work distribution:

Our group seperated out the stored procedure sections from the main use case file and assigned them to the members. Bug testing and edge cases were checked as a group 

### Kenny Hoang: 
sections: 5 and 6

view: 24



### Elizabeth Liu : 
sections: 3 and 4 

view: 25

Set up of flask and github

### Jeffrey Lei: 
sections: 1 and 7

view: 26 and 27

preliminary checks for invalid user input

### Reuben Ahn: 
sections: 2 and 8 

view: 28 and 29 


# phase4_app
CS 4400 Phase 4 Project: Restaurant Supply Express
by: Reuben An, Kenny Hoang, Jeffrey Lei, Elizabeth Liu 
 
## Setup:
Clone the repo, and run the sql files located in the static folder in your own mySQL workbench (cs4400_phase3_stored_procedures_SHELL_v0_2.sql and restaurant_delivery_schema.sql).

Go into app.py and update the following lines of code with your own mySQL username and password (should be near the top of the file).

 app.config['MYSQL_USER'] = 'your username here'
 app.config['MYSQL_PASSWORD'] = 'your password here'

Use pip to install the following package and then create a virtual environment by running the activate.bat script in the venv folder.
 > pip install virtualenv

Once inside the virtual environment, your command line should look like this:
 (venv) [your path here]>

Use pip to install the following packages within the virtual environment.
 > pip install Flask
 > pip install flask-mysqldb

Still working inside your virtual environment, use python to run app.py.
 > python app.py
 
The terminal will run the application locally.

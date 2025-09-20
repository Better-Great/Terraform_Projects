from flask import Flask, render_template, request, redirect, url_for
import psycopg2
import bcrypt
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)

# PostgreSQL configurations - loaded from .env file
DATABASE_CONFIG = {
    'host': os.environ.get('DB_HOST'),
    'database': os.environ.get('DB_NAME'),
    'user': os.environ.get('DB_USERNAME'),
    'password': os.environ.get('DB_PASSWORD'),
    'port': os.environ.get('DB_PORT')
}

# Connect to PostgreSQL
def get_db_connection():
    conn = psycopg2.connect(**DATABASE_CONFIG)
    return conn

# Create a table to store user data if it doesn't exist
def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    create_table_query = """
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255),
            email VARCHAR(255),
            address TEXT,
            phonenumber VARCHAR(255),
            password VARCHAR(255)
        )
    """
    cursor.execute(create_table_query)
    conn.commit()
    cursor.close()
    conn.close()

# Initialize database
init_db()


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/submit', methods=['POST'])
def submit():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        address = request.form['address']
        phonenumber = request.form['phonenumber']
        
        # Hash the password before storing it
        password = request.form['password'].encode('utf-8')  # Get the password from the form
        hashed_password = bcrypt.hashpw(password, bcrypt.gensalt())

        # Insert user data into the database
        conn = get_db_connection()
        cursor = conn.cursor()
        
        insert_query = "INSERT INTO users (name, email, address, phonenumber, password) VALUES (%s, %s, %s, %s, %s)"
        cursor.execute(insert_query, (name, email, address, phonenumber, hashed_password.decode('utf-8')))
        conn.commit()
        
        # Fetch the latest entry
        cursor.execute("SELECT * FROM users ORDER BY id DESC LIMIT 1")
        data = cursor.fetchall()

        cursor.close()
        conn.close()
        
        return render_template('submitteddata.html', data=data)
    
    return redirect(url_for('index'))



@app.route('/get-data', methods=['GET', 'POST'])
def get_data():
    if request.method == 'POST':
        # Retrieve data based on user input ID
        input_id = request.form['input_id']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        select_query = "SELECT * FROM users WHERE id = %s"
        cursor.execute(select_query, (input_id,))
        data = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return render_template('data.html', data=data, input_id=input_id)
    return render_template('get_data.html')

@app.route('/delete/<int:id>', methods=['GET', 'POST'])
def delete_data(id):
    if request.method == 'POST':
        # Perform deletion based on the provided ID
        conn = get_db_connection()
        cursor = conn.cursor()
        
        delete_query = "DELETE FROM users WHERE id = %s"
        cursor.execute(delete_query, (id,))
        conn.commit()
        
        cursor.close()
        conn.close()
        
        return redirect(url_for('get_data'))
    return render_template('delete.html', id=id)


if __name__ == '__main__':
    app.run(debug=True, port=8080, host='0.0.0.0')

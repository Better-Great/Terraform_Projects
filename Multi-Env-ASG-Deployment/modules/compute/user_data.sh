#!/bin/bash

# Update system
apt-get update -y

# Install required packages
apt-get install -y python3 python3-pip python3-venv awscli

# Create application directory
mkdir -p /opt/webapp
cd /opt/webapp

# Set environment variables for database connection
export DB_HOST="${db_host}"
export DB_NAME="${db_name}"
export DB_USERNAME="${db_username}"
export DB_PASSWORD="${db_password}"
export DB_PORT="${db_port}"

# Create the Flask application files (based on 3-tier-user-management-app)
cat << 'EOF' > app.py
from flask import Flask, render_template, request, redirect, url_for
import psycopg2
import bcrypt
import os

app = Flask(__name__)

# PostgreSQL configurations
DATABASE_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'database': os.environ.get('DB_NAME', 'webappdb'),
    'user': os.environ.get('DB_USERNAME', 'admin'),
    'password': os.environ.get('DB_PASSWORD', ''),
    'port': os.environ.get('DB_PORT', '5432')
}

# Connect to PostgreSQL
def get_db_connection():
    conn = psycopg2.connect(**DATABASE_CONFIG)
    return conn

# Create a table to store user data if it doesn't exist
def init_db():
    try:
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
        print("Database initialized successfully")
    except Exception as e:
        print(f"Database initialization error: {e}")

# Initialize database
init_db()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/health')
def health_check():
    return {'status': 'healthy', 'service': 'user-management-app'}, 200

@app.route('/submit', methods=['POST'])
def submit():
    if request.method == 'POST':
        try:
            name = request.form['name']
            email = request.form['email']
            address = request.form['address']
            phonenumber = request.form['phonenumber']
            
            # Hash the password before storing it
            password = request.form['password'].encode('utf-8')
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
        except Exception as e:
            print(f"Error submitting data: {e}")
            return redirect(url_for('index'))
    
    return redirect(url_for('index'))

@app.route('/get-data', methods=['GET', 'POST'])
def get_data():
    if request.method == 'POST':
        try:
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
        except Exception as e:
            print(f"Error retrieving data: {e}")
            return render_template('get_data.html')
    return render_template('get_data.html')

@app.route('/delete/<int:id>', methods=['GET', 'POST'])
def delete_data(id):
    if request.method == 'POST':
        try:
            # Perform deletion based on the provided ID
            conn = get_db_connection()
            cursor = conn.cursor()
            
            delete_query = "DELETE FROM users WHERE id = %s"
            cursor.execute(delete_query, (id,))
            conn.commit()
            
            cursor.close()
            conn.close()
            
            return redirect(url_for('get_data'))
        except Exception as e:
            print(f"Error deleting data: {e}")
            return redirect(url_for('get_data'))
    return render_template('delete.html', id=id)

if __name__ == '__main__':
    app.run(debug=False, port=${app_port}, host='0.0.0.0')
EOF

# Create requirements.txt (based on 3-tier-user-management-app/requirements.txt)
cat << 'EOF' > requirements.txt
Flask==2.3.3
psycopg2-binary==2.9.7
bcrypt==4.0.1
EOF

# Create templates directory and HTML files
mkdir -p templates

cat << 'EOF' > templates/index.html
<!DOCTYPE html>
<html>
<head>
    <title>User Management App</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background-color: #f5f5f5; 
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .form-group { margin-bottom: 15px; }
        label { 
            display: block; 
            margin-bottom: 5px; 
            font-weight: bold;
            color: #333;
        }
        input[type="text"], input[type="email"], input[type="password"], textarea { 
            width: 100%; 
            padding: 10px; 
            margin-bottom: 10px; 
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        input[type="submit"] { 
            background-color: #4CAF50; 
            color: white; 
            padding: 12px 24px; 
            border: none; 
            cursor: pointer; 
            border-radius: 4px;
            font-size: 16px;
        }
        input[type="submit"]:hover {
            background-color: #45a049;
        }
        .nav { 
            margin-bottom: 20px; 
            text-align: center;
        }
        .nav a { 
            margin-right: 20px; 
            text-decoration: none; 
            color: #007bff; 
            font-weight: bold;
        }
        .nav a:hover {
            text-decoration: underline;
        }
        h1 {
            color: #333;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="/">Home</a>
            <a href="/get-data">View Data</a>
        </div>
        
        <h1>User Registration</h1>
        <form method="POST" action="/submit">
            <div class="form-group">
                <label for="name">Name:</label>
                <input type="text" id="name" name="name" required>
            </div>
            
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" required>
            </div>
            
            <div class="form-group">
                <label for="address">Address:</label>
                <textarea id="address" name="address" rows="3" required></textarea>
            </div>
            
            <div class="form-group">
                <label for="phonenumber">Phone Number:</label>
                <input type="text" id="phonenumber" name="phonenumber" required>
            </div>
            
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <input type="submit" value="Submit">
        </form>
    </div>
</body>
</html>
EOF

cat << 'EOF' > templates/submitteddata.html
<!DOCTYPE html>
<html>
<head>
    <title>Submitted Data</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background-color: #f5f5f5; 
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        table { 
            border-collapse: collapse; 
            width: 100%; 
            margin-top: 20px;
        }
        th, td { 
            border: 1px solid #ddd; 
            padding: 12px; 
            text-align: left; 
        }
        th { 
            background-color: #4CAF50; 
            color: white;
        }
        .nav { 
            margin-bottom: 20px; 
            text-align: center;
        }
        .nav a { 
            margin-right: 20px; 
            text-decoration: none; 
            color: #007bff; 
            font-weight: bold;
        }
        .nav a:hover {
            text-decoration: underline;
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="/">Home</a>
            <a href="/get-data">View Data</a>
        </div>
        
        <div class="success">
            <h2>Data Submitted Successfully!</h2>
        </div>
        
        <h1>User Details</h1>
        <table>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Address</th>
                <th>Phone Number</th>
            </tr>
            {% for row in data %}
            <tr>
                <td>{{ row[0] }}</td>
                <td>{{ row[1] }}</td>
                <td>{{ row[2] }}</td>
                <td>{{ row[3] }}</td>
                <td>{{ row[4] }}</td>
            </tr>
            {% endfor %}
        </table>
    </div>
</body>
</html>
EOF

cat << 'EOF' > templates/get_data.html
<!DOCTYPE html>
<html>
<head>
    <title>Get User Data</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background-color: #f5f5f5; 
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .form-group { margin-bottom: 15px; }
        label { 
            display: block; 
            margin-bottom: 5px; 
            font-weight: bold;
            color: #333;
        }
        input[type="text"] { 
            width: 200px; 
            padding: 10px; 
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        input[type="submit"] { 
            background-color: #4CAF50; 
            color: white; 
            padding: 12px 24px; 
            border: none; 
            cursor: pointer; 
            border-radius: 4px;
            font-size: 16px;
        }
        input[type="submit"]:hover {
            background-color: #45a049;
        }
        .nav { 
            margin-bottom: 20px; 
            text-align: center;
        }
        .nav a { 
            margin-right: 20px; 
            text-decoration: none; 
            color: #007bff; 
            font-weight: bold;
        }
        .nav a:hover {
            text-decoration: underline;
        }
        h1 {
            color: #333;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="/">Home</a>
            <a href="/get-data">View Data</a>
        </div>
        
        <h1>Get User Data</h1>
        <form method="POST">
            <div class="form-group">
                <label for="input_id">Enter User ID:</label>
                <input type="text" id="input_id" name="input_id" required>
            </div>
            <input type="submit" value="Get Data">
        </form>
    </div>
</body>
</html>
EOF

cat << 'EOF' > templates/data.html
<!DOCTYPE html>
<html>
<head>
    <title>User Data</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background-color: #f5f5f5; 
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        table { 
            border-collapse: collapse; 
            width: 100%; 
            margin-top: 20px;
        }
        th, td { 
            border: 1px solid #ddd; 
            padding: 12px; 
            text-align: left; 
        }
        th { 
            background-color: #4CAF50; 
            color: white;
        }
        .nav { 
            margin-bottom: 20px; 
            text-align: center;
        }
        .nav a { 
            margin-right: 20px; 
            text-decoration: none; 
            color: #007bff; 
            font-weight: bold;
        }
        .nav a:hover {
            text-decoration: underline;
        }
        .delete-btn { 
            background-color: #f44336; 
            color: white; 
            padding: 8px 16px; 
            text-decoration: none; 
            border-radius: 4px;
            font-size: 14px;
        }
        .delete-btn:hover {
            background-color: #da190b;
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .no-data {
            text-align: center;
            color: #666;
            font-style: italic;
            padding: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="/">Home</a>
            <a href="/get-data">View Data</a>
        </div>
        
        <h1>User Data for ID: {{ input_id }}</h1>
        {% if data %}
        <table>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Address</th>
                <th>Phone Number</th>
                <th>Action</th>
            </tr>
            {% for row in data %}
            <tr>
                <td>{{ row[0] }}</td>
                <td>{{ row[1] }}</td>
                <td>{{ row[2] }}</td>
                <td>{{ row[3] }}</td>
                <td>{{ row[4] }}</td>
                <td><a href="/delete/{{ row[0] }}" class="delete-btn">Delete</a></td>
            </tr>
            {% endfor %}
        </table>
        {% else %}
        <div class="no-data">
            <p>No data found for ID: {{ input_id }}</p>
        </div>
        {% endif %}
    </div>
</body>
</html>
EOF

cat << 'EOF' > templates/delete.html
<!DOCTYPE html>
<html>
<head>
    <title>Delete User</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background-color: #f5f5f5; 
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .nav { 
            margin-bottom: 20px; 
            text-align: center;
        }
        .nav a { 
            margin-right: 20px; 
            text-decoration: none; 
            color: #007bff; 
            font-weight: bold;
        }
        .nav a:hover {
            text-decoration: underline;
        }
        .delete-btn { 
            background-color: #f44336; 
            color: white; 
            padding: 12px 24px; 
            border: none; 
            cursor: pointer; 
            border-radius: 4px;
            font-size: 16px;
        }
        .delete-btn:hover {
            background-color: #da190b;
        }
        .cancel-btn { 
            background-color: #6c757d; 
            color: white; 
            padding: 12px 24px; 
            text-decoration: none; 
            margin-left: 10px; 
            border-radius: 4px;
            font-size: 16px;
        }
        .cancel-btn:hover {
            background-color: #5a6268;
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .warning {
            background-color: #fff3cd;
            color: #856404;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
            text-align: center;
        }
        .button-group {
            text-align: center;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="/">Home</a>
            <a href="/get-data">View Data</a>
        </div>
        
        <h1>Delete User</h1>
        <div class="warning">
            <p><strong>Warning:</strong> Are you sure you want to delete user with ID: {{ id }}?</p>
            <p>This action cannot be undone.</p>
        </div>
        
        <div class="button-group">
            <form method="POST" style="display: inline;">
                <input type="submit" value="Delete User" class="delete-btn">
            </form>
            <a href="/get-data" class="cancel-btn">Cancel</a>
        </div>
    </div>
</body>
</html>
EOF

# Create virtual environment and install dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create systemd service file
cat << EOF > /etc/systemd/system/webapp.service
[Unit]
Description=Flask User Management Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/webapp
Environment=PATH=/opt/webapp/venv/bin
Environment=DB_HOST=${db_host}
Environment=DB_NAME=${db_name}
Environment=DB_USERNAME=${db_username}
Environment=DB_PASSWORD=${db_password}
Environment=DB_PORT=${db_port}
ExecStart=/opt/webapp/venv/bin/python app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Change ownership to ubuntu user
chown -R ubuntu:ubuntu /opt/webapp

# Enable and start the service
systemctl daemon-reload
systemctl enable webapp.service
systemctl start webapp.service

# Wait a moment for the service to start
sleep 10

# Check service status
systemctl status webapp.service --no-pager -l

echo "Application deployment completed!"
echo "Service status: $(systemctl is-active webapp.service)"
echo "Application should be running on port ${app_port}"
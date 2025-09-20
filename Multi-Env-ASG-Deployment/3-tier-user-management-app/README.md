# 3-Tier User Management Web Application

A modern Flask-based user management system with PostgreSQL database backend, designed for local development and cloud deployment.

## 🏗️ Architecture Overview

This is a **3-tier web application** consisting of:

1. **Presentation Layer (Frontend)**: HTML templates with modern CSS styling
2. **Application Layer (Backend)**: Flask web framework with Python business logic
3. **Data Layer (Database)**: PostgreSQL database for persistent storage

## ✨ Features

- **User Registration**: Secure user account creation with password hashing
- **Data Management**: Create, read, and delete user records
- **Modern UI**: Clean, responsive web interface
- **Secure Authentication**: BCrypt password hashing
- **Environment Configuration**: Configurable database settings via `.env` file
- **Local Development Ready**: Easy setup for local testing and development

## 🚀 Local Setup & Installation

### Prerequisites

- Python 3.8+
- PostgreSQL 12+
- Git

### Step 1: Clone the Repository

```bash
git clone <your-repository-url>
cd 3-tier-user-management-app
```

### Step 2: Set Up Python Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # On Linux/Mac
# venv\Scripts\activate   # On Windows

# Install dependencies
pip install -r requirements.txt
```

### Step 3: Configure PostgreSQL Database

#### Install PostgreSQL (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib -y
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### Create Database and User
```bash
# Switch to postgres user
sudo -u postgres psql

# In PostgreSQL shell, run:
CREATE DATABASE webappdb;
CREATE USER admin WITH PASSWORD 'admin123';
GRANT ALL PRIVILEGES ON DATABASE webappdb TO admin;
ALTER DATABASE webappdb OWNER TO admin;
GRANT ALL PRIVILEGES ON SCHEMA public TO admin;
\q
```

### Step 4: Configure Environment Variables

Create a `.env` file in the project root:

```bash
# Database Configuration
DB_HOST=localhost
DB_NAME=webappdb
DB_USERNAME=admin
DB_PASSWORD=admin123
DB_PORT=5432

# Flask Configuration
FLASK_ENV=development
FLASK_DEBUG=True

# Security
SECRET_KEY=your-secret-key-for-local-dev
```

### Step 5: Run the Application

```bash
# Make sure you're in the project directory and virtual environment is activated
source venv/bin/activate
python3 app.py
```

The application will be available at:
- **Local**: http://127.0.0.1:8080
- **Network**: http://0.0.0.0:8080

## 📖 Usage Guide

### User Registration
1. Navigate to the home page
2. Fill in the registration form with:
   - Name
   - Email
   - Address
   - Phone Number
   - Password
3. Submit to create a new user account

### Data Retrieval
1. Go to "Get Data" page
2. Enter a user ID to retrieve specific user information
3. View user details or delete records as needed

### Database Management
- The application automatically creates the `users` table on first run
- User passwords are securely hashed using BCrypt
- All database operations use parameterized queries for security

## 🛠️ Development

### Project Structure
```
3-tier-user-management-app/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── .env                   # Environment configuration (create this)
├── .gitignore            # Git ignore rules
├── templates/            # HTML templates
│   ├── index.html        # Home/registration page
│   ├── get_data.html     # Data retrieval page
│   ├── data.html         # Display user data
│   └── submitteddata.html # Registration success page
└── venv/                 # Virtual environment (auto-generated)
```

### Dependencies
- **Flask 2.3.3**: Web framework
- **psycopg2-binary 2.9.7**: PostgreSQL adapter
- **bcrypt 4.0.1**: Password hashing
- **python-dotenv 1.1.1**: Environment variable management

### Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `DB_HOST` | Database host | `localhost` |
| `DB_NAME` | Database name | `webappdb` |
| `DB_USERNAME` | Database user | `admin` |
| `DB_PASSWORD` | Database password | `admin123` |
| `DB_PORT` | Database port | `5432` |

## 🔒 Security Features

- **Password Hashing**: All passwords are hashed using BCrypt before storage
- **SQL Injection Prevention**: Parameterized queries protect against SQL injection
- **Environment Variables**: Sensitive configuration stored in `.env` file (not in version control)
- **Debug Mode**: Only enabled in development environment

## 🚨 Troubleshooting

### Common Issues

**1. "No password supplied" error**
- Ensure `.env` file exists and contains all required variables
- Check PostgreSQL user permissions

**2. "Permission denied for schema public"**
```bash
sudo -u postgres psql -c "ALTER DATABASE webappdb OWNER TO admin;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON SCHEMA public TO admin;"
```

**3. "ModuleNotFoundError: No module named 'flask'"**
- Activate virtual environment: `source venv/bin/activate`
- Install dependencies: `pip install -r requirements.txt`

**4. PostgreSQL connection refused**
```bash
sudo systemctl start postgresql
sudo systemctl status postgresql
```

## 🎥 Tutorial Credit

This project is based on the excellent tutorial by **TechTrapture**:
- **YouTube Channel**: [TechTrapture](https://youtu.be/pTtqGvDJ1DQ)
- **Original Tutorial**: "Three-Tier Python Web Application on Google Compute Engine and CloudSQL"

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🔄 Future Enhancements

- [ ] User authentication and sessions
- [ ] Password reset functionality
- [ ] User profile editing
- [ ] Data validation and error handling
- [ ] API endpoints for mobile app integration
- [ ] Docker containerization
- [ ] Cloud deployment automation with Terraform

---

**Happy Coding!** 🚀

For questions or support, please refer to the original tutorial or create an issue in this repository.
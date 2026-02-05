# Sri Murugan Finance Backend API

FastAPI backend for the Sri Murugan Finance mobile application with PostgreSQL database.

## Features

- User authentication (email/password and MPIN)
- Loan management system
- Transaction tracking
- JWT token-based security
- PostgreSQL database with SQLAlchemy ORM
- Database migrations with Alembic

## Setup Instructions

### 1. Install Dependencies

```bash
cd Srimurugan-groups/backend
pip install -r requirements.txt
```

### 2. Database Setup

1. Install PostgreSQL on your system
2. Create a database named `sri_murugan_finance`
3. Copy `.env.example` to `.env` and update database credentials:

```bash
cp .env.example .env
```

Edit `.env` file:
```
DATABASE_URL=postgresql://your_username:your_password@localhost:5432/sri_murugan_finance
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### 3. Run the Server with Sample Data

```bash
# This will initialize the database with sample data and start the server
python run_server.py
```

OR manually:

```bash
# Initialize database with sample data
python init_db.py

# Start the server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

### 4. Sample Login Credentials

After running `init_db.py`, you can use these test accounts:

| Email | Phone | Password | MPIN |
|-------|-------|----------|------|
| john.doe@gmail.com | +919876543210 | password123 | 1234 |
| priya.sharma@gmail.com | +919876543211 | password123 | 1234 |
| rajesh.kumar@gmail.com | +919876543212 | password123 | 1234 |
| anita.singh@gmail.com | +919876543213 | password123 | 1234 |
| vikram.patel@gmail.com | +919876543214 | password123 | 1234 |

## API Documentation

Once the server is running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login with email/password
- `POST /api/auth/mpin-login` - Login with phone/MPIN
- `POST /api/auth/set-mpin` - Set MPIN for user
- `POST /api/auth/change-password` - Change password

### Users
- `GET /api/users/me` - Get current user info
- `GET /api/users/{user_id}` - Get user by ID

### Loans
- `POST /api/loans/apply` - Apply for a loan
- `GET /api/loans/my-loans` - Get user's loans
- `GET /api/loans/{loan_id}` - Get specific loan
- `PUT /api/loans/{loan_id}/status` - Update loan status

### Transactions
- `POST /api/transactions/` - Create transaction
- `GET /api/transactions/my-transactions` - Get user's transactions
- `GET /api/transactions/loan/{loan_id}` - Get loan transactions
- `GET /api/transactions/{transaction_id}` - Get specific transaction

### Admin
- `GET /api/admin/users` - Get all users (with pagination)
- `GET /api/admin/users/{user_id}/loans` - Get user's loans
- `GET /api/admin/users/{user_id}/transactions` - Get user's transactions
- `GET /api/admin/loans` - Get all loans (with status filter)
- `GET /api/admin/transactions` - Get all transactions (with type filter)
- `GET /api/admin/stats` - Get system statistics
- `PUT /api/admin/loans/{loan_id}/approve` - Approve loan
- `PUT /api/admin/loans/{loan_id}/reject` - Reject loan

## Database Schema

### Users Table
- id, email, phone, full_name, hashed_password, mpin, is_active, created_at, updated_at

### Loans Table
- id, user_id, loan_amount, interest_rate, tenure_months, monthly_emi, outstanding_amount, status, purpose, created_at, updated_at

### Transactions Table
- id, user_id, loan_id, transaction_type, amount, description, status, created_at

## Security Features

- Password hashing with bcrypt
- JWT token authentication
- CORS middleware for Flutter app
- Input validation with Pydantic
- SQL injection protection with SQLAlchemy ORM
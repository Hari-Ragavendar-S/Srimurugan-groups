"""
Database initialization script with sample data
Run this after setting up your database to populate it with test users and transactions
"""

from sqlalchemy.orm import Session
from app.database import SessionLocal, engine
from app import models
from app.auth import get_password_hash
from datetime import datetime, timedelta
import random

# Create all tables
models.Base.metadata.create_all(bind=engine)

def init_sample_data():
    db = SessionLocal()
    
    try:
        # Check if data already exists
        existing_users = db.query(models.User).count()
        if existing_users > 0:
            print("Sample data already exists. Skipping initialization.")
            return
        
        print("Creating sample users...")
        
        # Sample users data
        sample_users = [
            {
                "email": "john.doe@gmail.com",
                "phone": "+919876543210",
                "full_name": "John Doe",
                "password": "password123"
            },
            {
                "email": "priya.sharma@gmail.com", 
                "phone": "+919876543211",
                "full_name": "Priya Sharma",
                "password": "password123"
            },
            {
                "email": "rajesh.kumar@gmail.com",
                "phone": "+919876543212", 
                "full_name": "Rajesh Kumar",
                "password": "password123"
            },
            {
                "email": "anita.singh@gmail.com",
                "phone": "+919876543213",
                "full_name": "Anita Singh", 
                "password": "password123"
            },
            {
                "email": "vikram.patel@gmail.com",
                "phone": "+919876543214",
                "full_name": "Vikram Patel",
                "password": "password123"
            }
        ]
        
        # Create users
        created_users = []
        for user_data in sample_users:
            user = models.User(
                email=user_data["email"],
                phone=user_data["phone"],
                full_name=user_data["full_name"],
                hashed_password=get_password_hash(user_data["password"]),
                mpin=get_password_hash("1234"),  # Default MPIN for all users
                is_active=True,
                created_at=datetime.utcnow() - timedelta(days=random.randint(30, 365))
            )
            db.add(user)
            created_users.append(user)
        
        db.commit()
        
        # Refresh to get IDs
        for user in created_users:
            db.refresh(user)
        
        print(f"Created {len(created_users)} users")
        
        # Sample loans data
        print("Creating sample loans...")
        
        loan_purposes = [
            "Home Renovation", "Business Expansion", "Education", 
            "Medical Emergency", "Wedding", "Vehicle Purchase",
            "Debt Consolidation", "Travel", "Equipment Purchase"
        ]
        
        loan_statuses = ["pending", "approved", "active", "closed", "rejected"]
        
        created_loans = []
        for user in created_users:
            # Each user gets 1-3 loans
            num_loans = random.randint(1, 3)
            
            for _ in range(num_loans):
                loan_amount = random.choice([50000, 100000, 200000, 300000, 500000, 750000, 1000000])
                interest_rate = random.uniform(8.5, 15.0)
                tenure_months = random.choice([12, 24, 36, 48, 60])
                
                # Calculate EMI
                monthly_rate = interest_rate / (12 * 100)
                emi = loan_amount * monthly_rate * (1 + monthly_rate) ** tenure_months / ((1 + monthly_rate) ** tenure_months - 1)
                emi = round(emi, 2)
                
                # Random outstanding amount (0 to full amount)
                outstanding_ratio = random.uniform(0.0, 1.0)
                outstanding_amount = round(loan_amount * outstanding_ratio, 2)
                
                # Status based on outstanding amount
                if outstanding_amount == 0:
                    status = "closed"
                elif outstanding_amount == loan_amount:
                    status = random.choice(["pending", "approved"])
                else:
                    status = "active"
                
                loan = models.Loan(
                    user_id=user.id,
                    loan_amount=loan_amount,
                    interest_rate=round(interest_rate, 2),
                    tenure_months=tenure_months,
                    monthly_emi=emi,
                    outstanding_amount=outstanding_amount,
                    status=status,
                    purpose=random.choice(loan_purposes),
                    created_at=datetime.utcnow() - timedelta(days=random.randint(1, 300)),
                    updated_at=datetime.utcnow() - timedelta(days=random.randint(0, 30))
                )
                db.add(loan)
                created_loans.append(loan)
        
        db.commit()
        
        # Refresh loans to get IDs
        for loan in created_loans:
            db.refresh(loan)
        
        print(f"Created {len(created_loans)} loans")
        
        # Sample transactions
        print("Creating sample transactions...")
        
        transaction_types = ["payment", "disbursement", "fee", "penalty"]
        transaction_descriptions = [
            "EMI Payment", "Loan Disbursement", "Processing Fee", 
            "Late Payment Fee", "Prepayment", "Interest Payment",
            "Principal Payment", "Documentation Fee", "Insurance Premium"
        ]
        
        created_transactions = []
        
        # Create transactions for each loan
        for loan in created_loans:
            if loan.status in ["active", "closed"]:
                # Create disbursement transaction
                disbursement = models.Transaction(
                    user_id=loan.user_id,
                    loan_id=loan.id,
                    transaction_type="disbursement",
                    amount=loan.loan_amount,
                    description="Loan Amount Disbursed",
                    status="completed",
                    created_at=loan.created_at + timedelta(days=1)
                )
                db.add(disbursement)
                created_transactions.append(disbursement)
                
                # Create payment transactions
                paid_amount = loan.loan_amount - loan.outstanding_amount
                if paid_amount > 0:
                    num_payments = random.randint(1, min(12, int(paid_amount / loan.monthly_emi) + 1))
                    
                    for i in range(num_payments):
                        payment_amount = random.uniform(loan.monthly_emi * 0.8, loan.monthly_emi * 1.2)
                        payment_amount = round(payment_amount, 2)
                        
                        payment = models.Transaction(
                            user_id=loan.user_id,
                            loan_id=loan.id,
                            transaction_type="payment",
                            amount=payment_amount,
                            description=random.choice(transaction_descriptions),
                            status="completed",
                            created_at=loan.created_at + timedelta(days=30 * (i + 1) + random.randint(-5, 5))
                        )
                        db.add(payment)
                        created_transactions.append(payment)
                
                # Random fee transactions
                if random.random() < 0.3:  # 30% chance of fee transaction
                    fee = models.Transaction(
                        user_id=loan.user_id,
                        loan_id=loan.id,
                        transaction_type="fee",
                        amount=random.choice([500, 1000, 1500, 2000]),
                        description=random.choice(["Processing Fee", "Documentation Fee", "Late Payment Fee"]),
                        status="completed",
                        created_at=loan.created_at + timedelta(days=random.randint(1, 100))
                    )
                    db.add(fee)
                    created_transactions.append(fee)
        
        # Create some standalone transactions (not linked to loans)
        for user in created_users:
            if random.random() < 0.4:  # 40% chance of standalone transaction
                standalone = models.Transaction(
                    user_id=user.id,
                    loan_id=None,
                    transaction_type=random.choice(["fee", "payment"]),
                    amount=random.choice([100, 250, 500, 750, 1000]),
                    description="Account Maintenance Fee",
                    status="completed",
                    created_at=datetime.utcnow() - timedelta(days=random.randint(1, 180))
                )
                db.add(standalone)
                created_transactions.append(standalone)
        
        db.commit()
        print(f"Created {len(created_transactions)} transactions")
        
        # Print summary
        print("\n" + "="*50)
        print("DATABASE INITIALIZATION COMPLETE!")
        print("="*50)
        print(f"✅ Users created: {len(created_users)}")
        print(f"✅ Loans created: {len(created_loans)}")
        print(f"✅ Transactions created: {len(created_transactions)}")
        print("\nSample Login Credentials:")
        print("-" * 30)
        for user in created_users:
            print(f"Email: {user.email}")
            print(f"Phone: {user.phone}")
            print(f"Password: password123")
            print(f"MPIN: 1234")
            print("-" * 30)
        
        print("\nAPI Server: http://localhost:8000")
        print("API Docs: http://localhost:8000/docs")
        
    except Exception as e:
        print(f"Error initializing database: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    print("Initializing Sri Murugan Finance Database...")
    init_sample_data()
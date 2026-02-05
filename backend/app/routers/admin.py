"""
Admin endpoints for managing users, loans, and transactions
"""

from typing import List
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from app.database import get_db
from app import models, schemas, auth

router = APIRouter()

# For demo purposes, we'll skip admin authentication
# In production, add proper admin role checking

@router.get("/users", response_model=List[schemas.UserResponse])
def get_all_users(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """Get all users with pagination"""
    users = db.query(models.User).offset(skip).limit(limit).all()
    return users

@router.get("/users/{user_id}/loans", response_model=List[schemas.LoanResponse])
def get_user_loans(user_id: int, db: Session = Depends(get_db)):
    """Get all loans for a specific user"""
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    loans = db.query(models.Loan).filter(models.Loan.user_id == user_id).all()
    return loans

@router.get("/users/{user_id}/transactions", response_model=List[schemas.TransactionResponse])
def get_user_transactions(user_id: int, db: Session = Depends(get_db)):
    """Get all transactions for a specific user"""
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    transactions = db.query(models.Transaction).filter(
        models.Transaction.user_id == user_id
    ).order_by(desc(models.Transaction.created_at)).all()
    return transactions

@router.get("/loans", response_model=List[schemas.LoanResponse])
def get_all_loans(
    status: str = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """Get all loans with optional status filter"""
    query = db.query(models.Loan)
    
    if status:
        query = query.filter(models.Loan.status == status)
    
    loans = query.offset(skip).limit(limit).all()
    return loans

@router.get("/transactions", response_model=List[schemas.TransactionResponse])
def get_all_transactions(
    transaction_type: str = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """Get all transactions with optional type filter"""
    query = db.query(models.Transaction)
    
    if transaction_type:
        query = query.filter(models.Transaction.transaction_type == transaction_type)
    
    transactions = query.order_by(desc(models.Transaction.created_at)).offset(skip).limit(limit).all()
    return transactions

@router.get("/stats")
def get_system_stats(db: Session = Depends(get_db)):
    """Get system statistics"""
    total_users = db.query(models.User).count()
    total_loans = db.query(models.Loan).count()
    total_transactions = db.query(models.Transaction).count()
    
    # Loan statistics
    active_loans = db.query(models.Loan).filter(models.Loan.status == "active").count()
    pending_loans = db.query(models.Loan).filter(models.Loan.status == "pending").count()
    closed_loans = db.query(models.Loan).filter(models.Loan.status == "closed").count()
    
    # Amount statistics
    total_loan_amount = db.query(func.sum(models.Loan.loan_amount)).scalar() or 0
    total_outstanding = db.query(func.sum(models.Loan.outstanding_amount)).scalar() or 0
    total_payments = db.query(func.sum(models.Transaction.amount)).filter(
        models.Transaction.transaction_type == "payment"
    ).scalar() or 0
    
    return {
        "users": {
            "total": total_users,
            "active": db.query(models.User).filter(models.User.is_active == True).count()
        },
        "loans": {
            "total": total_loans,
            "active": active_loans,
            "pending": pending_loans,
            "closed": closed_loans,
            "total_amount": total_loan_amount,
            "outstanding_amount": total_outstanding
        },
        "transactions": {
            "total": total_transactions,
            "total_payments": total_payments
        }
    }

@router.put("/loans/{loan_id}/approve")
def approve_loan(loan_id: int, db: Session = Depends(get_db)):
    """Approve a pending loan"""
    loan = db.query(models.Loan).filter(models.Loan.id == loan_id).first()
    if not loan:
        raise HTTPException(status_code=404, detail="Loan not found")
    
    if loan.status != "pending":
        raise HTTPException(status_code=400, detail="Only pending loans can be approved")
    
    loan.status = "approved"
    db.commit()
    return {"message": "Loan approved successfully"}

@router.put("/loans/{loan_id}/reject")
def reject_loan(loan_id: int, reason: str, db: Session = Depends(get_db)):
    """Reject a pending loan"""
    loan = db.query(models.Loan).filter(models.Loan.id == loan_id).first()
    if not loan:
        raise HTTPException(status_code=404, detail="Loan not found")
    
    if loan.status != "pending":
        raise HTTPException(status_code=400, detail="Only pending loans can be rejected")
    
    loan.status = "rejected"
    db.commit()
    return {"message": f"Loan rejected: {reason}"}
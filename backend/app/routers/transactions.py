from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app import models, schemas, auth

router = APIRouter()

@router.post("/", response_model=schemas.TransactionResponse)
def create_transaction(transaction: schemas.TransactionCreate, current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(get_db)):
    # Validate loan_id if provided
    if transaction.loan_id:
        loan = db.query(models.Loan).filter(
            models.Loan.id == transaction.loan_id,
            models.Loan.user_id == current_user.id
        ).first()
        if not loan:
            raise HTTPException(status_code=404, detail="Loan not found")
    
    db_transaction = models.Transaction(
        user_id=current_user.id,
        loan_id=transaction.loan_id,
        transaction_type=transaction.transaction_type,
        amount=transaction.amount,
        description=transaction.description,
        status="completed"
    )
    
    # Update loan outstanding amount if it's a payment
    if transaction.loan_id and transaction.transaction_type == "payment":
        loan = db.query(models.Loan).filter(models.Loan.id == transaction.loan_id).first()
        if loan:
            loan.outstanding_amount = max(0, loan.outstanding_amount - transaction.amount)
            if loan.outstanding_amount == 0:
                loan.status = "closed"
    
    db.add(db_transaction)
    db.commit()
    db.refresh(db_transaction)
    return db_transaction

@router.get("/my-transactions", response_model=List[schemas.TransactionResponse])
def get_my_transactions(current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(get_db)):
    transactions = db.query(models.Transaction).filter(
        models.Transaction.user_id == current_user.id
    ).order_by(models.Transaction.created_at.desc()).all()
    return transactions

@router.get("/loan/{loan_id}", response_model=List[schemas.TransactionResponse])
def get_loan_transactions(loan_id: int, current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(get_db)):
    # Verify loan belongs to current user
    loan = db.query(models.Loan).filter(
        models.Loan.id == loan_id,
        models.Loan.user_id == current_user.id
    ).first()
    
    if not loan:
        raise HTTPException(status_code=404, detail="Loan not found")
    
    transactions = db.query(models.Transaction).filter(
        models.Transaction.loan_id == loan_id
    ).order_by(models.Transaction.created_at.desc()).all()
    return transactions

@router.get("/{transaction_id}", response_model=schemas.TransactionResponse)
def get_transaction(transaction_id: int, current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(get_db)):
    transaction = db.query(models.Transaction).filter(
        models.Transaction.id == transaction_id,
        models.Transaction.user_id == current_user.id
    ).first()
    
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return transaction
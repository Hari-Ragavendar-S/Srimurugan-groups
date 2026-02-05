from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import date, timedelta
from app.database import get_db
from app import models, schemas, auth
from app.services.notification_service import NotificationService

router = APIRouter()

def calculate_emi(principal: float, rate: float, tenure: int) -> float:
    """Calculate EMI using the standard formula"""
    monthly_rate = rate / (12 * 100)
    emi = principal * monthly_rate * (1 + monthly_rate) ** tenure / ((1 + monthly_rate) ** tenure - 1)
    return round(emi, 2)

@router.post("/apply", response_model=schemas.LoanResponse)
def apply_loan(loan: schemas.LoanCreate, current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(get_db)):
    # Calculate EMI
    monthly_emi = calculate_emi(loan.loan_amount, loan.interest_rate, loan.tenure_months)
    
    # Set first due date (30 days from now)
    first_due_date = date.today() + timedelta(days=30)
    
    db_loan = models.Loan(
        user_id=current_user.id,
        loan_amount=loan.loan_amount,
        interest_rate=loan.interest_rate,
        tenure_months=loan.tenure_months,
        monthly_emi=monthly_emi,
        outstanding_amount=loan.loan_amount,
        next_due_date=first_due_date,
        purpose=loan.purpose,
        status="pending"
    )
    db.add(db_loan)
    db.commit()
    db.refresh(db_loan)
    return db_loan

@router.get("/my-loans", response_model=List[schemas.LoanResponse])
def get_my_loans(current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(get_db)):
    loans = db.query(models.Loan).filter(models.Loan.user_id == current_user.id).all()
    return loans

@router.get("/{loan_id}", response_model=schemas.LoanResponse)
def get_loan(loan_id: int, current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(get_db)):
    loan = db.query(models.Loan).filter(
        models.Loan.id == loan_id,
        models.Loan.user_id == current_user.id
    ).first()
    
    if not loan:
        raise HTTPException(status_code=404, detail="Loan not found")
    return loan

@router.put("/{loan_id}/status")
def update_loan_status(loan_id: int, status: str, current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(get_db)):
    # This would typically be an admin-only endpoint
    loan = db.query(models.Loan).filter(models.Loan.id == loan_id).first()
    if not loan:
        raise HTTPException(status_code=404, detail="Loan not found")
    
    valid_statuses = ["pending", "approved", "rejected", "active", "closed"]
    if status not in valid_statuses:
        raise HTTPException(status_code=400, detail="Invalid status")
    
    loan.status = status
    db.commit()
    return {"message": f"Loan status updated to {status}"}

@router.post("/{loan_id}/pay-emi")
def pay_emi(
    loan_id: int,
    amount: float,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    """Pay EMI for a loan"""
    loan = db.query(models.Loan).filter(
        models.Loan.id == loan_id,
        models.Loan.user_id == current_user.id
    ).first()
    
    if not loan:
        raise HTTPException(status_code=404, detail="Loan not found")
    
    if loan.status != "active":
        raise HTTPException(status_code=400, detail="Loan is not active")
    
    # Update loan outstanding amount
    loan.outstanding_amount = max(0, loan.outstanding_amount - amount)
    
    # Create transaction record
    transaction = models.Transaction(
        user_id=current_user.id,
        loan_id=loan_id,
        transaction_type="payment",
        amount=amount,
        description=f"EMI Payment for {loan.purpose}",
        status="completed"
    )
    db.add(transaction)
    
    # Update next due date
    NotificationService.update_next_due_date(db, loan_id)
    
    # Check if loan is fully paid
    if loan.outstanding_amount == 0:
        loan.status = "closed"
        
        # Create completion notification
        notification = models.Notification(
            user_id=current_user.id,
            loan_id=loan_id,
            title="🎉 Loan Completed!",
            message=f"Congratulations! Your {loan.purpose} loan has been fully paid off.",
            notification_type="loan_completed"
        )
        db.add(notification)
    else:
        # Create payment success notification
        notification = models.Notification(
            user_id=current_user.id,
            loan_id=loan_id,
            title="✅ EMI Payment Successful",
            message=f"EMI payment of ₹{amount:,.2f} processed successfully. Outstanding: ₹{loan.outstanding_amount:,.2f}",
            notification_type="payment_success"
        )
        db.add(notification)
    
    db.commit()
    
    return {
        "message": "EMI payment successful",
        "amount_paid": amount,
        "outstanding_amount": loan.outstanding_amount,
        "next_due_date": loan.next_due_date,
        "loan_status": loan.status
    }
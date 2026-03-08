"""Email utilities"""
import smtplib
from email.mime.text import MIMEText
from app.core.config import settings

def send_email(to: str, subject: str, body: str):
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = settings.SMTP_USER
    msg['To'] = to
    
    # TODO: Implement actual sending
    print(f"Email sent to {to}: {subject}")
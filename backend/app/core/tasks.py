"""
Celery background tasks
"""
from celery import Celery
from app.core.config import settings

celery_app = Celery(
    "ai_learning_platform",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL
)

celery_app.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='Asia/Ho_Chi_Minh',
    enable_utc=True,
)


@celery_app.task(name="send_email")
def send_email_task(to: str, subject: str, body: str):
    """Send email in background"""
    # TODO: Implement email sending
    print(f"Sending email to {to}: {subject}")
    return {"status": "sent", "to": to}


@celery_app.task(name="generate_recommendations")
def generate_recommendations_task(student_id: int):
    """Generate AI recommendations for student"""
    # TODO: Implement ML model
    print(f"Generating recommendations for student {student_id}")
    return {"status": "generated", "student_id": student_id}


@celery_app.task(name="process_assignment")
def process_assignment_task(assignment_id: int):
    """Process submitted assignment"""
    print(f"Processing assignment {assignment_id}")
    return {"status": "processed", "assignment_id": assignment_id}
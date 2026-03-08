from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Dict, Any
from datetime import datetime

from app.database import get_db
from app.models import User, QuizResult, Enrollment, Lesson
from app.dependencies import get_current_user
from app.data.quiz_data import QUIZ_DATA

router = APIRouter()

@router.get("/lessons/{lesson_file_name}/quiz")
async def get_quiz_for_lesson(
    lesson_file_name: str,
    current_user: User = Depends(get_current_user)
):
    """
    Get quiz questions for a specific lesson
    """
    if lesson_file_name not in QUIZ_DATA:
        raise HTTPException(status_code=404, detail="Quiz not found for this lesson")
    
    quiz = QUIZ_DATA[lesson_file_name]
    
    # Return quiz without correct answers (only for display)
    questions = []
    for q in quiz["questions"]:
        questions.append({
            "id": q["id"],
            "question": q["question"],
            "options": q["options"]
        })
    
    return {
        "title": quiz["title"],
        "lesson_file": lesson_file_name,
        "questions": questions,
        "total_questions": len(questions)
    }


@router.post("/lessons/{lesson_file_name}/quiz/submit")
async def submit_quiz(
    lesson_file_name: str,
    answers: Dict[int, int],  # question_id -> selected_option_index
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Submit quiz answers and calculate score
    """
    try:
        if lesson_file_name not in QUIZ_DATA:
            raise HTTPException(status_code=404, detail="Quiz not found for this lesson")
        
        quiz = QUIZ_DATA[lesson_file_name]
        
        # Calculate score
        total_questions = len(quiz["questions"])
        correct_count = 0
        results = []
        
        for question in quiz["questions"]:
            question_id = question["id"]
            correct_answer = question["correct_answer"]
            user_answer = answers.get(question_id)
            
            is_correct = user_answer == correct_answer
            if is_correct:
                correct_count += 1
            
            results.append({
                "question_id": question_id,
                "question": question["question"],
                "options": question["options"],
                "user_answer": user_answer,
                "correct_answer": correct_answer,
                "is_correct": is_correct,
                "explanation": question.get("explanation", "")
            })
        
        score = round((correct_count / total_questions) * 100, 2)
        
        # Find the lesson in database
        lesson = db.query(Lesson).filter(
            Lesson.pdf_file_name == lesson_file_name
        ).first()
        
        if not lesson:
            raise HTTPException(status_code=404, detail="Lesson not found in database")
        
        # Save quiz result to database
        quiz_result = QuizResult(
            user_id=current_user.id,
            lesson_id=lesson.id,
            score=score,
            total_questions=total_questions,
            correct_answers=correct_count
        )
        
        db.add(quiz_result)
        db.flush()  # Flush to get the quiz_result ID
        
        # Update enrollment progress
        enrollment = db.query(Enrollment).filter(
            Enrollment.student_id == current_user.id,
            Enrollment.course_id == lesson.course_id
        ).first()
        
        if enrollment:
            # Calculate progress: count completed lessons (lessons with quiz results)
            # Count includes the newly added result
            completed_lessons = db.query(QuizResult).join(Lesson).filter(
                QuizResult.user_id == current_user.id,
                Lesson.course_id == lesson.course_id
            ).count()
            
            total_lessons = db.query(Lesson).filter(
                Lesson.course_id == lesson.course_id,
                Lesson.pdf_file_name.isnot(None)  # Only count lessons with PDF
            ).count()
            
            if total_lessons > 0:
                enrollment.progress = round((completed_lessons / total_lessons) * 100, 2)
            
            # If score >= 70%, mark lesson as completed
            if score >= 70:
                enrollment.completed_lessons = completed_lessons
        
        db.commit()
        
        return {
            "score": score,
            "correct_count": correct_count,
            "total_questions": total_questions,
            "passed": score >= 70,
            "results": results,
            "message": f"You scored {score}%! " + 
                       ("Great job! 🎉" if score >= 90 else
                        "Good work! 👍" if score >= 70 else
                        "Keep practicing! 📚")
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        print(f"Error in submit_quiz: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error submitting quiz: {str(e)}")


@router.get("/quiz-history")
async def get_quiz_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get user's quiz history
    """
    results = db.query(QuizResult).filter(
        QuizResult.user_id == current_user.id
    ).order_by(QuizResult.completed_at.desc()).all()
    
    history = []
    for result in results:
        lesson = db.query(Lesson).filter(Lesson.id == result.lesson_id).first()
        history.append({
            "id": result.id,
            "lesson_id": result.lesson_id,
            "lesson_title": lesson.title if lesson else "Unknown",
            "score": result.score,
            "correct_answers": result.correct_answers,
            "total_questions": result.total_questions,
            "completed_at": result.completed_at.isoformat(),
            "passed": result.score >= 70
        })
    
    return history

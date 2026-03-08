"""
Import Quiz Questions from PDF files in Courses folder
Format: Each quiz PDF contains questions and answers at the end
"""
import sys
import os
import re
sys.path.insert(0, '.')

import fitz  # PyMuPDF
from app.database import SessionLocal
from app.models import Course, Lesson
from app.models.assessment import Assessment, Question, AssessmentType

# Mapping folder names to course codes
COURSE_MAPPING = {
    'NhapMonCNTT': 'IT101',
    'CoSoLapTrinh': 'PR101', 
    'CauTrucDuLieuVaGiaiThuat': 'DSA101',
    'KyThuatLapTrinh': 'PR102',
    'NhapMonMangMayTinhVaDienToanDamMay': 'NET101',
    'CoSoDuLieu': 'DB101',
    'LapTrinhUngDungWeb': 'WEB101',
    'Laptrinhungdungweb': 'WEB101',  # Alternative folder name
    'KiemThuPhanMem': 'TEST101',
    'PhanTichThietKePhanMem': 'SE201',
    'QuanLyDuAnPhanMem': 'PM101',
}

# Base paths
COURSES_PATH = r"D:\KLTN\ai-learning-platform\Courses"

def extract_text_from_pdf(pdf_path):
    """Extract text from PDF file"""
    try:
        doc = fitz.open(pdf_path)
        text = ""
        for page in doc:
            text += page.get_text()
        doc.close()
        return text
    except Exception as e:
        print(f"Error reading {pdf_path}: {e}")
        return ""

def parse_quiz_questions(text):
    """Parse quiz questions and answers from text"""
    questions = []
    
    # Split into questions section and answers section
    parts = re.split(r'ĐÁP ÁN|DAP AN|Đáp án|Answer Key|ANSWER', text, flags=re.IGNORECASE)
    
    if len(parts) < 2:
        print("  Warning: Could not find answer section")
        return questions
    
    questions_text = parts[0]
    answers_text = parts[1]
    
    # Parse answers: "1. B" or "1.B" or "1: B" or just "1 B"
    answer_pattern = r'(\d+)[.\s:]+([A-Da-d])'
    answers = {}
    for match in re.finditer(answer_pattern, answers_text):
        q_num = int(match.group(1))
        answer = match.group(2).upper()
        answers[q_num] = answer
    
    # Try multiple question patterns
    # Pattern 1: "Câu X" format
    question_pattern = r'Câu\s+(\d+)[:\.]?\s*(.*?)(?=Câu\s+\d+|$)'
    matches = list(re.finditer(question_pattern, questions_text, re.DOTALL))
    
    # Pattern 2: "X." format (e.g., "1. Question text")
    if not matches:
        question_pattern = r'(?:^|\n)\s*(\d+)[.\)]\s*(.+?)(?=\n\s*\d+[.\)]|\n\s*Đáp án|\n\s*ĐÁP ÁN|$)'
        matches = list(re.finditer(question_pattern, questions_text, re.DOTALL))
    
    for match in matches:
        q_num = int(match.group(1))
        q_content = match.group(2).strip()
        
        # Extract question text and options
        # Pattern: question text followed by A. B. C. D. options
        option_pattern = r'([A-D])[.\)\s]+(.+?)(?=[A-D][.\)\s]|$)'
        options_matches = list(re.finditer(option_pattern, q_content, re.DOTALL))
        
        if len(options_matches) >= 4:
            # Get question text (everything before first option)
            first_option_pos = q_content.find('A.')
            if first_option_pos == -1:
                first_option_pos = q_content.find('A ')
            if first_option_pos == -1:
                first_option_pos = q_content.find('A)')
            
            if first_option_pos > 0:
                question_text = q_content[:first_option_pos].strip()
            else:
                question_text = q_content.split('\n')[0].strip()
            
            options = {}
            for opt_match in options_matches[:4]:
                opt_letter = opt_match.group(1)
                opt_text = opt_match.group(2).strip().replace('\n', ' ')
                options[opt_letter] = opt_text
            
            correct_answer = answers.get(q_num, 'A')
            
            questions.append({
                'number': q_num,
                'question_text': question_text,
                'options': options,
                'correct_answer': correct_answer
            })
    
    return questions

def import_quizzes_for_course(db, course_code, quiz_folder_path):
    """Import quizzes from a folder for a specific course"""
    course = db.query(Course).filter(Course.course_code == course_code).first()
    if not course:
        print(f"  Course {course_code} not found in database!")
        return 0
    
    print(f"\n{'='*60}")
    print(f"Importing quizzes for: {course_code} - {course.course_name}")
    print(f"From: {quiz_folder_path}")
    print('='*60)
    
    if not os.path.exists(quiz_folder_path):
        print(f"  Folder not found: {quiz_folder_path}")
        return 0
    
    # Delete existing quizzes for this course
    existing_quizzes = db.query(Assessment).filter(
        Assessment.course_id == course.id,
        Assessment.assessment_type == AssessmentType.QUIZ
    ).all()
    
    for quiz in existing_quizzes:
        # Delete questions first
        db.query(Question).filter(Question.assessment_id == quiz.id).delete()
        db.delete(quiz)
    
    db.commit()
    print(f"  Deleted {len(existing_quizzes)} existing quizzes")
    
    # Get all PDF files in quiz folder
    pdf_files = [f for f in os.listdir(quiz_folder_path) if f.lower().endswith('.pdf')]
    pdf_files.sort()
    
    total_questions = 0
    
    for idx, pdf_file in enumerate(pdf_files, 1):
        pdf_path = os.path.join(quiz_folder_path, pdf_file)
        print(f"\n  Processing: {pdf_file}")
        
        # Extract text
        text = extract_text_from_pdf(pdf_path)
        if not text:
            print(f"    No text extracted!")
            continue
        
        # Parse questions
        questions = parse_quiz_questions(text)
        print(f"    Found {len(questions)} questions")
        
        if not questions:
            continue
        
        # Create assessment
        quiz_title = pdf_file.replace('.pdf', '').strip()
        assessment = Assessment(
            course_id=course.id,
            title=quiz_title,
            description=f"Quiz {idx} cho môn {course.course_name}",
            assessment_type=AssessmentType.QUIZ,
            max_score=10.0,
            passing_score=5.0,
            is_published=True,
            max_attempts=3
        )
        db.add(assessment)
        db.flush()
        
        # Add questions
        for q in questions:
            question = Question(
                assessment_id=assessment.id,
                question_text=q['question_text'],
                question_type='multiple_choice',
                option_a=q['options'].get('A', ''),
                option_b=q['options'].get('B', ''),
                option_c=q['options'].get('C', ''),
                option_d=q['options'].get('D', ''),
                correct_answer=q['correct_answer'],
                points=1.0,
                order=q['number']
            )
            db.add(question)
            total_questions += 1
        
        db.commit()
        print(f"    ✅ Created quiz: {quiz_title} with {len(questions)} questions")
    
    return total_questions

def find_quiz_folders():
    """Find all BaiTap folders in Courses directory"""
    quiz_folders = []
    
    for category in os.listdir(COURSES_PATH):
        category_path = os.path.join(COURSES_PATH, category)
        if not os.path.isdir(category_path) or category.startswith('_'):
            continue
        
        for course_folder in os.listdir(category_path):
            course_path = os.path.join(category_path, course_folder)
            if not os.path.isdir(course_path):
                continue
            
            baitap_path = os.path.join(course_path, 'BaiTap')
            if os.path.exists(baitap_path):
                course_code = COURSE_MAPPING.get(course_folder)
                if course_code:
                    quiz_folders.append({
                        'folder_name': course_folder,
                        'course_code': course_code,
                        'quiz_path': baitap_path
                    })
                else:
                    print(f"Warning: No mapping for folder '{course_folder}'")
    
    return quiz_folders

def main():
    print("=" * 60)
    print("IMPORTING QUIZ QUESTIONS FROM COURSES FOLDER")
    print("=" * 60)
    
    db = SessionLocal()
    
    # Find all quiz folders
    quiz_folders = find_quiz_folders()
    print(f"\nFound {len(quiz_folders)} courses with quiz folders:")
    for qf in quiz_folders:
        print(f"  - {qf['folder_name']} -> {qf['course_code']}")
    
    # Import quizzes
    total = 0
    for qf in quiz_folders:
        count = import_quizzes_for_course(db, qf['course_code'], qf['quiz_path'])
        total += count
    
    db.close()
    
    print("\n" + "=" * 60)
    print(f"✅ IMPORT COMPLETE! Total questions imported: {total}")
    print("=" * 60)

if __name__ == "__main__":
    main()

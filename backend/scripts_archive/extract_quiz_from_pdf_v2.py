#!/usr/bin/env python3
"""
Extract quiz questions from PDF files and generate quiz_data.py
"""

import PyPDF2
import re
import os

# Mapping from quiz PDF filename to lecture PDF filename
FILE_MAPPING = {
    "Quiz_Lecture_00_Course_Introduction.pdf": "Lecture 00 - Course Introduction.pdf",
    "Quiz_Lecture_01_HTML_CSS_JavaScript.pdf": "Lecture 01 - HTMLJavaScript.pdf",
    "Quiz_Lecture_02_Getting_Started_with_React.pdf": "Lecture 02 - Getting Started with React.pdf",
    "Quiz_Lecture_03_React_Components.pdf": "Lecture 03 - React Components.pdf",
    "Quiz_Lecture_04_Handling_Interactions.pdf": "Lecture 04 - Handling Interactions in React.pdf",
    "Quiz_Lecture_05_Building_React_Applications.pdf": "Lecture 05 - Building Real-World Applications with React.pdf",
    "Quiz_Lecture_06_Redux_Fundamentals.pdf": "Lecture 06 - Redux Fundamentals.pdf",
    "Quiz_Lecture_07_Angular_Reactive_Forms.pdf": "Lecture 07 - Angular Reactive Forms.pdf",
}

QUIZ_PDF_DIR = r"D:\KLTN\ai-learning-platform\Courses\CNPM\QuizzLaptrinhungdungweb"
OUTPUT_FILE = r"D:\KLTN\ai-learning-platform\backend\app\data\quiz_data.py"

def extract_text_from_pdf(pdf_path):
    """Extract all text from PDF file"""
    try:
        with open(pdf_path, 'rb') as file:
            pdf_reader = PyPDF2.PdfReader(file)
            text = ""
            for page in pdf_reader.pages:
                text += page.extract_text() + "\n"
            return text
    except Exception as e:
        print(f"  Error reading PDF: {e}")
        return ""

def parse_quiz_from_text(text):
    """
    Parse quiz from text extracted from PDF
    Format:
      Quiz – Lecture XX: Title
      1. Question text?
      A. Option A
      B. Option B
      C. Option C
      D. Option D
      ...
      Đáp án
      1. B
      2. C
      ...
    """
    # Extract title
    title_match = re.search(r'Quiz[:\s–-]*(.+?)(?=\n)', text, re.IGNORECASE)
    title = title_match.group(1).strip() if title_match else "Quiz"
    
    # Split into questions part and answers part
    parts = re.split(r'\n\s*Đáp án\s*\n', text, flags=re.IGNORECASE)
    questions_text = parts[0] if parts else text
    answers_text = parts[1] if len(parts) > 1 else ""
    
    # Parse answers section
    answers_dict = {}
    if answers_text:
        for line in answers_text.strip().split('\n'):
            line = line.strip()
            # Match "1. B", "1.B", "1B"
            match = re.match(r'(\d+)[\.\s]*([A-D])', line, re.IGNORECASE)
            if match:
                q_num = int(match.group(1))
                answer_letter = match.group(2).upper()
                answers_dict[q_num] = ord(answer_letter) - ord('A')
    
    # Split by question numbers
    question_blocks = re.split(r'\n\s*(\d+)\.\s+', questions_text)
    
    # Remove text before first question
    if question_blocks and not question_blocks[0].strip().startswith('Quiz'):
        pass  # Keep it for title extraction
    
    questions = []
    
    # Process in pairs (number, content)
    i = 1  # Start from first number
    while i < len(question_blocks):
        if i + 1 >= len(question_blocks):
            break
        
        try:
            question_num = int(question_blocks[i])
        except ValueError:
            i += 1
            continue
            
        question_content = question_blocks[i + 1].strip()
        
        # Split into lines
        lines = question_content.split('\n')
        
        # Extract question (first line before options)
        question = ""
        options = []
        current_option = None
        current_option_letter = None
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
            
            # Check if line starts with A., B., C., D.
            option_match = re.match(r'^([A-D])[\.\)]\s*(.+)', line, re.IGNORECASE)
            
            if option_match:
                # Save previous option
                if current_option is not None:
                    options.append(current_option)
                
                # Start new option
                current_option_letter = option_match.group(1).upper()
                current_option = option_match.group(2).strip()
            elif current_option is not None:
                # Continue multi-line option
                current_option += " " + line
            else:
                # This is part of the question
                if question:
                    question += " " + line
                else:
                    question = line
        
        # Add last option
        if current_option is not None:
            options.append(current_option)
        
        # Validate
        if not question or len(options) != 4:
            print(f"  Warning: Question {question_num} - invalid format (question: '{question[:30]}...', options: {len(options)})")
            i += 2
            continue
        
        # Get correct answer
        correct_answer = answers_dict.get(question_num, 0)
        
        questions.append({
            "id": question_num,
            "question": question,
            "options": options,
            "correct_answer": correct_answer,
            "explanation": f"Đáp án đúng là {chr(ord('A') + correct_answer)}"
        })
        
        i += 2
    
    return {
        "title": title,
        "questions": questions
    }

def generate_quiz_data_file(all_quizzes):
    """Generate the quiz_data.py file"""
    content = '''"""
Quiz questions for all lectures
Auto-generated from PDF files
"""

QUIZ_DATA = {
'''
    
    for lecture_filename, quiz_data in all_quizzes.items():
        content += f'    "{lecture_filename}": {{\n'
        content += f'        "title": "{quiz_data["title"]}",\n'
        content += f'        "questions": [\n'
        
        for q in quiz_data["questions"]:
            content += '            {\n'
            content += f'                "id": {q["id"]},\n'
            content += f'                "question": """{q["question"]}""",\n'
            content += f'                "options": [\n'
            for opt in q["options"]:
                content += f'                    """{opt}""",\n'
            content += f'                ],\n'
            content += f'                "correct_answer": {q["correct_answer"]},\n'
            content += f'                "explanation": """{q["explanation"]}"""\n'
            content += '            },\n'
        
        content += '        ]\n'
        content += '    },\n'
    
    content += '}\n'
    
    return content

def main():
    print("Extracting quiz data from PDF files...\n")
    
    all_quizzes = {}
    
    for quiz_filename, lecture_filename in FILE_MAPPING.items():
        print(f"Processing: {quiz_filename}")
        
        # Read PDF
        pdf_path = os.path.join(QUIZ_PDF_DIR, quiz_filename)
        if not os.path.exists(pdf_path):
            print(f"  ✗ File not found: {pdf_path}")
            continue
        
        # Extract text
        text = extract_text_from_pdf(pdf_path)
        if not text:
            print(f"  ✗ Could not extract text")
            continue
        
        # Parse quiz
        quiz_data = parse_quiz_from_text(text)
        
        if quiz_data["questions"]:
            all_quizzes[lecture_filename] = quiz_data
            print(f"  ✓ Extracted {len(quiz_data['questions'])} questions")
        else:
            print(f"  ✗ No questions found")
    
    # Generate output file
    if all_quizzes:
        print(f"\nGenerating {OUTPUT_FILE}...")
        content = generate_quiz_data_file(all_quizzes)
        
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✓ Generated {OUTPUT_FILE} with {len(all_quizzes)} quizzes")
        
        # Summary
        print("\nSummary:")
        total_questions = sum(len(q["questions"]) for q in all_quizzes.values())
        print(f"  Total quizzes: {len(all_quizzes)}")
        print(f"  Total questions: {total_questions}")
    else:
        print("\n✗ No quiz data extracted")

if __name__ == "__main__":
    main()

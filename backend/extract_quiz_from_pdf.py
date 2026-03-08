# Script to extract quiz data from PDF files and convert to Python dictionary
import PyPDF2
import os
import json
import re

QUIZ_DIR = r"D:\KLTN\ai-learning-platform\Courses\CNPM\QuizzLaptrinhungdungweb"
OUTPUT_FILE = r"D:\KLTN\ai-learning-platform\backend\app\data\quiz_data.py"

# Mapping PDF files to lecture PDF names
FILE_MAPPING = {
    "Quiz_Lecture_00_Course_Introduction.pdf": "Lecture 00 - Course Introduction.pdf",
    "Quiz_Lecture_01_HTML_CSS_JavaScript.pdf": "Lecture 01 - HTMLJavaScript.pdf",
    "Quiz_Lecture_02_Getting_Started_with_React.pdf": "Lecture 02 - React.pdf",
    "Quiz_Lecture_03_React_Components.pdf": "Lecture 03 - React Components and Props.pdf",
    "Quiz_Lecture_04_Handling_Interactions.pdf": "Lecture 04 - React Interaction.pdf",
    "Quiz_Lecture_05_Building_React_Applications.pdf": "Lecture 05 - React Application.pdf",
    "Quiz_Lecture_06_Redux_Fundamentals.pdf": "Lecture 06 - Redux.pdf",
    "Quiz_Lecture_07_Angular_Reactive_Forms.pdf": "Lecture 07 - Angular.pdf"
}

def extract_text_from_pdf(pdf_path):
    """Extract text from PDF file"""
    try:
        with open(pdf_path, 'rb') as file:
            pdf_reader = PyPDF2.PdfReader(file)
            text = ""
            for page in pdf_reader.pages:
                text += page.extract_text()
            return text
    except Exception as e:
        print(f"Error reading {pdf_path}: {e}")
        return ""

def parse_quiz_from_text(text, quiz_file_name):
    """Parse quiz questions from extracted text"""
    questions = []
    
    # Try to extract title
    title_match = re.search(r'Quiz[:\s]*(.+?)(?:\n|$)', text, re.IGNORECASE)
    title = title_match.group(1).strip() if title_match else f"Quiz: {quiz_file_name.replace('Quiz_', '').replace('_', ' ').replace('.pdf', '')}"
    
    # Split by question numbers (assumes format like "Câu 1:", "Question 1:", "1.", etc.)
    question_blocks = re.split(r'\n\s*(?:Câu|Question|Câu hỏi)\s*(\d+)[:\.]?\s*', text, flags=re.IGNORECASE)
    
    # Process each question block
    for i in range(1, len(question_blocks), 2):
        if i+1 >= len(question_blocks):
            break
            
        question_num = int(question_blocks[i])
        question_text_block = question_blocks[i+1]
        
        # Extract question text (before options)
        option_match = re.search(r'(?:A[\.\)]|a[\.\)]|\nA\s)', question_text_block)
        if option_match:
            question_text = question_text_block[:option_match.start()].strip()
            options_text = question_text_block[option_match.start():]
        else:
            question_text = question_text_block.strip()
            options_text = ""
        
        # Extract options (A, B, C, D or a, b, c, d)
        options = []
        option_pattern = r'[A-Da-d][\.\)]\s*(.+?)(?=\n[A-Da-d][\.\)]|\n\n|Đáp án|Answer|Giải thích|Explanation|$)'
        option_matches = re.findall(option_pattern, options_text, re.DOTALL | re.IGNORECASE)
        
        for opt_text in option_matches:
            options.append(opt_text.strip())
        
        # Extract correct answer
        correct_answer = 0
        answer_match = re.search(r'(?:Đáp án đúng|Correct answer|Answer)[:\s]*([A-Da-d])', question_text_block, re.IGNORECASE)
        if answer_match:
            answer_letter = answer_match.group(1).upper()
            correct_answer = ord(answer_letter) - ord('A')
        
        # Extract explanation
        explanation = ""
        exp_match = re.search(r'(?:Giải thích|Explanation)[:\s]*(.+?)(?=\n\n|Câu|Question|$)', question_text_block, re.DOTALL | re.IGNORECASE)
        if exp_match:
            explanation = exp_match.group(1).strip()
        
        # Only add if we have valid question and options
        if question_text and len(options) >= 2:
            questions.append({
                "id": question_num,
                "question": question_text,
                "options": options,
                "correct_answer": correct_answer,
                "explanation": explanation if explanation else f"Đáp án đúng là {chr(correct_answer + ord('A'))}"
            })
    
    return {
        "title": title,
        "questions": questions
    }

def generate_quiz_data_file():
    """Generate quiz_data.py from PDF files"""
    quiz_data = {}
    
    print("Extracting quiz data from PDF files...")
    
    for quiz_file, lecture_file in FILE_MAPPING.items():
        pdf_path = os.path.join(QUIZ_DIR, quiz_file)
        
        if not os.path.exists(pdf_path):
            print(f"Warning: {quiz_file} not found, skipping...")
            continue
        
        print(f"\nProcessing: {quiz_file}")
        text = extract_text_from_pdf(pdf_path)
        
        if text:
            quiz = parse_quiz_from_text(text, quiz_file)
            if quiz["questions"]:
                quiz_data[lecture_file] = quiz
                print(f"  ✓ Extracted {len(quiz['questions'])} questions")
            else:
                print(f"  ✗ No questions found")
        else:
            print(f"  ✗ Could not extract text")
    
    # Generate Python file
    print(f"\nGenerating {OUTPUT_FILE}...")
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write("# Quiz data for Web Development course\n")
        f.write("# Extracted from PDF files\n\n")
        f.write("QUIZ_DATA = {\n")
        
        for lecture_file, quiz in quiz_data.items():
            f.write(f'    "{lecture_file}": {{\n')
            f.write(f'        "title": "{quiz["title"]}",\n')
            f.write('        "questions": [\n')
            
            for q in quiz["questions"]:
                f.write('            {\n')
                f.write(f'                "id": {q["id"]},\n')
                f.write(f'                "question": """{q["question"]}""",\n')
                f.write('                "options": [\n')
                for opt in q["options"]:
                    f.write(f'                    """{opt}""",\n')
                f.write('                ],\n')
                f.write(f'                "correct_answer": {q["correct_answer"]},\n')
                f.write(f'                "explanation": """{q["explanation"]}"""\n')
                f.write('            },\n')
            
            f.write('        ]\n')
            f.write('    },\n')
        
        f.write('}\n')
    
    print(f"\n✓ Generated {OUTPUT_FILE} with {len(quiz_data)} quizzes")
    
    # Print summary
    print("\nSummary:")
    for lecture_file, quiz in quiz_data.items():
        print(f"  - {lecture_file}: {len(quiz['questions'])} questions")

if __name__ == "__main__":
    # Check if PyPDF2 is installed
    try:
        import PyPDF2
        generate_quiz_data_file()
    except ImportError:
        print("Error: PyPDF2 not installed")
        print("Please install it with: pip install PyPDF2")

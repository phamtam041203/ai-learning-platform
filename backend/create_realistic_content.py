#!/usr/bin/env python
"""Create realistic lessons and quizzes with real content"""

from app.database import SessionLocal
from app.models import Course, Lesson, Assessment, Question, AssessmentType

db = SessionLocal()

# Realistic content - mapped to actual courses
CONTENT = {
    "Web Development với React": {
        "lessons": [
            {
                "title": "React Fundamentals",
                "content": """# React Fundamentals

## What is React?
React is a JavaScript library for building user interfaces with reusable components.

## Key Concepts:
- **Components**: Reusable UI building blocks
- **JSX**: JavaScript syntax extension for writing HTML-like code
- **Props**: Pass data from parent to child components
- **State**: Manage component internal data
- **Hooks**: Functions to use state and other React features

## Basic Component Example:
```jsx
function Welcome(props) {
  return <h1>Hello, {props.name}!</h1>;
}
```

## JSX Rules:
- Return a single element (wrap in div or fragment)
- Close all tags properly
- Use className instead of class
- Use camelCase for attributes (onClick, onChange)"""
            },
            {
                "title": "React Hooks",
                "content": """# React Hooks

## useState Hook
Manages state in functional components:
```jsx
const [count, setCount] = useState(0);
```

## useEffect Hook
Performs side effects:
```jsx
useEffect(() => {
  // Code runs after render
  return () => {
    // Cleanup function
  };
}, [dependency]); // Run when dependency changes
```

## useContext Hook
Access context without nesting:
```jsx
const theme = useContext(ThemeContext);
```

## Custom Hooks
Create reusable logic:
```jsx
function useFetch(url) {
  const [data, setData] = useState(null);
  
  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(data => setData(data));
  }, [url]);
  
  return data;
}
```"""
            }
        ],
        "questions": [
            {"q": "What is React?", "opts": ["A library for building UI", "A server", "A database", "An OS"], "ans": 0},
            {"q": "What are React components?", "opts": ["Reusable UI blocks", "Server code", "Database tables", "HTML tags"], "ans": 0},
            {"q": "What does useState do?", "opts": ["Makes HTTP requests", "Manages component state", "Renders HTML", "Connects to database"], "ans": 1},
            {"q": "What is JSX?", "opts": ["JavaScript SQL", "JavaScript XML", "Java extension", "JSON extension"], "ans": 1},
            {"q": "How do you pass data to a component?", "opts": ["Using props", "Using state", "Using constants", "Using classes"], "ans": 0},
        ]
    },
    "Backend Development với Python/FastAPI": {
        "lessons": [
            {
                "title": "FastAPI Basics",
                "content": """# FastAPI Framework

## What is FastAPI?
FastAPI is a modern web framework for building APIs with Python.

## Key Features:
- **Fast**: Very high performance
- **Automatic API documentation**: Swagger UI and ReDoc
- **Type hints**: Better code quality with Python type hints
- **Async/await**: Built-in support for async operations
- **Dependency Injection**: Easy dependency management

## Basic Example:
```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/items/{item_id}")
def read_item(item_id: int):
    return {"item_id": item_id}
```

## Running:
```bash
uvicorn main:app --reload
```

API Docs will be available at `/docs`"""
            },
            {
                "title": "Database with SQLAlchemy",
                "content": """# SQLAlchemy ORM

## What is ORM?
Object-Relational Mapping - maps Python classes to database tables.

## Define Models:
```python
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True)
    name = Column(String(50))
    email = Column(String(100))
```

## Create Database Connection:
```python
from sqlalchemy import create_engine

engine = create_engine("postgresql://user:pass@localhost/dbname")
Base.metadata.create_all(engine)

SessionLocal = sessionmaker(bind=engine)
```

## CRUD Operations:
```python
# Create
user = User(name="An", email="an@example.com")
db.add(user)
db.commit()

# Read
user = db.query(User).filter(User.id == 1).first()

# Update
user.name = "New Name"
db.commit()

# Delete
db.delete(user)
db.commit()
```"""
            }
        ],
        "questions": [
            {"q": "What is FastAPI?", "opts": ["Web framework", "Database", "Frontend tool", "OS"], "ans": 0},
            {"q": "What does ORM stand for?", "opts": ["Object Remote Management", "Object-Relational Mapping", "Online Resource Manager", "Operating Remote Memory"], "ans": 1},
            {"q": "How do you run FastAPI?", "opts": ["python app.py", "uvicorn main:app", "npm start", "java app.jar"], "ans": 1},
            {"q": "What does @app.get() do?", "opts": ["Creates POST endpoint", "Creates GET endpoint", "Defines a variable", "Imports a module"], "ans": 1},
            {"q": "How to query database in SQLAlchemy?", "opts": ["db.query(Model)", "db.select(Model)", "db.find(Model)", "db.get(Model)"], "ans": 0},
        ]
    },
    "Database Design & SQL": {
        "lessons": [
            {
                "title": "Database Design",
                "content": """# Database Design

## Relational Database Concepts
- **Table**: Collection of related records
- **Record**: A row in a table
- **Field**: A column in a table
- **Primary Key**: Uniquely identifies each record
- **Foreign Key**: Links to another table's primary key

## Normalization
Process to organize data efficiently:

**First Normal Form (1NF)**
- Each column has atomic values
- No repeating groups

**Second Normal Form (2NF)**
- In 1NF
- Non-key attributes depend on entire primary key

**Third Normal Form (3NF)**
- In 2NF
- Non-key attributes depend only on primary key

## Database Design Example:
```
users table:
- id (PK)
- name
- email

orders table:
- id (PK)
- user_id (FK to users)
- order_date
- total_amount
```"""
            },
            {
                "title": "SQL Queries",
                "content": """# SQL Queries

## SELECT Statements
```sql
-- Get all records
SELECT * FROM users;

-- Get specific columns
SELECT id, name FROM users;

-- With WHERE clause
SELECT * FROM users WHERE age > 18;

-- LIKE pattern matching
SELECT * FROM users WHERE name LIKE 'A%';

-- ORDER BY
SELECT * FROM users ORDER BY name ASC;

-- LIMIT
SELECT * FROM users LIMIT 10;
```

## JOIN Operations
```sql
-- INNER JOIN - get matching records from both tables
SELECT u.name, o.order_date
FROM users u
INNER JOIN orders o ON u.id = o.user_id;

-- LEFT JOIN - all from left table + matching from right
SELECT u.name, o.order_date
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

-- RIGHT JOIN - all from right table + matching from left
SELECT u.name, o.order_date
FROM users u
RIGHT JOIN orders o ON u.id = o.user_id;
```

## Aggregate Functions
```sql
-- Count
SELECT COUNT(*) FROM users;

-- Sum, Average, Max, Min
SELECT AVG(age) FROM users;
SELECT MAX(salary) FROM employees;

-- GROUP BY
SELECT department, AVG(salary)
FROM employees
GROUP BY department;
```

## INSERT, UPDATE, DELETE
```sql
-- Insert
INSERT INTO users (name, email) VALUES ('An', 'an@example.com');

-- Update
UPDATE users SET age = 21 WHERE id = 1;

-- Delete
DELETE FROM users WHERE id = 1;
```"""
            }
        ],
        "questions": [
            {"q": "What does PRIMARY KEY do?", "opts": ["Stores encrypted data", "Uniquely identifies records", "Creates indexes", "Links tables"], "ans": 1},
            {"q": "What is normalization?", "opts": ["Backing up data", "Organizing data efficiently", "Encrypting data", "Compressing data"], "ans": 1},
            {"q": "What JOIN returns all from left table?", "opts": ["INNER JOIN", "RIGHT JOIN", "LEFT JOIN", "OUTER JOIN"], "ans": 2},
            {"q": "Which aggregates rows together?", "opts": ["SELECT", "WHERE", "GROUP BY", "ORDER BY"], "ans": 2},
            {"q": "How to get first 5 records?", "opts": ["SELECT TOP 5", "SELECT LIMIT 5", "SELECT * LIMIT 5;", "SELECT COUNT 5"], "ans": 2},
        ]
    }
}

def create_content():
    """Create lessons and quizzes for courses"""
    try:
        for course_name, data in CONTENT.items():
            # Find course
            course = db.query(Course).filter(
                Course.course_name == course_name
            ).first()
            
            if not course:
                print(f"⏭️  Course '{course_name}' not found, skipping...")
                continue
            
            # Check if lessons already exist
            existing = db.query(Lesson).filter(Lesson.course_id == course.id).count()
            if existing > 0:
                print(f"✅ '{course_name}' already has {existing} lessons")
                continue
            
            print(f"\n📚 Creating content for '{course_name}'...")
            
            # Create lessons
            for i, lesson_data in enumerate(data["lessons"]):
                lesson = Lesson(
                    course_id=course.id,
                    title=lesson_data["title"],
                    content=lesson_data["content"],
                    order=i + 1
                )
                db.add(lesson)
                print(f"  ✓ Lesson: {lesson_data['title']}")
            
            db.flush()
            
            # Create assessment
            assessment = Assessment(
                course_id=course.id,
                title=f"Quiz: {course_name}",
                description=f"Test your knowledge of {course_name}",
                assessment_type=AssessmentType.QUIZ,
                passing_score=60,
                max_score=100
            )
            db.add(assessment)
            db.flush()
            
            # Create questions
            for i, q_data in enumerate(data["questions"]):
                question = Question(
                    assessment_id=assessment.id,
                    question_text=q_data["q"],
                    question_type="multiple_choice",
                    option_a=q_data["opts"][0],
                    option_b=q_data["opts"][1],
                    option_c=q_data["opts"][2],
                    option_d=q_data["opts"][3],
                    correct_answer=chr(97 + q_data["ans"]),  # a, b, c, d
                    points=1.0,
                    order=i + 1
                )
                db.add(question)
            
            db.commit()
            print(f"  ✓ Quiz with {len(data['questions'])} questions")
        
        print("\n✅ All realistic content created successfully!")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    print("=" * 60)
    print("📚 Creating Realistic Lessons & Quizzes")
    print("=" * 60)
    create_content()

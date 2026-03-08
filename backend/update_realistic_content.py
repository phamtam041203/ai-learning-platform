#!/usr/bin/env python
"""Replace generic content with detailed, realistic lessons and quizzes"""

from app.database import SessionLocal
from app.models import Course, Lesson, Assessment, Question, AssessmentType

db = SessionLocal()

# Comprehensive realistic content for all courses
REALISTIC_CONTENT = {
    "Nhập môn lập trình": {
        "lessons": [
            ("Lập Trình Là Gì", """# Lập Trình Là Gì?

## Định Nghĩa
Lập trình (Programming) là quá trình viết các hướng dẫn (code) cho máy tính để thực hiện những công việc cụ thể. Những hướng dẫn này được viết bằng các ngôn ngữ lập trình.

## Ngôn Ngữ Lập Trình Phổ Biến
- **Python**: Dễ học, dùng cho AI/ML, web scraping
- **Java**: Mạnh mẽ, dùng cho ứng dụng doanh nghiệp
- **JavaScript**: Lập trình web (frontend)
- **C++**: Hiệu suất cao, lập trình hệ thống
- **C#**: Phát triển với .NET framework

## Tại Sao Học Lập Trình?
1. **Lương cao**: Lập trình viên có mức lương cạnh tranh cao (15-50 triệu/tháng)
2. **Nhu cầu cao**: Mỗi công ty hiện đại đều cần lập trình viên
3. **Nhiều cơ hội**: Có thể làm việc tại startup, tập đoàn lớn, hoặc freelance
4. **Sáng tạo**: Bạn có thể tạo ra những ứng dụng hữu ích thay đổi cuộc sống con người
5. **Linh hoạt**: Có thể làm việc từ xa (remote)"""),
            
            ("Biến và Kiểu Dữ Liệu", """# Biến và Kiểu Dữ Liệu

## Biến (Variables)
Biến là một vùng bộ nhớ dùng để lưu trữ dữ liệu. Giống như một hộp để bạn bỏ đồ vào.

```python
x = 10              # Biến x chứa giá trị 10
name = "Nguyễn Văn A"  # Biến name chứa một chuỗi
```

## Kiểu Dữ Liệu (Data Types)

### 1. Integer (Số Nguyên)
```python
age = 20
year = 2024
temperature = -5
```

### 2. Float (Số Thực)
```python
price = 19.99
pi = 3.14159
height = 1.75
```

### 3. String (Chuỗi Ký Tự)
```python
greeting = "Xin chào"
email = "student@vanlang.edu.vn"
```

### 4. Boolean (Logic)
```python
is_student = True
is_graduated = False
```

### 5. List (Danh Sách)
```python
fruits = ["táo", "cam", "chuối"]
numbers = [1, 2, 3, 4, 5]
mixed = [1, "hello", 3.14, True]
```

### 6. Dictionary (Từ Điển)
```python
student = {
    "name": "Nguyễn Văn A",
    "age": 20,
    "email": "a@vanlang.edu.vn"
}
```

## Đặt Tên Biến
- Bắt đầu bằng chữ cái hoặc dấu gạch dưới (_)
- Không chứa khoảng trắng
- Phân biệt chữ hoa chữ thường
- Tránh sử dụng các từ khóa của Python"""),
            
            ("Toán Tử và Phép Tính", """# Toán Tử và Phép Tính

## Toán Tử Số Học (Arithmetic Operators)
```python
a = 10
b = 3

print(a + b)   # Cộng: 13
print(a - b)   # Trừ: 7
print(a * b)   # Nhân: 30
print(a / b)   # Chia: 3.33...
print(a // b)  # Chia lấy phần nguyên: 3
print(a % b)   # Chia lấy dư: 1
print(a ** b)  # Lũy thừa: 1000
```

## Toán Tử So Sánh (Comparison Operators)
```python
x = 5
y = 8

print(x == y)   # Bằng: False
print(x != y)   # Khác: True
print(x < y)    # Nhỏ hơn: True
print(x > y)    # Lớn hơn: False
print(x <= y)   # Nhỏ hơn hoặc bằng: True
print(x >= y)   # Lớn hơn hoặc bằng: False
```

## Toán Tử Logic (Logical Operators)
```python
age = 20
has_id = True

# AND - cả hai điều kiện đúng
if age >= 18 and has_id:
    print("Có thể vào quán")

# OR - ít nhất một điều kiện đúng
if age < 18 or has_id:
    print("Cảnh báo")

# NOT - phủ định
if not age < 18:
    print("Bạn đã trưởng thành")
```

## Ưu Tiên Toán Tử (Operator Precedence)
1. Lũy thừa (**)
2. Nhân, Chia, Chia lấy phần nguyên, Chia lấy dư
3. Cộng, Trừ

Ví dụ: `2 + 3 * 4 = 14` (không phải 20) vì nhân được ưu tiên"""),
            
            ("Câu Lệnh Điều Kiện (If-Else)", """# Câu Lệnh Điều Kiện

## If Statement
```python
age = 18

if age >= 18:
    print("Bạn đã trưởng thành")
```

## If-Else Statement
```python
score = 5.0

if score >= 5.0:
    print("Bạn vượt qua môn học")
else:
    print("Bạn cần học thêm")
```

## If-Elif-Else Statement
```python
score = 7.5

if score >= 8.0:
    print("Điểm A")
elif score >= 7.0:
    print("Điểm B")
elif score >= 6.0:
    print("Điểm C")
else:
    print("Điểm F")
```

## Nested If (Lồng nhau)
```python
age = 20
has_license = True

if age >= 18:
    if has_license:
        print("Có thể lái xe")
    else:
        print("Cần bằng lái")
else:
    print("Chưa đủ tuổi")
```

## Lưu Ý
- Sử dụng indentation (thụt lề) để chỉ khối code
- Python sử dụng `:` để kết thúc điều kiện"""),
            
            ("Vòng Lặp (Loops)", """# Vòng Lặp (Loops)

## For Loop
Vòng lặp for dùng khi biết số lần lặp trước.

```python
# Lặp từ 0 đến 4
for i in range(5):
    print(i)  # In: 0, 1, 2, 3, 4

# Lặp qua danh sách
fruits = ["táo", "cam", "chuối"]
for fruit in fruits:
    print(fruit)

# Lặp với bước nhảy
for i in range(0, 10, 2):
    print(i)  # In: 0, 2, 4, 6, 8
```

## While Loop
Vòng lặp while lặp miễn là điều kiện đúng.

```python
count = 0
while count < 5:
    print(count)
    count += 1  # Tăng count thêm 1

# Output: 0, 1, 2, 3, 4
```

## Break và Continue
```python
# Break - thoát khỏi vòng lặp
for i in range(10):
    if i == 5:
        break
    print(i)  # In: 0, 1, 2, 3, 4

# Continue - bỏ qua lần lặp hiện tại
for i in range(5):
    if i == 2:
        continue
    print(i)  # In: 0, 1, 3, 4
```

## Nested Loops
```python
for i in range(3):
    for j in range(3):
        print(f"({i}, {j})")
```""")
        ],
        "questions": [
            ("Lập trình là gì?", ["Viết hướng dẫn cho máy tính", "Sửa chữa máy tính", "Bán máy tính", "Chơi game"], 0),
            ("Python dùng cho mục đích nào chủ yếu?", ["Desktop", "AI/ML, Web scraping", "Chỉ game", "Không dùng được"], 1),
            ("Kiểu dữ liệu nào dùng để lưu số thực?", ["Integer", "String", "Float", "Boolean"], 2),
            ("Cách gán giá trị cho biến:", ["x == 10", "x = 10", "x := 10", "10 = x"], 1),
            ("Toán tử nào kiểm tra bằng?", ["!=", "==", "=>", "<="], 1),
        ]
    },
    
    "Cấu trúc dữ liệu và giải thuật": {
        "lessons": [
            ("Array và List", """# Array và List

## Array
Array là một tập hợp các phần tử cùng kiểu dữ liệu, sắp xếp liên tiếp trong bộ nhớ.

```
Array Index:  0  1  2  3  4
Values:      10 20 30 40 50
Memory:     [10][20][30][40][50]
```

## List trong Python
```python
numbers = [10, 20, 30, 40, 50]

# Truy cập phần tử
print(numbers[0])   # 10
print(numbers[2])   # 30
print(numbers[-1])  # 50 (phần tử cuối)

# Thêm phần tử
numbers.append(60)

# Xóa phần tử
numbers.remove(30)

# Lấy độ dài
len(numbers)

# Cắt list
numbers[1:3]  # [20, 30]
```

## Ưu và Nhược Điểm
**Ưu điểm:**
- Truy cập nhanh O(1) theo chỉ số
- Sử dụng bộ nhớ liên tiếp

**Nhược điểm:**
- Kích thước cố định (trong Array)
- Chèn/xóa chậm O(n)"""),
            
            ("Stack - LIFO", """# Stack (Ngăn Xếp)

## Stack là gì?
Stack hoạt động theo nguyên tắc LIFO (Last In First Out) - phần tử vào sau xóa trước.

Giống như xếp chồng đĩa:
```
Push 1: [1]
Push 2: [1,2]
Push 3: [1,2,3]
Pop:    [1,2] - lấy 3 ra
```

## Các Thao Tác Chính
```python
class Stack:
    def __init__(self):
        self.items = []
    
    def push(self, item):
        """Thêm phần tử vào đầu"""
        self.items.append(item)
    
    def pop(self):
        """Lấy phần tử từ đầu"""
        return self.items.pop()
    
    def peek(self):
        """Xem phần tử đầu mà không lấy"""
        return self.items[-1]
    
    def is_empty(self):
        """Kiểm tra stack rỗng"""
        return len(self.items) == 0

# Sử dụng
stack = Stack()
stack.push(10)
stack.push(20)
print(stack.pop())  # 20
```

## Ứng Dụng Thực Tế
- Lịch sử duyệt web (Back button)
- Undo/Redo trong editor
- Kiểm tra ngoặc cân bằng
- DFS (Depth First Search) trong đồ thị"""),
            
            ("Queue - FIFO", """# Queue (Hàng Chờ)

## Queue là gì?
Queue hoạt động theo nguyên tắc FIFO (First In First Out) - phần tử vào trước xóa trước.

Giống như hàng chờ mua vé:
```
Enqueue A: [A]
Enqueue B: [A,B]
Enqueue C: [A,B,C]
Dequeue:   [B,C] - A ra trước
```

## Các Thao Tác Chính
```python
from collections import deque

class Queue:
    def __init__(self):
        self.items = deque()
    
    def enqueue(self, item):
        """Thêm vào cuối"""
        self.items.append(item)
    
    def dequeue(self):
        """Lấy từ đầu"""
        return self.items.popleft()
    
    def is_empty(self):
        return len(self.items) == 0

# Sử dụng
queue = Queue()
queue.enqueue(10)
queue.enqueue(20)
print(queue.dequeue())  # 10
```

## Ứng Dụng Thực Tế
- Xếp hàng in (Print queue)
- Xử lý yêu cầu trên server
- BFS (Breadth First Search)
- Làm mịn hình ảnh
- Trò chơi lập lịch tác vụ"""),
            
            ("Sorting Algorithms", """# Các Thuật Toán Sắp Xếp

## Bubble Sort
Độ phức tạp: O(n²) - chậm, không nên dùng cho dữ liệu lớn

```python
def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(0, n-i-1):
            if arr[j] > arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]
    return arr

# Ví dụ
numbers = [64, 34, 25, 12, 22, 11, 90]
bubble_sort(numbers)  # [11, 12, 22, 25, 34, 64, 90]
```

## Quick Sort
Độ phức tạp: O(n log n) trung bình - nhanh, dùng phổ biến

```python
def quick_sort(arr):
    if len(arr) <= 1:
        return arr
    
    pivot = arr[len(arr)//2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    
    return quick_sort(left) + middle + quick_sort(right)
```

## Merge Sort
Độ phức tạp: O(n log n) - ổn định, tốt cho dữ liệu lớn

## Comparison
| Thuật toán | Trung bình | Tồi nhất | Ổn định |
|-----------|-----------|---------|---------|
| Bubble Sort | O(n²) | O(n²) | Có |
| Quick Sort | O(n log n) | O(n²) | Không |
| Merge Sort | O(n log n) | O(n log n) | Có |
| Heap Sort | O(n log n) | O(n log n) | Không |""")
        ],
        "questions": [
            ("Array là gì?", ["Một đối tượng", "Tập hợp phần tử cùng kiểu", "Một hàm", "Một biến"], 1),
            ("Stack hoạt động theo nguyên tắc?", ["FIFO", "LIFO", "FILO", "OLIF"], 1),
            ("Queue hoạt động theo nguyên tắc?", ["LIFO", "FIFO", "LILO", "OILF"], 1),
            ("Độ phức tạp của Quick Sort trung bình:", ["O(n)", "O(n²)", "O(n log n)", "O(log n)"], 2),
            ("Ứng dụng của Stack:", ["Hàng chờ", "Back button", "In document", "Tìm kiếm"], 1),
        ]
    }
}

# Thêm nội dung chi tiết cho các khóa học khác
MORE_COURSES = {
    "Web Development với React": {
        "lessons": [
            ("React Fundamentals", "React là thư viện JavaScript cho xây dựng giao diện. Nó sử dụng các component tái sử dụng được.\n\n# Khái Niệm Cơ Bản:\n- JSX: Cú pháp mở rộng cho JavaScript\n- Components: Các khối xây dựng giao diện\n- Props: Truyền dữ liệu từ cha xuống con\n- State: Trạng thái nội bộ của component\n- Hooks: useState, useEffect, useContext"),
            ("React Hooks", "Hooks cho phép sử dụng state trong functional components.\n\n# useState:\nQuản lý state trong component.\n\n# useEffect:\nThực hiện side effects sau render.\n\n# useContext:\nTruy cập context mà không cần prop drilling."),
        ],
        "questions": [
            ("React là gì?", ["Ngôn ngữ lập trình", "Thư viện JavaScript", "Framework backend", "Database"], 1),
            ("JSX là gì?", ["Java XML", "JavaScript XML", "Java extension", "JavaScript extension"], 1),
        ]
    },
    
    "Backend Development với Python/FastAPI": {
        "lessons": [
            ("FastAPI Basics", "FastAPI là framework web hiện đại cho xây dựng API với Python.\n\n# Đặc Điểm:\n- Type hints: Gõ tĩnh\n- Async/await: Hỗ trợ bất đồng bộ\n- Automatic documentation: Swagger UI\n- Fast: Hiệu suất cao\n\nSử dụng Uvicorn làm ASGI server."),
            ("Database with SQLAlchemy", "SQLAlchemy là ORM cho Python, giúp làm việc với database dễ dàng.\n\n# CRUD Operations:\nCreate, Read, Update, Delete\n\n# Models:\nXác định cấu trúc bảng như các lớp Python."),
        ],
        "questions": [
            ("FastAPI chạy trên server nào?", ["Apache", "Nginx", "Uvicorn", "IIS"], 2),
            ("ORM là gì?", ["Object Relational Mapping", "Online Resource Manager", "Object Remote Memory", "Operating Resource Model"], 0),
        ]
    }
}

def update_all_content():
    """Update all lessons and quizzes with realistic content"""
    try:
        # Update courses with detailed content
        for course_name, content in {**REALISTIC_CONTENT, **MORE_COURSES}.items():
            course = db.query(Course).filter(
                Course.course_name == course_name
            ).first()
            
            if not course:
                print(f"⏭️  '{course_name}' not found")
                continue
            
            # Delete old lessons
            old_lessons = db.query(Lesson).filter(Lesson.course_id == course.id).all()
            for lesson in old_lessons:
                db.delete(lesson)
            
            # Delete old assessments
            old_assessments = db.query(Assessment).filter(
                Assessment.course_id == course.id
            ).all()
            for assessment in old_assessments:
                db.delete(assessment)
            
            db.commit()
            
            print(f"\n📚 Updating '{course_name}'...")
            
            # Add new lessons
            for i, (title, content_text) in enumerate(content["lessons"]):
                lesson = Lesson(
                    course_id=course.id,
                    title=title,
                    content=content_text,
                    order=i + 1
                )
                db.add(lesson)
                print(f"  ✓ {title}")
            
            db.flush()
            
            # Add assessment
            assessment = Assessment(
                course_id=course.id,
                title=f"Quiz: {course_name}",
                description=f"Kiểm tra kiến thức {course_name}",
                assessment_type=AssessmentType.QUIZ,
                passing_score=60,
                max_score=100
            )
            db.add(assessment)
            db.flush()
            
            # Add questions
            for i, (q_text, opts, correct) in enumerate(content["questions"]):
                question = Question(
                    assessment_id=assessment.id,
                    question_text=q_text,
                    question_type="multiple_choice",
                    option_a=opts[0],
                    option_b=opts[1],
                    option_c=opts[2],
                    option_d=opts[3],
                    correct_answer=chr(97 + correct),
                    points=1.0,
                    order=i + 1
                )
                db.add(question)
            
            db.commit()
            print(f"  ✓ Quiz with {len(content['questions'])} questions")
        
        print("\n✅ Updated all courses with realistic content!")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    print("=" * 70)
    print("🔄 UPDATING WITH REALISTIC CONTENT")
    print("=" * 70)
    update_all_content()

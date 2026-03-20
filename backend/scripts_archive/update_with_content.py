#!/usr/bin/env python
"""Update lessons and quizzes with realistic content - simplified version"""

from app.database import SessionLocal
from app.models import Course, Lesson, Assessment, Question, AssessmentType

db = SessionLocal()

# Content mapping
COURSE_UPDATES = {
    "Nhập môn lập trình": {
        "lessons": [
            {
                "title": "Lập Trình Là Gì",
                "content": "Lập trình là quá trình viết code cho máy tính. Ngôn ngữ phổ biến: Python, Java, JavaScript, C++. Lợi ích: lương cao, nhu cầu cao, nhiều cơ hội việc làm."
            },
            {
                "title": "Biến và Kiểu Dữ Liệu",
                "content": "Biến lưu trữ dữ liệu. Kiểu dữ liệu: Integer (số nguyên), Float (số thực), String (chuỗi), Boolean (đúng/sai), List (danh sách), Dictionary (từ điển). Ví dụ: x = 10 (int), name = 'An' (string)"
            },
            {
                "title": "Toán Tử và Phép Tính",
                "content": "Toán tử số học: +, -, *, /, //, %, **. Toán tử so sánh: ==, !=, <, >, <=, >=. Toán tử logic: and, or, not. Ưu tiên: ** > *,/,//,% > +,-"
            },
            {
                "title": "Câu Lệnh Điều Kiện",
                "content": "If-else điều khiển luồng chương trình. If: thực hiện nếu đúng. If-else: thực hiện một trong hai. If-elif-else: kiểm tra nhiều điều kiện. Cấu trúc lồng nhau được hỗ trợ."
            },
            {
                "title": "Vòng Lặp",
                "content": "For loop: lặp số lần biết trước. While loop: lặp miễn là điều kiện đúng. Break thoát khỏi vòng lặp. Continue bỏ qua lần hiện tại. Range(start, stop, step) tạo dãy số."
            }
        ],
        "questions": [
            ("Lập trình là gì?", ["Sửa máy", "Viết code cho máy", "Bán máy", "Chơi game"], 1),
            ("Kiểu dữ liệu nào lưu số thực?", ["int", "float", "str", "bool"], 1),
            ("Toán tử nào kiểm tra bằng?", ["!=", "==", "=>", "<="], 1),
            ("Stack hoạt động theo nguyên tắc gì?", ["FIFO", "LIFO", "LILO", "OILF"], 1),
            ("For loop dùng khi nào?", ["Không biết số lần", "Biết số lần lặp", "Kiểm tra điều kiện", "Thoát khỏi chương trình"], 1),
        ]
    },
    
    "Cấu trúc dữ liệu và giải thuật": {
        "lessons": [
            {
                "title": "Array và List",
                "content": "Array: tập hợp phần tử cùng kiểu, kích thước cố định. List Python: linh hoạt, có thể thêm/xóa. Truy cập: O(1), Chèn/Xóa: O(n). Ứng dụng: lưu dữ liệu tuần tự."
            },
            {
                "title": "Stack - LIFO",
                "content": "Stack (ngăn xếp): Last In First Out. Giống xếp chồng đĩa. Thao tác: Push (thêm), Pop (lấy). Ứng dụng: Back button, Undo/Redo, Kiểm tra ngoặc, DFS."
            },
            {
                "title": "Queue - FIFO",
                "content": "Queue (hàng chờ): First In First Out. Giống hàng chờ mua vé. Thao tác: Enqueue (thêm), Dequeue (lấy). Ứng dụng: Print queue, BFS, Xử lý yêu cầu, Làm mịn ảnh."
            },
            {
                "title": "Linked List",
                "content": "Linked List: các nút liên kết với nhau qua con trỏ. Ưu điểm: Chèn/Xóa O(1) nếu có con trỏ. Nhược điểm: Truy cập O(n), cần thêm bộ nhớ. Ứng dụng: Danh sách động."
            },
            {
                "title": "Sorting Algorithms",
                "content": "Bubble Sort O(n²). Quick Sort O(n log n). Merge Sort O(n log n). Heap Sort O(n log n). Selection, Insertion: O(n²). Chọn dựa trên yêu cầu: tốc độ vs ổn định."
            }
        ],
        "questions": [
            ("Array/List truy cập phần tử: ", ["O(n)", "O(n²)", "O(1)", "O(log n)"], 2),
            ("Stack là LIFO, Queue là gì?", ["LIFO", "FIFO", "LILO", "Random"], 1),
            ("Merge Sort độ phức tạp?", ["O(n)", "O(n²)", "O(n log n)", "O(log n)"], 2),
            ("Chèn/Xóa trong Linked List:", ["O(1)", "O(n)", "O(n²)", "O(log n)"], 0),
            ("DFS dùng cấu trúc nào?", ["Queue", "Stack", "Array", "Tree"], 1),
        ]
    },
    
    "Web Development với React": {
        "lessons": [
            {
                "title": "React Fundamentals",
                "content": "React là thư viện JavaScript cho UI. Component: khối xây dựng tái sử dụng. JSX: cú pháp mở rộng. Props: truyền dữ liệu cha->con. State: trạng thái nội bộ. Hooks: useState, useEffect, useContext."
            },
            {
                "title": "Components và Props",
                "content": "Functional Components: hàm trả về JSX. Props: tham số truyền vào. Destructuring props. Default props. PropTypes kiểm tra kiểu. Children component. Composition vs Inheritance."
            },
            {
                "title": "Hooks - useState",
                "content": "useState quản lý state trong functional component. Cú pháp: const [state, setState] = useState(initialValue). Sử dụng: event handler, setters. Quy tắc: gọi ở top level. Re-render khi state thay đổi."
            },
            {
                "title": "Hooks - useEffect",
                "content": "useEffect thực hiện side effect. Cú pháp: useEffect(callback, dependencies). Dependency array: [] (một lần), [dep] (khi dep thay đổi), không có (mỗi render). Cleanup function return trong callback."
            },
            {
                "title": "React Router",
                "content": "React Router quản lý navigation. BrowserRouter: kích hoạt routing. Routes/Route: định nghĩa routes. Link/NavLink: điều hướng. useNavigate: lập trình điều hướng. useParams: lấy tham số URL."
            }
        ],
        "questions": [
            ("React là gì?", ["Ngôn ngữ", "Thư viện", "Framework backend", "Database"], 1),
            ("Props dùng để?", ["Lưu state", "Truyền dữ liệu", "Render lại", "Gọi API"], 1),
            ("useState trả về?", ["State", "[state, setState]", "setState", "value"], 1),
            ("useEffect dependency?", ["Không bắt buộc", "Bắt buộc luôn", "Tùy case", "Chỉ với async"], 2),
            ("React Router dùng component nào?", ["Router", "BrowserRouter", "Route", "Tất cả"], 3),
        ]
    },
    
    "Backend Development với Python/FastAPI": {
        "lessons": [
            {
                "title": "FastAPI Basics",
                "content": "FastAPI: framework web hiện đại Python. Type hints: gõ tĩnh. Async/await: bất đồng bộ. Automatic docs: Swagger UI, ReDoc. ASGI server: Uvicorn. Decorator: @app.get, @app.post, @app.put, @app.delete."
            },
            {
                "title": "Request/Response",
                "content": "Request body: Pydantic models. Path parameters: /items/{item_id}. Query parameters: ?skip=0&limit=10. Headers: authorization. Response status: 200, 201, 400, 404, 500. Response model: định nghĩa cấu trúc trả về."
            },
            {
                "title": "SQLAlchemy ORM",
                "content": "ORM: Object Relational Mapping. Define models: class inherited Base. Columns: Column(type). Relationships: relationship(). CRUD: create, read, update, delete. Query: db.query(Model). Filter: filter(), filter_by()."
            },
            {
                "title": "Authentication & Security",
                "content": "JWT: JSON Web Tokens xác thực. Password hashing: bcrypt. Dependencies: Depends() kiểm tra quyền. CORS: chia sẻ tài nguyên. Rate limiting. Middleware: xử lý request trước controllers."
            },
            {
                "title": "Testing APIs",
                "content": "pytest: unit testing. TestClient: test FastAPI apps. Mock database. Test CRUD operations. Assert status codes. Fixtures: setup/teardown. Integration tests. Load testing."
            }
        ],
        "questions": [
            ("FastAPI server nào?", ["Apache", "Nginx", "Uvicorn", "IIS"], 2),
            ("ORM là gì?", ["Object Relational Mapping", "Online Resource Manager", "Object Remote Memory", "Operating Resource Model"], 0),
            ("JWT dùng để?", ["Database", "Xác thực", "Routing", "Testing"], 1),
            ("Decorator GET/POST?", ["@app.get(), @app.post()", "get(), post()", "#get, #post", "GET(), POST()"], 0),
            ("Kiểm tra quyền FastAPI?", ["Middleware", "Depends()", "Headers", "Query"], 1),
        ]
    },
    
    "Cơ sở dữ liệu": {
        "lessons": [
            {
                "title": "CSDL Quan Hệ",
                "content": "Database: tập hợp dữ liệu tổ chức. Quan hệ: bảng, hàng, cột. Bảng: tập bản ghi. Bản ghi: dòng. Trường: cột. Khóa chính: xác định duy nhất. Khóa ngoài: liên kết bảng. ACID: Atomicity, Consistency, Isolation, Durability."
            },
            {
                "title": "SELECT & WHERE",
                "content": "SELECT: lấy dữ liệu. Cú pháp: SELECT columns FROM table WHERE condition. WHERE: lọc điều kiện. Operators: =, !=, <, >, <=, >=, LIKE, IN, BETWEEN. AND, OR logic."
            },
            {
                "title": "INSERT, UPDATE, DELETE",
                "content": "INSERT: thêm bản ghi. Cú pháp: INSERT INTO table (cols) VALUES (vals). UPDATE: sửa. Cú pháp: UPDATE table SET col=val WHERE condition. DELETE: xóa. Cú pháp: DELETE FROM table WHERE condition."
            },
            {
                "title": "JOIN Operations",
                "content": "INNER JOIN: giao của hai bảng. LEFT JOIN: tất cả bên trái + khớp. RIGHT JOIN: tất cả bên phải + khớp. FULL JOIN: tất cả. ON: điều kiện join. Alias: AS."
            },
            {
                "title": "Indexing & Optimization",
                "content": "Index: tăng tốc độ truy vấn. Primary key: index tự động. Composite index: nhiều cột. EXPLAIN: xem kế hoạch query. Avoid: SELECT *, N+1 queries. Normalize: giảm lặp dữ liệu."
            }
        ],
        "questions": [
            ("CSDL quan hệ chứa?", ["Đối tượng", "Bảng, hàng, cột", "Hàm", "Hình ảnh"], 1),
            ("SELECT dùng để?", ["Thêm", "Lấy", "Sửa", "Xóa"], 1),
            ("INNER JOIN trả về?", ["Giao", "Hợp", "Hiệu", "Bù"], 0),
            ("Index tác dụng?", ["Thêm dữ liệu", "Xóa dữ liệu", "Tăng tốc truy vấn", "Bảo mật"], 2),
            ("Khóa chính dùng?", ["Tìm kiếm", "Xác định duy nhất", "Liên kết bảng", "Sắp xếp"], 1),
        ]
    }
}

def update_courses():
    """Update all courses with realistic content"""
    try:
        updated = 0
        
        for course_name, content in COURSE_UPDATES.items():
            course = db.query(Course).filter(Course.course_name == course_name).first()
            
            if not course:
                print(f"⏭️  '{course_name}' not found")
                continue
            
            print(f"\n📚 Updating '{course_name}'...")
            
            # Delete old content
            db.query(Lesson).filter(Lesson.course_id == course.id).delete()
            db.query(Assessment).filter(Assessment.course_id == course.id).delete()
            db.commit()
            
            # Add lessons
            for i, lesson_data in enumerate(content["lessons"]):
                lesson = Lesson(
                    course_id=course.id,
                    title=lesson_data["title"],
                    content=lesson_data["content"],
                    order=i + 1
                )
                db.add(lesson)
                print(f"  ✓ {lesson_data['title']}")
            
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
            updated += 1
        
        print(f"\n✅ Successfully updated {updated} courses with realistic content!")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    print("=" * 70)
    print("🔄 UPDATING COURSES WITH REALISTIC CONTENT")
    print("=" * 70)
    update_courses()

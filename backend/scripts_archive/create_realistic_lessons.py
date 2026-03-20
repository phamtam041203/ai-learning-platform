"""
Script to create realistic lessons and quizzes with real content from the internet
"""

import sys
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models import Course, Lesson, Assessment, Question, LessonProgress, AssessmentType
from app.database import Base, SessionLocal, engine
from app.core.config import settings

# Realistic lesson and quiz data - mapped to actual courses
LESSONS_DATA = {
    "Web Development with React": [
        {
            "title": "Giới thiệu lập trình",
            "content": """
# Giới thiệu lập trình

## Lập trình là gì?
Lập trình (Programming) là quá trình viết các hướng dẫn cho máy tính thực hiện những công việc cụ thể. 
Các hướng dẫn này được viết bằng những ngôn ngữ lập trình như Python, Java, C++, JavaScript, v.v.

## Tại sao học lập trình?
1. **Lương cao**: Lập trình viên có mức lương cạnh tranh cao
2. **Nhu cầu cao**: Mọi công ty đều cần lập trình viên
3. **Cơ hội việc làm**: Nhiều công ty tuyển dụng từ startup đến các tập đoàn lớn
4. **Sáng tạo**: Bạn có thể tạo những ứng dụng hữu ích cho thế giới

## Các ngôn ngữ lập trình phổ biến
- **Python**: Dễ học, phổ biến trong AI/ML
- **Java**: Được sử dụng rộng rãi trong các doanh nghiệp
- **JavaScript**: Dùng để tạo website
- **C++**: Lập trình hiệu suất cao

## Bắt đầu học lập trình
- Chọn một ngôn ngữ lập trình
- Hiểu cơ bản: biến, kiểu dữ liệu, vòng lặp
- Thực hành bằng cách viết các chương trình nhỏ
- Dần dần tăng độ phức tạp
            """
        },
        {
            "title": "Các khái niệm cơ bản",
            "content": """
# Các khái niệm cơ bản

## Biến (Variables)
Biến là một vùng bộ nhớ dùng để lưu trữ dữ liệu. Ví dụ:
```
x = 10        # Biến x có giá trị 10
name = "An"   # Biến name có giá trị "An"
```

## Kiểu dữ liệu (Data Types)
- **Integer** (Số nguyên): 10, 20, -5
- **Float** (Số thực): 3.14, 2.5, -1.5
- **String** (Chuỗi): "Hello", "An"
- **Boolean** (Logic): True, False
- **List** (Danh sách): [1, 2, 3, "An"]
- **Dictionary** (Từ điển): {"name": "An", "age": 20}

## Toán tử (Operators)
- **Toán học**: + (cộng), - (trừ), * (nhân), / (chia)
- **Gán**: = 
- **So sánh**: == (bằng), != (khác), < (nhỏ hơn), > (lớn hơn)
- **Logic**: and, or, not

## Câu lệnh điều kiện (If-Else)
```
if điều_kiện:
    # Thực hiện khi điều kiện đúng
else:
    # Thực hiện khi điều kiện sai
```

## Vòng lặp (Loops)
**Vòng lặp For:**
```
for i in range(5):
    print(i)  # In 0, 1, 2, 3, 4
```

**Vòng lặp While:**
```
while x < 10:
    x = x + 1
```
            """
        }
    ],
    "Lập trình hướng đối tượng": [
        {
            "title": "Giới thiệu OOP",
            "content": """
# Lập trình hướng đối tượng (OOP)

## OOP là gì?
Lập trình hướng đối tượng (Object-Oriented Programming - OOP) là một phương pháp lập trình 
tổ chức mã thành các "đối tượng" có chứa dữ liệu và hành động.

## Các khái niệm chính

### 1. Lớp (Class)
Lớp là một bản thiết kế để tạo đối tượng. Ví dụ:
```python
class Sinh_vien:
    def __init__(self, ten, tuoi):
        self.ten = ten
        self.tuoi = tuoi
```

### 2. Đối tượng (Object)
Đối tượng là một thể hiện của lớp:
```python
sv1 = Sinh_vien("An", 20)
```

### 3. Thuộc tính (Attributes)
Dữ liệu mà đối tượng chứa:
```python
sv1.ten    # "An"
sv1.tuoi   # 20
```

### 4. Phương thức (Methods)
Những hành động mà đối tượng có thể thực hiện:
```python
class Sinh_vien:
    def hoc(self):
        return f"{self.ten} đang học"
```

## Bốn trụ cột của OOP

1. **Encapsulation (Đóng gói)**: Ẩn các chi tiết bên trong
2. **Inheritance (Kế thừa)**: Lớp con kế thừa từ lớp cha
3. **Polymorphism (Đa hình)**: Cùng tên phương thức, cách thực hiện khác nhau
4. **Abstraction (Trừu tượng)**: Ẩn độ phức tạp, chỉ hiển thị giao diện
            """
        },
        {
            "title": "Kế thừa và Đa hình",
            "content": """
# Kế thừa (Inheritance) và Đa hình (Polymorphism)

## Kế thừa
Kế thừa cho phép một lớp (lớp con) kế thừa các thuộc tính và phương thức từ lớp khác (lớp cha).

```python
class Nguoi:
    def __init__(self, ten, tuoi):
        self.ten = ten
        self.tuoi = tuoi
    
    def gioi_thieu(self):
        return f"Tôi là {self.ten}, {self.tuoi} tuổi"

class Sinh_vien(Nguoi):
    def __init__(self, ten, tuoi, ma_sv):
        super().__init__(ten, tuoi)
        self.ma_sv = ma_sv
```

## Đa hình
Đa hình cho phép các lớp con triển khai lại các phương thức từ lớp cha:

```python
class Dong_vat:
    def keu(self):
        pass

class Cho(Dong_vat):
    def keu(self):
        return "Gâu gâu"

class Meo(Dong_vat):
    def keu(self):
        return "Meo meo"
```

## Override (Ghi đè)
Override cho phép lớp con thay đổi cách thực hiện của phương thức từ lớp cha.

## Super()
Sử dụng super() để gọi phương thức của lớp cha từ lớp con.
            """
        }
    ],
    "Cơ sở dữ liệu": [
        {
            "title": "Giới thiệu CSDL",
            "content": """
# Cơ sở dữ liệu (Database)

## CSDL là gì?
Cơ sở dữ liệu là một tập hợp dữ liệu được tổ chức, lưu trữ và quản lý một cách có hệ thống.

## Tại sao cần CSDL?
1. **Lưu trữ lớn**: Có thể lưu hàng tỷ bản ghi
2. **Truy xuất nhanh**: Tìm dữ liệu trong vài mili giây
3. **Bảo mật**: Bảo vệ dữ liệu với quyền hạn
4. **Sao lưu**: Dễ dàng sao lưu và phục hồi dữ liệu

## Các loại CSDL

### 1. CSDL quan hệ (Relational Database)
- Dữ liệu được tổ chức trong các bảng
- Mỗi hàng là một bản ghi, mỗi cột là một trường
- Ví dụ: MySQL, PostgreSQL, SQL Server

### 2. CSDL NoSQL
- Không sử dụng bảng mà sử dụng các cấu trúc dữ liệu khác
- Ví dụ: MongoDB, Redis, Cassandra

## Khái niệm cơ bản

**Bảng (Table)**
- Tập hợp các bản ghi cùng loại
- Ví dụ: Bảng Sinh_vien

**Bản ghi (Record)**
- Một dòng trong bảng
- Ví dụ: Thông tin của một sinh viên

**Trường (Field)**
- Một cột trong bảng
- Ví dụ: Tên, tuổi, email

**Khóa chính (Primary Key)**
- Dùng để xác định duy nhất mỗi bản ghi
- Ví dụ: ID sinh viên
            """
        },
        {
            "title": "SQL cơ bản",
            "content": """
# SQL - Ngôn ngữ truy vấn cơ sở dữ liệu

## SQL là gì?
SQL (Structured Query Language) là ngôn ngữ dùng để thao tác với CSDL quan hệ.

## Các câu lệnh cơ bản

### SELECT - Truy vấn dữ liệu
```sql
SELECT * FROM sinh_vien;  -- Lấy tất cả sinh viên
SELECT ten, tuoi FROM sinh_vien;  -- Lấy tên và tuổi
SELECT * FROM sinh_vien WHERE tuoi > 20;  -- Lấy sinh viên trên 20 tuổi
```

### INSERT - Thêm dữ liệu
```sql
INSERT INTO sinh_vien (ten, tuoi, email) 
VALUES ('An', 20, 'an@vanlang.edu.vn');
```

### UPDATE - Cập nhật dữ liệu
```sql
UPDATE sinh_vien 
SET tuoi = 21 
WHERE ten = 'An';
```

### DELETE - Xóa dữ liệu
```sql
DELETE FROM sinh_vien 
WHERE tuoi < 18;
```

## WHERE - Điều kiện
- Bằng: WHERE tuoi = 20
- Khác: WHERE tuoi != 20
- Lớn hơn: WHERE tuoi > 20
- Nhỏ hơn: WHERE tuoi < 20
- AND/OR: WHERE tuoi > 20 AND ten = 'An'

## ORDER BY - Sắp xếp
```sql
SELECT * FROM sinh_vien 
ORDER BY tuoi DESC;  -- Sắp xếp theo tuổi giảm dần
```

## JOIN - Kết nối bảng
```sql
SELECT sv.ten, kh.ten 
FROM sinh_vien sv 
JOIN khoa_hoc kh ON sv.khoa_hoc_id = kh.id;
```
            """
        }
    ],
    "Web Development": [
        {
            "title": "HTML cơ bản",
            "content": """
# HTML - Ngôn ngữ đánh dấu siêu văn bản

## HTML là gì?
HTML (HyperText Markup Language) là ngôn ngữ dùng để tạo cấu trúc của trang web.

## Cấu trúc HTML cơ bản
```html
<!DOCTYPE html>
<html>
<head>
    <title>Tiêu đề trang web</title>
</head>
<body>
    <h1>Xin chào</h1>
    <p>Đây là một trang web</p>
</body>
</html>
```

## Các thẻ HTML phổ biến

### Thẻ tiêu đề
```html
<h1>Tiêu đề cấp 1</h1>
<h2>Tiêu đề cấp 2</h2>
<h3>Tiêu đề cấp 3</h3>
```

### Thẻ văn bản
```html
<p>Đoạn văn</p>
<a href="https://google.com">Liên kết</a>
<strong>Chữ đậm</strong>
<em>Chữ nghiêng</em>
```

### Thẻ danh sách
```html
<ul>
    <li>Mục 1</li>
    <li>Mục 2</li>
</ul>

<ol>
    <li>Mục thứ 1</li>
    <li>Mục thứ 2</li>
</ol>
```

### Thẻ biểu mẫu
```html
<form>
    <input type="text" name="ten">
    <input type="password" name="mat_khau">
    <button type="submit">Gửi</button>
</form>
```

## Thuộc tính HTML
```html
<img src="hinh.jpg" alt="Hình ảnh">
<a href="page.html" target="_blank">Link</a>
<div class="container" id="main">...</div>
```
            """
        },
        {
            "title": "CSS styling",
            "content": """
# CSS - Cascading Style Sheets

## CSS là gì?
CSS (Cascading Style Sheets) dùng để trang trí, định dạng giao diện của trang web.

## Cách sử dụng CSS

### Inline CSS
```html
<p style="color: red; font-size: 18px;">Văn bản đỏ</p>
```

### Internal CSS
```html
<style>
p {
    color: blue;
    font-size: 16px;
}
</style>
```

### External CSS
```html
<link rel="stylesheet" href="style.css">
```

## Các tính chất CSS phổ biến

### Màu sắc
```css
color: red;              /* Màu chữ */
background-color: blue;  /* Màu nền */
```

### Kích thước
```css
width: 100px;      /* Chiều rộng */
height: 50px;      /* Chiều cao */
font-size: 16px;   /* Kích thước chữ */
padding: 10px;     /* Khoảng cách bên trong */
margin: 10px;      /* Khoảng cách bên ngoài */
```

### Font chữ
```css
font-family: Arial, sans-serif;
font-weight: bold;
font-style: italic;
```

### CSS Selector
```css
p { ... }              /* Tất cả thẻ <p> */
.container { ... }     /* Class "container" */
#main { ... }          /* ID "main" */
p.intro { ... }        /* Thẻ <p> có class "intro" */
```

## Flexbox
```css
.container {
    display: flex;
    justify-content: center;
    align-items: center;
}
```
            """
        }
    ],
    "Backend Development": [
        {
            "title": "REST API cơ bản",
            "content": """
# REST API - Cơ sở

## REST là gì?
REST (Representational State Transfer) là một phong cách thiết kế API web.

## HTTP Methods
- **GET**: Lấy dữ liệu (không thay đổi dữ liệu)
- **POST**: Tạo dữ liệu mới
- **PUT**: Cập nhật toàn bộ dữ liệu
- **PATCH**: Cập nhật một phần dữ liệu
- **DELETE**: Xóa dữ liệu

## Status Codes
- **200 OK**: Thành công
- **201 Created**: Tạo thành công
- **400 Bad Request**: Yêu cầu sai
- **401 Unauthorized**: Chưa xác thực
- **404 Not Found**: Không tìm thấy
- **500 Internal Server Error**: Lỗi máy chủ

## Ví dụ API

### GET - Lấy danh sách sinh viên
```
GET /api/sinh-vien
Response:
[
    {"id": 1, "ten": "An", "tuoi": 20},
    {"id": 2, "ten": "Bình", "tuoi": 21}
]
```

### POST - Tạo sinh viên mới
```
POST /api/sinh-vien
Body:
{"ten": "Cẩm", "tuoi": 19}
Response:
{"id": 3, "ten": "Cẩm", "tuoi": 19}
```

### GET - Lấy sinh viên theo ID
```
GET /api/sinh-vien/1
Response:
{"id": 1, "ten": "An", "tuoi": 20}
```

### PUT - Cập nhật sinh viên
```
PUT /api/sinh-vien/1
Body:
{"ten": "An", "tuoi": 21}
```

### DELETE - Xóa sinh viên
```
DELETE /api/sinh-vien/1
Response: 204 No Content
```

## JSON Format
```json
{
    "id": 1,
    "ten": "An",
    "tuoi": 20,
    "email": "an@vanlang.edu.vn"
}
```
            """
        },
        {
            "title": "Xác thực và bảo mật API",
            "content": """
# Xác thực và Bảo mật API

## Tại sao cần bảo mật API?
- Bảo vệ dữ liệu người dùng
- Ngăn chặn truy cập trái phép
- Kiểm soát tài nguyên

## JWT (JSON Web Token)

### JWT là gì?
JWT là một cách xác thực stateless, không cần lưu session trên server.

### Cấu trúc JWT
```
header.payload.signature

Ví dụ:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.
eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.
SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

### Cách hoạt động
1. User gửi username/password
2. Server xác minh và tạo JWT
3. Client lưu JWT
4. Mỗi request, client gửi JWT trong header Authorization
5. Server xác minh JWT

### Sử dụng JWT
```
Authorization: Bearer <token>
```

## HTTPS
- Mã hóa dữ liệu trong quá trình truyền
- Bắt buộc với API sản xuất
- Sử dụng SSL/TLS

## CORS (Cross-Origin Resource Sharing)
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
```

## Rate Limiting
- Giới hạn số lượng request từ một IP
- Ngăn chặn abuse và DDoS
- Ví dụ: 100 request/phút per IP

## Input Validation
```
- Kiểm tra kiểu dữ liệu
- Kiểm tra độ dài chuỗi
- Kiểm tra định dạng email
- SQL Injection prevention
```
            """
        }
    ]
}

# Quiz data - realistic questions
QUIZ_DATA = {
    "Cơ sở lập trình": [
        {
            "question": "Lập trình viên là gì?",
            "options": [
                "Người viết hướng dẫn cho máy tính thực hiện công việc",
                "Người sửa chữa máy tính",
                "Người bán máy tính",
                "Người sử dụng máy tính"
            ],
            "correct": 0
        },
        {
            "question": "Python là gì?",
            "options": [
                "Một loại rắn độc",
                "Một ngôn ngữ lập trình",
                "Một trò chơi máy tính",
                "Một hệ điều hành"
            ],
            "correct": 1
        },
        {
            "question": "Biến trong lập trình dùng để làm gì?",
            "options": [
                "Lưu trữ dữ liệu",
                "Tạo vòng lặp",
                "Kết nối mạng",
                "Vẽ hình ảnh"
            ],
            "correct": 0
        },
        {
            "question": "Vòng lặp for dùng để làm gì?",
            "options": [
                "Lặp lại một khối mã nhiều lần",
                "Tạo một hàm",
                "Kiểm tra điều kiện",
                "Sắp xếp dữ liệu"
            ],
            "correct": 0
        },
        {
            "question": "Kiểu dữ liệu nào dùng để lưu số nguyên?",
            "options": [
                "String",
                "Float",
                "Integer",
                "Boolean"
            ],
            "correct": 2
        }
    ],
    "Lập trình hướng đối tượng": [
        {
            "question": "OOP là viết tắt của?",
            "options": [
                "Open Object Programming",
                "Object-Oriented Programming",
                "Object Operating Program",
                "Online Object Processing"
            ],
            "correct": 1
        },
        {
            "question": "Lớp (Class) trong OOP là gì?",
            "options": [
                "Một phòng học",
                "Một bản thiết kế để tạo đối tượng",
                "Một tập hợp dữ liệu",
                "Một loại biến"
            ],
            "correct": 1
        },
        {
            "question": "Kế thừa (Inheritance) cho phép gì?",
            "options": [
                "Lớp con kế thừa từ lớp cha",
                "Tạo nhiều lớp",
                "Ẩn dữ liệu",
                "Tạo vòng lặp"
            ],
            "correct": 0
        },
        {
            "question": "Đa hình (Polymorphism) là gì?",
            "options": [
                "Một loại lớp",
                "Cùng tên phương thức, cách thực hiện khác nhau",
                "Nhiều lớp con",
                "Ẩn thông tin"
            ],
            "correct": 1
        },
        {
            "question": "Từ khóa 'super()' dùng để làm gì?",
            "options": [
                "Tạo lớp cha",
                "Gọi phương thức của lớp cha từ lớp con",
                "Tạo lớp con",
                "Xóa dữ liệu"
            ],
            "correct": 1
        }
    ],
    "Cơ sở dữ liệu": [
        {
            "question": "CSDL (Database) là gì?",
            "options": [
                "Một tập hợp dữ liệu được tổ chức",
                "Một ngôn ngữ lập trình",
                "Một loại máy tính",
                "Một hệ điều hành"
            ],
            "correct": 0
        },
        {
            "question": "MySQL thuộc loại CSDL nào?",
            "options": [
                "NoSQL",
                "CSDL quan hệ (Relational)",
                "CSDL phân tán",
                "CSDL tài liệu"
            ],
            "correct": 1
        },
        {
            "question": "SQL SELECT dùng để?",
            "options": [
                "Thêm dữ liệu",
                "Xóa dữ liệu",
                "Lấy dữ liệu",
                "Cập nhật dữ liệu"
            ],
            "correct": 2
        },
        {
            "question": "Khóa chính (Primary Key) dùng để?",
            "options": [
                "Xác định duy nhất mỗi bản ghi",
                "Mã hóa dữ liệu",
                "Sắp xếp dữ liệu",
                "Tạo sao lưu"
            ],
            "correct": 0
        },
        {
            "question": "JOIN trong SQL dùng để?",
            "options": [
                "Kết nối nhiều bảng",
                "Xóa bảng",
                "Tạo bảng",
                "Sao lưu dữ liệu"
            ],
            "correct": 0
        }
    ],
    "Web Development": [
        {
            "question": "HTML là gì?",
            "options": [
                "Một ngôn ngữ lập trình",
                "Ngôn ngữ đánh dấu siêu văn bản",
                "Một máy chủ web",
                "Một cơ sở dữ liệu"
            ],
            "correct": 1
        },
        {
            "question": "Thẻ nào dùng để tạo đoạn văn trong HTML?",
            "options": [
                "<h1>",
                "<div>",
                "<p>",
                "<span>"
            ],
            "correct": 2
        },
        {
            "question": "CSS dùng để?",
            "options": [
                "Tạo cấu trúc trang web",
                "Trang trí và định dạng trang web",
                "Tạo cơ sở dữ liệu",
                "Kết nối máy chủ"
            ],
            "correct": 1
        },
        {
            "question": "Lớp (class) trong CSS được viết như thế nào?",
            "options": [
                "#class-name",
                ".class-name",
                "@class-name",
                "$class-name"
            ],
            "correct": 1
        },
        {
            "question": "JavaScript dùng để?",
            "options": [
                "Tạo cấu trúc trang web",
                "Trang trí trang web",
                "Tạo tương tác động và chức năng cho trang web",
                "Lưu trữ dữ liệu"
            ],
            "correct": 2
        }
    ],
    "Backend Development": [
        {
            "question": "REST API là gì?",
            "options": [
                "Một cơ sở dữ liệu",
                "Một ngôn ngữ lập trình",
                "Một phong cách thiết kế API web",
                "Một trình duyệt web"
            ],
            "correct": 2
        },
        {
            "question": "HTTP GET dùng để?",
            "options": [
                "Tạo dữ liệu",
                "Lấy dữ liệu",
                "Xóa dữ liệu",
                "Cập nhật dữ liệu"
            ],
            "correct": 1
        },
        {
            "question": "Status code 200 có nghĩa là?",
            "options": [
                "Lỗi",
                "Thành công",
                "Không tìm thấy",
                "Chưa xác thực"
            ],
            "correct": 1
        },
        {
            "question": "JWT là gì?",
            "options": [
                "Một cơ sở dữ liệu",
                "Một ngôn ngữ lập trình",
                "JSON Web Token - cách xác thực",
                "Một máy chủ web"
            ],
            "correct": 2
        },
        {
            "question": "CORS dùng để?",
            "options": [
                "Sắp xếp dữ liệu",
                "Chia sẻ tài nguyên giữa các domain khác nhau",
                "Mã hóa dữ liệu",
                "Tạo sao lưu"
            ],
            "correct": 1
        }
    ]
}

# Database setup
Base.metadata.create_all(bind=engine)

def create_lessons_and_quizzes():
    """Create realistic lessons and quizzes"""
    db = SessionLocal()
    
    try:
        # Get courses
        courses = db.query(Course).filter(
            Course.course_code.in_(["CS101", "CS102", "CS103", "CS104", "CS105"])
        ).all()
        
        for course in courses:
            course_name = course.course_name
            
            if course_name not in LESSONS_DATA:
                print(f"⏭️  No lesson data for {course_name}, skipping...")
                continue
            
            # Get existing lessons count
            existing_lessons = db.query(Lesson).filter(
                Lesson.course_id == course.id
            ).count()
            
            if existing_lessons > 0:
                print(f"✅ {course_name} already has {existing_lessons} lessons, skipping...")
                continue
            
            print(f"\n📚 Creating lessons for {course_name}...")
            
            # Create lessons
            lessons_list = []
            for lesson_idx, lesson_data in enumerate(LESSONS_DATA[course_name]):
                lesson = Lesson(
                    course_id=course.id,
                    title=lesson_data["title"],
                    content=lesson_data["content"],
                    order=lesson_idx + 1
                )
                db.add(lesson)
                db.flush()
                lessons_list.append(lesson)
                print(f"  ✓ Created lesson: {lesson.title}")
            
            # Create quizzes
            if course_name in QUIZ_DATA:
                print(f"📝 Creating quiz for {course_name}...")
                
                assessment = Assessment(
                    course_id=course.id,
                    title=f"Quiz: {course_name}",
                    description=f"Kiểm tra kiến thức về {course_name}",
                    assessment_type=AssessmentType.QUIZ,
                    passing_score=60,
                    max_score=100
                )
                db.add(assessment)
                db.flush()
                
                # Create questions
                for q_idx, q_data in enumerate(QUIZ_DATA[course_name]):
                    question = Question(
                        assessment_id=assessment.id,
                        question_text=q_data["question"],
                        question_type="multiple_choice",
                        option_a=q_data["options"][0],
                        option_b=q_data["options"][1],
                        option_c=q_data["options"][2],
                        option_d=q_data["options"][3],
                        correct_answer=chr(97 + q_data["correct"]),  # a, b, c, d
                        points=1.0,
                        order=q_idx + 1
                    )
                    db.add(question)
                    
                    print(f"  ✓ Created question: {q_data['question']}")
                
                print(f"  ✓ Created quiz with {len(QUIZ_DATA[course_name])} questions")
        
        db.commit()
        print("\n✅ All lessons and quizzes created successfully!")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error creating lessons and quizzes: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    print("=" * 60)
    print("🎓 Creating Realistic Lessons and Quizzes")
    print("=" * 60)
    create_lessons_and_quizzes()

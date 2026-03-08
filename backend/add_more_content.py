#!/usr/bin/env python
"""Add realistic lessons and quizzes to more courses"""

from app.database import SessionLocal
from app.models import Course, Lesson, Assessment, Question, AssessmentType

db = SessionLocal()

# Comprehensive content for various specializations
COURSES_CONTENT = {
    "Mobile Development với React Native": {
        "lessons": [
            {
                "title": "React Native Fundamentals",
                "content": """# React Native Basics
React Native allows you to build mobile apps using JavaScript and React.
- Cross-platform development for iOS and Android
- Code reuse between platforms
- Native components and performance
- Hot reload for fast development"""
            },
            {
                "title": "Navigation & Routing",
                "content": """# Navigation in React Native
React Navigation is the most popular library for routing.
- Stack Navigator: Navigate between screens
- Tab Navigator: Tab-based navigation
- Deep linking: Direct access to specific screens
- Dynamic navigation with parameters"""
            }
        ],
        "questions": [
            {"q": "What is React Native?", "opts": ["Mobile framework", "Web framework", "Desktop app", "Backend service"], "ans": 0},
            {"q": "Which navigator is for tabs?", "opts": ["StackNavigator", "TabNavigator", "DrawerNavigator", "WebNavigator"], "ans": 1},
        ]
    },
    "Big Data Fundamentals": {
        "lessons": [
            {
                "title": "Introduction to Big Data",
                "content": """# Big Data Concepts
Big Data refers to extremely large datasets that are difficult to process.
- **Volume**: Large amounts of data
- **Velocity**: Fast generation of new data
- **Variety**: Different types of data formats
- **Veracity**: Data quality and reliability
- **Value**: Extracting insights from data"""
            },
            {
                "title": "Hadoop Ecosystem",
                "content": """# Hadoop
Hadoop is an open-source framework for distributed storage and processing.
- HDFS: Distributed file system
- MapReduce: Distributed processing
- YARN: Resource management
- Pig: Data flow programming
- Hive: SQL-like queries on Hadoop"""
            }
        ],
        "questions": [
            {"q": "What does Volume mean in Big Data?", "opts": ["Speed of data", "Large amount of data", "Data types", "Data quality"], "ans": 1},
            {"q": "What is HDFS?", "opts": ["Storage system", "Processing engine", "Query language", "Framework"], "ans": 0},
        ]
    },
    "Apache Spark for Data Processing": {
        "lessons": [
            {
                "title": "Spark Overview",
                "content": """# Apache Spark
Spark is a unified analytics engine for large-scale data processing.
- In-memory computation for speed
- Supports multiple languages: Python, Scala, Java, SQL
- RDDs: Resilient Distributed Datasets
- DataFrames and Spark SQL
- Streaming and Machine Learning libraries"""
            },
            {
                "title": "Spark DataFrame API",
                "content": """# Working with Spark DataFrames
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("demo").getOrCreate()

# Create DataFrame
df = spark.read.csv("data.csv", header=True)

# Select columns
df.select("name", "age").show()

# Filter
df.filter(df.age > 25).show()

# Group by
df.groupBy("department").count().show()
```"""
            }
        ],
        "questions": [
            {"q": "What is Spark's main advantage?", "opts": ["Easiest to learn", "In-memory computation", "Lowest cost", "Best documentation"], "ans": 1},
            {"q": "What is an RDD?", "opts": ["Regular Data Display", "Resilient Distributed Dataset", "Remote Data Database", "Relational Data Definition"], "ans": 1},
        ]
    },
    "Cybersecurity Fundamentals": {
        "lessons": [
            {
                "title": "Security Basics",
                "content": """# Cybersecurity Fundamentals
- **Confidentiality**: Only authorized access to data
- **Integrity**: Data remains accurate and unmodified
- **Availability**: Systems accessible when needed
- **Threats**: Viruses, malware, phishing, hacking
- **Vulnerabilities**: Weaknesses in systems or code
- **Attacks**: Active attempts to exploit vulnerabilities"""
            },
            {
                "title": "Network Security",
                "content": """# Network Security
- **Firewalls**: Control inbound/outbound traffic
- **VPN**: Virtual Private Network for secure connections
- **IDS/IPS**: Intrusion Detection/Prevention Systems
- **WAF**: Web Application Firewall
- **Penetration Testing**: Authorized security testing
- **DoS/DDoS**: Denial of Service attacks"""
            }
        ],
        "questions": [
            {"q": "What does Confidentiality mean?", "opts": ["Accuracy of data", "Authorized access", "System uptime", "Data backup"], "ans": 1},
            {"q": "What does VPN stand for?", "opts": ["Virtual Private Network", "Very Protected Network", "Virtual Public Network", "Verified Private Notification"], "ans": 0},
        ]
    },
    "Cryptography & Encryption": {
        "lessons": [
            {
                "title": "Encryption Basics",
                "content": """# Cryptography Concepts
- **Plaintext**: Original unencrypted data
- **Ciphertext**: Encrypted data
- **Key**: Secret used to encrypt/decrypt
- **Symmetric**: Same key for encryption and decryption
- **Asymmetric**: Different keys (public and private)"""
            },
            {
                "title": "Common Encryption Algorithms",
                "content": """# Algorithms
**Symmetric:**
- AES (Advanced Encryption Standard)
- DES (Data Encryption Standard)
- Blowfish

**Asymmetric:**
- RSA (Rivest-Shamir-Adleman)
- ECC (Elliptic Curve Cryptography)

**Hashing:**
- MD5 (deprecated)
- SHA-1 (deprecated)
- SHA-256"""
            }
        ],
        "questions": [
            {"q": "What is plaintext?", "opts": ["Encrypted data", "Unencrypted data", "A key", "A cipher"], "ans": 1},
            {"q": "Which is asymmetric encryption?", "opts": ["AES", "RSA", "DES", "Blowfish"], "ans": 1},
        ]
    },
    "Nhập môn lập trình": {
        "lessons": [
            {
                "title": "Lập Trình Là Gì",
                "content": """# Giới thiệu Lập Trình
Lập trình là quá trình viết hướng dẫn cho máy tính thực hiện công việc.
- Ngôn ngữ lập trình: Python, Java, C++, JavaScript
- Các khái niệm: Biến, kiểu dữ liệu, vòng lặp, hàm
- Quy trình: Viết code → Test → Debug
- Ứng dụng: Web, Mobile, Desktop, IoT"""
            },
            {
                "title": "Biến và Kiểu Dữ Liệu",
                "content": """# Biến và Kiểu Dữ Liệu
**Biến**: Vùng nhớ lưu trữ dữ liệu
```
x = 10          # Số nguyên
name = "An"     # Chuỗi
pi = 3.14       # Số thực
active = True   # Boolean
```

**Kiểu Dữ Liệu**:
- Integer: 10, 20, -5
- Float: 3.14, 2.5
- String: "Hello"
- Boolean: True, False
- List: [1, 2, 3]
- Dictionary: {"name": "An"}"""
            }
        ],
        "questions": [
            {"q": "Lập trình là gì?", "opts": ["Sửa máy", "Viết hướng dẫn cho máy", "Bán máy", "Học máy"], "ans": 1},
            {"q": "Biến dùng để làm gì?", "opts": ["Tạo vòng lặp", "Lưu dữ liệu", "In kết quả", "Kết nối mạng"], "ans": 1},
        ]
    },
    "Cấu trúc dữ liệu và giải thuật": {
        "lessons": [
            {
                "title": "Cấu Trúc Dữ Liệu Cơ Bản",
                "content": """# Cấu Trúc Dữ Liệu
- **Array/List**: Tập hợp phần tử cùng kiểu
- **Stack**: LIFO (Last In First Out)
- **Queue**: FIFO (First In First Out)
- **Linked List**: Danh sách liên kết
- **Tree**: Cấu trúc cây
- **Graph**: Đồ thị"""
            },
            {
                "title": "Giải Thuật Sắp Xếp",
                "content": """# Sorting Algorithms
- **Bubble Sort**: O(n²)
- **Selection Sort**: O(n²)
- **Insertion Sort**: O(n²)
- **Merge Sort**: O(n log n)
- **Quick Sort**: O(n log n) average
- **Heap Sort**: O(n log n)"""
            }
        ],
        "questions": [
            {"q": "Stack là gì?", "opts": ["FIFO", "LIFO", "LRU", "MRU"], "ans": 1},
            {"q": "Quick Sort độ phức tạp bao nhiêu?", "opts": ["O(n)", "O(n²)", "O(n log n)", "O(log n)"], "ans": 2},
        ]
    },
    "Hệ điều hành": {
        "lessons": [
            {
                "title": "Lịch Sử và Khái Niệm",
                "content": """# Hệ Điều Hành
Hệ điều hành (OS) là phần mềm quản lý tài nguyên máy tính.
- **Quản lý Process**: Lập lịch, điều phối
- **Quản lý Bộ Nhớ**: Cấp phát, tối ưu hóa
- **Quản lý File**: Lưu trữ, truy xuất
- **Bảo Mật**: Xác thực, phân quyền
- **Giao Diện Người Dùng**: GUI hoặc CLI"""
            },
            {
                "title": "Process và Thread",
                "content": """# Process và Thread
**Process:**
- Chương trình đang chạy
- Không chia sẻ bộ nhớ
- Chi phí tạo cao

**Thread:**
- Đơn vị nhỏ nhất chạy
- Chia sẻ bộ nhớ process
- Chi phí tạo thấp
- Context switching nhanh"""
            }
        ],
        "questions": [
            {"q": "Hệ điều hành là gì?", "opts": ["Phần cứng", "Quản lý tài nguyên", "Ứng dụng", "Trò chơi"], "ans": 1},
            {"q": "Khác biệt giữa Process và Thread?", "opts": ["Không khác", "Thread nhẹ hơn", "Process nhẹ hơn", "Không liên quan"], "ans": 1},
        ]
    }
}

def add_content():
    """Add content to courses"""
    try:
        added = 0
        skipped = 0
        
        for course_name, data in COURSES_CONTENT.items():
            course = db.query(Course).filter(
                Course.course_name == course_name
            ).first()
            
            if not course:
                print(f"⏭️  '{course_name}' not found")
                skipped += 1
                continue
            
            existing = db.query(Lesson).filter(Lesson.course_id == course.id).count()
            if existing > 0:
                print(f"✅ '{course_name}' ({existing} lessons)")
                continue
            
            print(f"📚 Creating '{course_name}'...")
            
            # Lessons
            for i, lesson_data in enumerate(data["lessons"]):
                lesson = Lesson(
                    course_id=course.id,
                    title=lesson_data["title"],
                    content=lesson_data["content"],
                    order=i + 1
                )
                db.add(lesson)
            
            db.flush()
            
            # Assessment
            assessment = Assessment(
                course_id=course.id,
                title=f"Quiz: {course_name}",
                description=f"Test knowledge on {course_name}",
                assessment_type=AssessmentType.QUIZ,
                passing_score=60,
                max_score=100
            )
            db.add(assessment)
            db.flush()
            
            # Questions
            for i, q_data in enumerate(data["questions"]):
                question = Question(
                    assessment_id=assessment.id,
                    question_text=q_data["q"],
                    question_type="multiple_choice",
                    option_a=q_data["opts"][0],
                    option_b=q_data["opts"][1],
                    option_c=q_data["opts"][2],
                    option_d=q_data["opts"][3],
                    correct_answer=chr(97 + q_data["ans"]),
                    points=1.0,
                    order=i + 1
                )
                db.add(question)
            
            db.commit()
            print(f"  ✓ {len(data['lessons'])} lessons + {len(data['questions'])} questions")
            added += 1
        
        print(f"\n✅ Added content to {added} courses")
        if skipped:
            print(f"⏭️  Skipped {skipped} courses (not found or already have content)")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    print("=" * 60)
    print("📚 Adding Realistic Content to More Courses")
    print("=" * 60)
    add_content()

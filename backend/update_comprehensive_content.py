#!/usr/bin/env python
"""Update comprehensive lesson and quiz content"""
from app.database import SessionLocal
from app.models import Course, Lesson, Assessment, Question

db = SessionLocal()

# ============================================================
# 1. NHẬP MÔN LẬP TRÌNH
# ============================================================
INTRO_PROGRAMMING_LESSONS = {
    "Lập Trình Là Gì": """
Lập trình là quá trình viết các hướng dẫn (code) để cho máy tính thực hiện những công việc cụ thể. 

🎯 Định nghĩa: Lập trình là việc sử dụng ngôn ngữ lập trình để tạo ra các chương trình máy tính.

📚 Các khái niệm cơ bản:
- Source Code: Mã nguồn được viết bằng ngôn ngữ lập trình mà con người có thể đọc được
- Compiler/Interpreter: Công cụ dịch source code thành ngôn ngữ máy (0 và 1)
- Algorithm: Các bước giải quyết một vấn đề cụ thể
- Data Structures: Cách tổ chức và lưu trữ dữ liệu

💡 Ví dụ thực tế:
- Các ứng dụng di động (Facebook, Instagram, TikTok)
- Website (Google, Amazon, Shopee)
- Phần mềm máy tính (Microsoft Office, Photoshop)
- Hệ thống quản lý (Ngân hàng, Bệnh viện)

🌐 Ngôn ngữ phổ biến:
- Python: Dễ học, phổ biến trong AI, Data Science
- JavaScript: Lập trình web, phát triển nhanh
- Java: Enterprise, Android, ứng dụng lớn
- C++: Hiệu suất cao, game development
- Go: Scalable, microservices

💼 Lợi ích của lập trình:
- Lương cao: Lập trình viên có mức lương cao trên thế giới
- Nhu cầu cao: Thiếu lập trình viên giỏi trên toàn thế giới
- Tính sáng tạo: Có thể tạo ra những sản phẩm mới
- Làm việc remote: Có thể làm việc từ bất kỳ đâu
    """,
    "Biến và Kiểu Dữ Liệu": """
Biến là một vùng bộ nhớ dùng để lưu trữ dữ liệu. Kiểu dữ liệu xác định loại dữ liệu mà biến có thể chứa.

📦 Khái niệm Biến:
- Tên biến: Cách gọi dữ liệu (VD: age, name, temperature)
- Giá trị: Dữ liệu được lưu trữ trong biến
- Kiểu dữ liệu: Xác định loại dữ liệu

🔢 Các Kiểu Dữ Liệu Chính:

1️⃣ Integer (Số nguyên)
   - Kiểu: int
   - Ví dụ: 25, -10, 1000
   - Sử dụng: Đếm, tính tuổi, số ID

2️⃣ Float (Số thực)
   - Kiểu: float, double
   - Ví dụ: 3.14, -2.5, 99.99
   - Sử dụng: Tính toán khoa học, giá cả, nhiệt độ

3️⃣ String (Chuỗi ký tự)
   - Kiểu: str
   - Ví dụ: "Hello", "Việt Nam", "123"
   - Sử dụng: Lưu tên, địa chỉ, tin nhắn

4️⃣ Boolean (Logic)
   - Kiểu: bool
   - Giá trị: True hoặc False
   - Sử dụng: Kiểm tra điều kiện, quyết định

💻 Ví dụ Python:
```python
# Khai báo biến
name = "Phạm Thành Tâm"      # String
age = 22                      # Integer
height = 1.75                 # Float
is_student = True             # Boolean

# In ra màn hình
print(name)      # Output: Phạm Thành Tâm
print(age + 5)   # Output: 27
print(height * 100)  # Output: 175.0
```

🎯 Quy tắc đặt tên biến:
- Bắt đầu bằng chữ hoặc underscore (_)
- Chứa chữ, số, underscore
- Không có khoảng trắng
- Viết thường với underscore (snake_case): user_name, student_id
- Không dùng từ khóa (if, for, while, etc.)

⚠️ Lỗi thường gặp:
- Sử dụng biến chưa khai báo
- Gán sai kiểu dữ liệu
- Tên biến không rõ ràng
    """,
    "Toán Tử và Phép Tính": """
Toán tử là ký hiệu được sử dụng để thực hiện các phép toán trên dữ liệu.

🔧 Toán Tử Số Học (Arithmetic Operators):
+  : Cộng          Ví dụ: 5 + 3 = 8
-  : Trừ           Ví dụ: 10 - 4 = 6
*  : Nhân          Ví dụ: 6 * 2 = 12
/  : Chia thường   Ví dụ: 10 / 3 = 3.333...
// : Chia lấy phần nguyên   Ví dụ: 10 // 3 = 3
%  : Chia lấy dư   Ví dụ: 10 % 3 = 1
** : Lũy thừa      Ví dụ: 2 ** 3 = 8

📊 Toán Tử So Sánh (Comparison Operators):
==  : Bằng         Ví dụ: 5 == 5 → True
!=  : Không bằng   Ví dụ: 5 != 3 → True
<   : Nhỏ hơn      Ví dụ: 3 < 5 → True
>   : Lớn hơn      Ví dụ: 10 > 5 → True
<=  : Nhỏ hơn hoặc bằng    Ví dụ: 5 <= 5 → True
>=  : Lớn hơn hoặc bằng    Ví dụ: 5 >= 5 → True

🔗 Toán Tử Logic (Logical Operators):
and : Cả hai điều kiện đều đúng
or  : Ít nhất một điều kiện đúng
not : Đảo ngược giá trị logic

💻 Ví dụ thực tế:
```python
# Toán tử số học
tien = 100000
gia_hang = 25000
so_luong = 3
tong = gia_hang * so_luong  # 75000
tien_con_lai = tien - tong  # 25000

# Toán tử so sánh
diem = 8.5
dau_diem = 8.0
dat = diem >= dau_diem  # True

# Toán tử logic
tuoi = 25
co_bang_cap = True
co_kinh_nghiem = True
phu_hop_viec = (tuoi >= 18) and (co_bang_cap) and (co_kinh_nghiem)  # True
```

⚙️ Thứ tự ưu tiên (Precedence):
1. ** (Lũy thừa)
2. *, /, //, % (Nhân, chia)
3. +, - (Cộng, trừ)
4. ==, !=, <, >, <=, >= (So sánh)
5. not, and, or (Logic)
    """,
    "Câu Lệnh Điều Kiện": """
Câu lệnh điều kiện (If-Else) cho phép chương trình đưa ra quyết định dựa trên các điều kiện.

🎯 Cấu trúc If-Else:

if (điều kiện):
    # Thực hiện nếu điều kiện đúng (True)
else:
    # Thực hiện nếu điều kiện sai (False)

📋 Các loại câu lệnh điều kiện:

1️⃣ IF Đơn giản:
```python
tuoi = 18
if tuoi >= 18:
    print("Bạn đủ tuổi học lái xe")
```

2️⃣ IF-ELSE:
```python
diem = 7.5
if diem >= 8:
    print("Đạt yêu cầu")
else:
    print("Chưa đạt yêu cầu")
```

3️⃣ IF-ELIF-ELSE (Nhiều điều kiện):
```python
diem = 8.5
if diem >= 9:
    print("Xếp loại A")
elif diem >= 8:
    print("Xếp loại B")
elif diem >= 7:
    print("Xếp loại C")
else:
    print("Xếp loại D")
```

4️⃣ Lồng IF (Nested IF):
```python
tuoi = 25
co_bang_cap = True
if tuoi >= 18:
    if co_bang_cap:
        print("Có thể ứng tuyển vị trí này")
    else:
        print("Cần có bằng cấp")
```

💡 Ví dụ thực tế - Hệ thống tính học bổng:
```python
diem_trung_binh = 8.2
tien_gia_dinh = 50000000

if diem_trung_binh >= 8.5:
    hoc_bong = 2000000
elif diem_trung_binh >= 8.0:
    hoc_bong = 1000000
else:
    hoc_bong = 0

if tien_gia_dinh < 100000000:
    hoc_bong = hoc_bong + 500000

print(f"Học bổng của bạn: {hoc_bong} đồng")
```

⚠️ Lỗi thường gặp:
- Quên dấu : sau if/else/elif
- Sai indentation (thụt lề)
- So sánh với = thay vì ==
- Lồng if quá sâu (khó đọc)

💪 Best practices:
- Giữ điều kiện đơn giản, dễ đọc
- Tránh lồng if quá sâu (max 3 cấp)
- Dùng biến có tên rõ ràng
- Thêm comment giải thích logic phức tạp
    """,
    "Vòng Lặp": """
Vòng lặp (Loop) cho phép bạn lặp lại một khối code nhiều lần mà không cần viết lại.

🔄 Hai loại vòng lặp chính:

1️⃣ FOR LOOP (Lặp một số lần biết trước):

Cú pháp:
```python
for biến in range(số_lần):
    # Code thực thi lặp lại
```

Ví dụ:
```python
# In số 1 đến 10
for i in range(1, 11):
    print(i)

# Lặp qua danh sách
sinh_vien = ["An", "Bình", "Cường", "Dũng"]
for name in sinh_vien:
    print(f"Xin chào {name}")

# Lặp với bước nhảy
for i in range(0, 10, 2):
    print(i)  # In: 0, 2, 4, 6, 8
```

2️⃣ WHILE LOOP (Lặp khi điều kiện đúng):

Cú pháp:
```python
while (điều kiện):
    # Code thực thi lặp lại
    # QUAN TRỌNG: Cần update điều kiện để tránh vòng lặp vô tận
```

Ví dụ:
```python
# Chơi game cho đến khi thua
is_playing = True
while is_playing:
    # Code chơi game
    is_playing = (thua == False)  # Update điều kiện

# Đếm ngược từ 5 đến 0
count = 5
while count >= 0:
    print(count)
    count = count - 1  # QUAN TRỌNG: Giảm count để tránh vòng lặp vô tận
```

🎛️ Lệnh điều khiển vòng lặp:

BREAK: Thoát khỏi vòng lặp
```python
for i in range(10):
    if i == 5:
        break  # Thoát khi i = 5
    print(i)  # In: 0, 1, 2, 3, 4
```

CONTINUE: Bỏ qua lần lặp hiện tại
```python
for i in range(5):
    if i == 2:
        continue  # Bỏ qua khi i = 2
    print(i)  # In: 0, 1, 3, 4
```

PASS: Không làm gì cả (placeholder)
```python
for i in range(5):
    if i == 2:
        pass  # Không làm gì
    print(i)
```

💡 Ví dụ thực tế - Tính tổng điểm của học sinh:
```python
diem_toan = [8, 7, 9, 8.5]
tong = 0
for diem in diem_toan:
    tong = tong + diem
trung_binh = tong / len(diem_toan)
print(f"Điểm trung bình: {trung_binh}")

# Ví dụ 2: Tìm sinh viên có điểm cao nhất
sinh_vien = {
    "An": 9.0,
    "Bình": 8.5,
    "Cường": 9.2,
    "Dũng": 8.0
}
diem_cao_nhat = 0
sinh_vien_gioi = ""
for name, diem in sinh_vien.items():
    if diem > diem_cao_nhat:
        diem_cao_nhat = diem
        sinh_vien_gioi = name
print(f"Sinh viên giỏi nhất: {sinh_vien_gioi} ({diem_cao_nhat})")
```

⚠️ Vòng lặp vô tận (Infinite Loop):
```python
# ❌ SAI - Vòng lặp vô tận!
while True:
    print("Chương trình chạy mãi mãi")
    # Không có cách để thoát

# ✅ ĐÚNG - Có cách để thoát
while True:
    leuoc = input("Nhập 'thoát' để dừng: ")
    if leua == "thoát":
        break
```

💪 Best practices:
- For loop: Khi biết trước số lần lặp
- While loop: Khi lặp dựa trên điều kiện
- Tránh vòng lặp quá phức tạp
- Comment giải thích logic lặp
- Kiểm tra điều kiện thoát trong while loop
    """
}

INTRO_PROGRAMMING_QUIZ = [
    {
        "question": "Lập trình là gì?",
        "options": [
            "A. Viết các hướng dẫn (code) để máy tính thực hiện công việc cụ thể",
            "B. Chỉ là một công việc dành cho những người thông minh",
            "C. Là quá trình sửa chữa máy tính",
            "D. Là việc sử dụng Microsoft Office"
        ],
        "correct": "A"
    },
    {
        "question": "Biến trong lập trình là gì?",
        "options": [
            "A. Một lệnh để in dữ liệu",
            "B. Một vùng bộ nhớ dùng để lưu trữ dữ liệu",
            "C. Một loại lỗi lập trình",
            "D. Một phần mềm máy tính"
        ],
        "correct": "B"
    },
    {
        "question": "Kiểu dữ liệu Integer được dùng để:",
        "options": [
            "A. Lưu trữ số thực như 3.14",
            "B. Lưu trữ số nguyên như 5, 10, -20",
            "C. Lưu trữ văn bản như 'Hello'",
            "D. Lưu trữ đúng/sai (True/False)"
        ],
        "correct": "B"
    },
    {
        "question": "Toán tử // trong Python là gì?",
        "options": [
            "A. Chia thường (10 / 3 = 3.333...)",
            "B. Chia lấy phần nguyên (10 // 3 = 3)",
            "C. Lũy thừa",
            "D. Mod (chia lấy dư)"
        ],
        "correct": "B"
    },
    {
        "question": "Câu lệnh IF được sử dụng để:",
        "options": [
            "A. Lặp lại code nhiều lần",
            "B. Khai báo một biến",
            "C. Đưa ra quyết định dựa trên điều kiện",
            "D. Thoát khỏi chương trình"
        ],
        "correct": "C"
    }
]

# ============================================================
# 2. CẤU TRÚC DỮ LIỆU VÀ GIẢI THUẬT
# ============================================================
DATA_STRUCTURES_LESSONS = {
    "Array và List": """
Array (Mảng) là một cấu trúc dữ liệu lưu trữ nhiều phần tử cùng kiểu dữ liệu.

📦 Khái niệm:
- Index: Vị trí của phần tử (bắt đầu từ 0)
- Length: Số lượng phần tử
- Element: Giá trị tại một vị trí

📋 Ví dụ:
```python
# Tạo list
numbers = [10, 20, 30, 40, 50]
names = ["An", "Bình", "Cường"]

# Truy cập phần tử
print(numbers[0])  # 10
print(names[2])    # "Cường"

# Thêm phần tử
numbers.append(60)

# Xóa phần tử
numbers.remove(30)

# Duyệt qua list
for num in numbers:
    print(num)

# Độ dài list
length = len(numbers)
```

⏱️ Độ phức tạp thời gian:
- Truy cập: O(1) - Instant
- Tìm kiếm: O(n) - Tuyến tính
- Thêm cuối: O(1) - Instant
- Thêm đầu: O(n) - Phải dịch chuyển
- Xóa: O(n) - Phải tìm kiếm trước

💡 Ứng dụng thực tế:
- Danh sách sinh viên
- Điểm của học sinh
- Danh sách sản phẩm trong giỏ hàng
    """,
    "Stack - Ngăn Xếp": """
Stack (Ngăn xếp) là cấu trúc dữ liệu LIFO: Last In First Out - Vào sau ra trước.

🔑 Đặc điểm:
- Chỉ thêm/xóa ở đầu (top)
- Hình ảnh: Xếp đĩa, mỗi lần lấy từ trên cùng

📊 Các phép toán:
PUSH: Thêm phần tử vào đầu
POP: Lấy phần tử từ đầu
PEEK: Xem phần tử ở đầu (không lấy)
IS_EMPTY: Kiểm tra rỗng

💻 Cài đặt:
```python
class Stack:
    def __init__(self):
        self.items = []
    
    def push(self, item):
        self.items.append(item)
    
    def pop(self):
        if not self.is_empty():
            return self.items.pop()
    
    def peek(self):
        if not self.is_empty():
            return self.items[-1]
    
    def is_empty(self):
        return len(self.items) == 0
    
    def size(self):
        return len(self.items)

# Sử dụng
stack = Stack()
stack.push(1)
stack.push(2)
stack.push(3)
print(stack.pop())  # 3
print(stack.peek()) # 2
```

💡 Ứng dụng thực tế:
- Undo/Redo trong editor
- Browser history (back button)
- Kiểm tra matching brackets: (){}[]
- Chuyển đổi infix sang postfix
    """,
    "Queue - Hàng Đợi": """
Queue (Hàng đợi) là cấu trúc dữ liệu FIFO: First In First Out - Vào trước ra trước.

🔑 Đặc điểm:
- Thêm ở cuối, lấy từ đầu
- Hình ảnh: Xếp hàng chờ, người vào trước ra trước

📊 Các phép toán:
ENQUEUE: Thêm phần tử vào cuối
DEQUEUE: Lấy phần tử từ đầu
PEEK: Xem phần tử ở đầu
IS_EMPTY: Kiểm tra rỗng

💻 Cài đặt:
```python
from collections import deque

# Tạo queue
queue = deque()

# Enqueue
queue.append(1)
queue.append(2)
queue.append(3)

# Dequeue
print(queue.popleft())  # 1
print(queue.popleft())  # 2

# Peek
print(queue[0])  # 3

# Kiểm tra rỗng
if len(queue) > 0:
    print("Queue không rỗng")
```

💡 Ứng dụng thực tế:
- Hệ thống in ấn (print queue)
- Customer service (chờ tư vấn viên)
- Giao hàng (phục vụ theo thứ tự)
- BFS (Breadth-First Search) algorithm
    """,
    "Linked List - Danh Sách Liên Kết": """
Linked List là cấu trúc dữ liệu mà mỗi node chứa dữ liệu và con trỏ đến node tiếp theo.

🔑 Đặc điểm:
- Mỗi node có: data (dữ liệu) + next (con trỏ)
- Kết nối: 1 → 2 → 3 → 4 → None

📊 Ưu điểm vs Nhược điểm:
✅ Ưu điểm:
- Dễ thêm/xóa ở đầu
- Kích thước linh hoạt

❌ Nhược điểm:
- Truy cập chậm (phải từ đầu)
- Dùng bộ nhớ cho con trỏ

💻 Cài đặt:
```python
class Node:
    def __init__(self, data):
        self.data = data
        self.next = None

class LinkedList:
    def __init__(self):
        self.head = None
    
    def insert_at_head(self, data):
        new_node = Node(data)
        new_node.next = self.head
        self.head = new_node
    
    def insert_at_end(self, data):
        new_node = Node(data)
        if not self.head:
            self.head = new_node
            return
        
        current = self.head
        while current.next:
            current = current.next
        current.next = new_node
    
    def display(self):
        current = self.head
        while current:
            print(current.data, end=" → ")
            current = current.next
        print("None")

# Sử dụng
ll = LinkedList()
ll.insert_at_end(1)
ll.insert_at_end(2)
ll.insert_at_end(3)
ll.display()  # 1 → 2 → 3 → None
```

💡 Ứng dụng thực tế:
- Danh sách phát (Music player)
- Breadth-First Search
- Undo functionality
    """,
    "Sorting - Sắp Xếp": """
Sorting là quá trình sắp xếp dữ liệu theo thứ tự tăng dần hoặc giảm dần.

📊 Các thuật toán sắp xếp phổ biến:

1️⃣ Bubble Sort - Sắp xếp nổi bọt
- Cơ chế: So sánh và hoán đổi từng cặp liền kề
- Độ phức tạp: O(n²)
- Khi dùng: Dữ liệu nhỏ, học tập

2️⃣ Selection Sort - Sắp xếp chọn
- Cơ chế: Chọn phần tử nhỏ nhất, đặt ở đầu
- Độ phức tạp: O(n²)
- Khi dùng: Dữ liệu nhỏ

3️⃣ Insertion Sort - Sắp xếp chèn
- Cơ chế: Chèn từng phần tử vào vị trí đúng
- Độ phức tạp: O(n²)
- Khi dùng: Dữ liệu nhỏ, gần sắp xếp

4️⃣ Merge Sort - Sắp xếp trộn
- Cơ chế: Chia đôi, sắp xếp từng nửa, trộn
- Độ phức tạp: O(n log n)
- Khi dùng: Dữ liệu lớn

5️⃣ Quick Sort - Sắp xếp nhanh
- Cơ chế: Chọn pivot, chia mảng, sắp xếp
- Độ phức tạp: O(n log n) bình quân
- Khi dùng: Dữ liệu lớn, thực tế

💻 Ví dụ Python:
```python
# Bubble Sort
def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(n - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr

# Python built-in
numbers = [5, 2, 8, 1, 9]
sorted_numbers = sorted(numbers)  # [1, 2, 5, 8, 9]
```

📊 So sánh hiệu suất:
Dữ liệu nhỏ (< 100): Bubble, Selection, Insertion
Dữ liệu lớn (> 1000): Merge Sort, Quick Sort
Dữ liệu rất lớn: Heap Sort, Counting Sort
    """
}

DATA_STRUCTURES_QUIZ = [
    {
        "question": "Array là gì?",
        "options": [
            "A. Một biến lưu trữ một giá trị",
            "B. Một cấu trúc dữ liệu lưu trữ nhiều phần tử cùng kiểu",
            "C. Một hàm trong lập trình",
            "D. Một lỗi lập trình"
        ],
        "correct": "B"
    },
    {
        "question": "Stack là LIFO có nghĩa là:",
        "options": [
            "A. Last In First Out - Vào sau ra trước",
            "B. Last Input Final Output",
            "C. Load In File Output",
            "D. List In First Operation"
        ],
        "correct": "A"
    },
    {
        "question": "Queue được sử dụng trong trường hợp:",
        "options": [
            "A. Undo/Redo trong editor",
            "B. Hệ thống in ấn (print queue)",
            "C. Browser history",
            "D. Matching brackets check"
        ],
        "correct": "B"
    },
    {
        "question": "Linked List so với Array, thế mạnh là:",
        "options": [
            "A. Truy cập nhanh hơn",
            "B. Dễ thêm/xóa ở đầu hơn",
            "C. Dùng ít bộ nhớ hơn",
            "D. Không cần biết kích thước trước"
        ],
        "correct": "B"
    },
    {
        "question": "Cho dữ liệu lớn (100,000 phần tử), nên dùng thuật toán sắp xếp nào?",
        "options": [
            "A. Bubble Sort",
            "B. Selection Sort",
            "C. Quick Sort hoặc Merge Sort",
            "D. Insertion Sort"
        ],
        "correct": "C"
    }
]

# ============================================================
# 3. WEB DEVELOPMENT VỚI REACT
# ============================================================
WEB_REACT_LESSONS = {
    "React Fundamentals": """
React là một thư viện JavaScript dùng để xây dựng giao diện người dùng (UI) một cách hiệu quả.

🎯 Khái niệm cơ bản:

1️⃣ Component
- Là một phần của UI (nút, form, danh sách, etc.)
- Có thể tái sử dụng
- Có thể có logic riêng

2️⃣ JSX
- Syntax hỗn hợp HTML + JavaScript
- Giúp viết code dễ đọc

3️⃣ Props
- Dữ liệu truyền từ component cha → component con
- Là read-only (không thay đổi được)

4️⃣ State
- Dữ liệu nội bộ của component
- Có thể thay đổi
- Khi state thay đổi, component re-render

📊 Ví dụ Component:
```jsx
// Component con nhận props
function Welcome(props) {
    return <h1>Xin chào, {props.name}!</h1>;
}

// Component cha truyền props
function App() {
    return <Welcome name="Tâm" />;
}
```

🔄 Vòng đời Component:
1. Mount: Component được tạo ra
2. Update: State/Props thay đổi
3. Unmount: Component bị xóa

💡 Tại sao dùng React?
- Hiệu suất cao (Virtual DOM)
- Component reusable
- Dễ debug
- Cộng đồng lớn, tài liệu nhiều

🚀 Cài đặt:
```bash
npx create-react-app my-app
cd my-app
npm start
```
    """,
    "Components và Props": """
Component là building block của React. Props là cách truyền dữ liệu.

📦 Hai loại Component:

1️⃣ Functional Component (hiện đại)
```jsx
function Greeting(props) {
    return <h1>Xin chào {props.name}</h1>;
}
```

2️⃣ Class Component (cũ)
```jsx
class Greeting extends React.Component {
    render() {
        return <h1>Xin chào {this.props.name}</h1>;
    }
}
```

📤 Props (Properties):
- Dữ liệu từ cha xuống con
- Immutable (không đổi)
- Dùng để tùy chỉnh component

💻 Ví dụ:
```jsx
// Component con
function StudentCard(props) {
    return (
        <div className="card">
            <h2>{props.name}</h2>
            <p>Điểm: {props.score}</p>
            <p>Lớp: {props.class}</p>
        </div>
    );
}

// Component cha
function App() {
    const students = [
        { name: "An", score: 9.0, class: "10A1" },
        { name: "Bình", score: 8.5, class: "10A1" }
    ];
    
    return (
        <div>
            {students.map((student, index) => (
                <StudentCard 
                    key={index}
                    name={student.name}
                    score={student.score}
                    class={student.class}
                />
            ))}
        </div>
    );
}
```

🎯 Default Props:
```jsx
function Button(props) {
    return <button>{props.label}</button>;
}

Button.defaultProps = {
    label: "Click me"
};
```

✔️ PropTypes (Validation):
```jsx
import PropTypes from 'prop-types';

function UserCard(props) {
    return <h1>{props.name}, {props.age} tuổi</h1>;
}

UserCard.propTypes = {
    name: PropTypes.string.isRequired,
    age: PropTypes.number.isRequired
};
```

💡 Best practices:
- Đặt tên props rõ ràng
- Dùng PropTypes để validate
- Tránh nested component quá sâu
- Tách component thành nhiều file nhỏ
    """,
    "State và Hooks": """
State là dữ liệu có thể thay đổi của component. Hooks là cách quản lý state trong functional components.

🪝 useState Hook:
```jsx
import { useState } from 'react';

function Counter() {
    // Khai báo state
    const [count, setCount] = useState(0);
    // count: giá trị hiện tại
    // setCount: hàm cập nhật state
    
    return (
        <div>
            <p>Số lần click: {count}</p>
            <button onClick={() => setCount(count + 1)}>
                Click me
            </button>
        </div>
    );
}
```

📝 State trong Form:
```jsx
function LoginForm() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    
    const handleSubmit = (e) => {
        e.preventDefault();
        console.log('Email:', email, 'Password:', password);
    };
    
    return (
        <form onSubmit={handleSubmit}>
            <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Email"
            />
            <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Password"
            />
            <button type="submit">Đăng nhập</button>
        </form>
    );
}
```

🎣 useEffect Hook:
```jsx
import { useEffect } from 'react';

function DataFetcher() {
    const [data, setData] = useState(null);
    
    // Chạy một lần khi component mount
    useEffect(() => {
        fetch('/api/data')
            .then(res => res.json())
            .then(data => setData(data));
    }, []); // Empty dependency array
    
    return <div>{data ? JSON.stringify(data) : 'Loading...'}</div>;
}
```

⚠️ Dependency Array:
- [] : Chạy một lần khi mount
- [value] : Chạy khi value thay đổi
- Không có: Chạy mỗi lần render

🎯 Multiple States:
```jsx
function UserProfile() {
    const [name, setName] = useState('');
    const [age, setAge] = useState(0);
    const [city, setCity] = useState('');
    
    return (
        <div>
            <p>Tên: {name}</p>
            <p>Tuổi: {age}</p>
            <p>Thành phố: {city}</p>
        </div>
    );
}
```

💡 Best practices:
- Một state cho một giá trị
- Tránh prop drilling (truyền props quá sâu)
- Dùng Context API hoặc Redux cho state toàn cục
- Cleanup effects nếu cần
    """,
    "useEffect và Lifecycle": """
useEffect Hook cho phép thực hiện side effects trong functional components.

🔄 Lifecycle của Component:

1️⃣ Mounting (Sinh ra)
- Component được tạo
- Props và State khởi tạo
- useEffect chạy (dependency = [])

2️⃣ Updating (Cập nhật)
- State/Props thay đổi
- Component re-render
- useEffect chạy (nếu dependency matching)

3️⃣ Unmounting (Chết)
- Component bị xóa khỏi DOM
- Cleanup function chạy

💻 Các ví dụ useEffect:

**Fetch data:**
```jsx
function UserList() {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    
    useEffect(() => {
        fetch('/api/users')
            .then(res => res.json())
            .then(data => {
                setUsers(data);
                setLoading(false);
            });
    }, []);
    
    return loading ? <p>Loading...</p> : <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

**Timer:**
```jsx
function Timer() {
    const [seconds, setSeconds] = useState(0);
    
    useEffect(() => {
        const interval = setInterval(() => {
            setSeconds(s => s + 1);
        }, 1000);
        
        // Cleanup: xóa interval khi unmount
        return () => clearInterval(interval);
    }, []);
    
    return <p>Đã trôi: {seconds} giây</p>;
}
```

**Window resize listener:**
```jsx
function WindowSize() {
    const [width, setWidth] = useState(window.innerWidth);
    
    useEffect(() => {
        const handleResize = () => setWidth(window.innerWidth);
        
        window.addEventListener('resize', handleResize);
        
        return () => window.removeEventListener('resize', handleResize);
    }, []);
    
    return <p>Chiều rộng: {width}px</p>;
}
```

📊 Dependency Array Rules:
```jsx
// Chạy mỗi lần render (⚠️ Tránh!)
useEffect(() => { });

// Chạy một lần (mount)
useEffect(() => { }, []);

// Chạy khi dependency thay đổi
useEffect(() => { }, [dependency]);

// Chạy mỗi lần render (không recommended)
useEffect(() => { }, [dependency1, dependency2]);
```

⚡ Performance tip:
```jsx
function SearchUsers() {
    const [query, setQuery] = useState('');
    const [results, setResults] = useState([]);
    
    useEffect(() => {
        // Chỉ search khi query thay đổi
        if (query.length > 2) {
            fetch(`/api/search?q=${query}`)
                .then(res => res.json())
                .then(data => setResults(data));
        }
    }, [query]); // Chỉ chạy khi query thay đổi
    
    return (
        <div>
            <input value={query} onChange={(e) => setQuery(e.target.value)} />
            <ul>{results.map(r => <li key={r.id}>{r.name}</li>)}</ul>
        </div>
    );
}
```
    """,
    "React Router": """
React Router là thư viện để tạo Single Page Application (SPA) với multiple pages.

🛣️ Cài đặt:
```bash
npm install react-router-dom
```

📐 Cấu trúc cơ bản:
```jsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import About from './pages/About';
import NotFound from './pages/NotFound';

function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/about" element={<About />} />
                <Route path="*" element={<NotFound />} />
            </Routes>
        </BrowserRouter>
    );
}
```

🔗 Navigation:
```jsx
import { Link, useNavigate } from 'react-router-dom';

function Navigation() {
    const navigate = useNavigate();
    
    return (
        <nav>
            <Link to="/">Home</Link>
            <Link to="/about">About</Link>
            <button onClick={() => navigate('/products')}>Go to Products</button>
        </nav>
    );
}
```

📝 Dynamic Routes:
```jsx
<Routes>
    <Route path="/user/:id" element={<UserDetail />} />
    <Route path="/product/:id/review/:reviewId" element={<ReviewDetail />} />
</Routes>

// Sử dụng params
import { useParams } from 'react-router-dom';

function UserDetail() {
    const { id } = useParams();
    return <h1>User ID: {id}</h1>;
}
```

🔍 Query Strings:
```jsx
import { useSearchParams } from 'react-router-dom';

function SearchPage() {
    const [searchParams] = useSearchParams();
    const query = searchParams.get('q');
    
    return <h1>Searching for: {query}</h1>;
}

// URL: /search?q=javascript&category=tutorials
```

🚀 Nested Routes:
```jsx
<Routes>
    <Route path="/dashboard" element={<Dashboard />}>
        <Route path="overview" element={<Overview />} />
        <Route path="analytics" element={<Analytics />} />
    </Route>
</Routes>
```

💡 Best practices:
- Tách components thành từng file
- Tổ chức routes rõ ràng
- Dùng dynamic routes cho detail pages
- Implement 404 page
- Tối ưu code splitting với lazy loading
    """
}

WEB_REACT_QUIZ = [
    {
        "question": "React là gì?",
        "options": [
            "A. Một ngôn ngữ lập trình",
            "B. Một framework web",
            "C. Một thư viện JavaScript để xây dựng UI",
            "D. Một cơ sở dữ liệu"
        ],
        "correct": "C"
    },
    {
        "question": "Props trong React dùng để:",
        "options": [
            "A. Lưu trữ dữ liệu thay đổi của component",
            "B. Truyền dữ liệu từ component cha đến component con",
            "C. Tạo animation",
            "D. Kết nối tới database"
        ],
        "correct": "B"
    },
    {
        "question": "State khác Props ở chỗ:",
        "options": [
            "A. State là read-only, Props có thể thay đổi",
            "B. State có thể thay đổi, Props là read-only",
            "C. Không có sự khác biệt",
            "D. State dùng cho class component, Props dùng cho functional"
        ],
        "correct": "B"
    },
    {
        "question": "useState Hook được sử dụng để:",
        "options": [
            "A. Tạo effect khi component mount",
            "B. Quản lý state trong functional components",
            "C. Navigation giữa các trang",
            "D. Lấy URL parameters"
        ],
        "correct": "B"
    },
    {
        "question": "useEffect Hook với dependency array rỗng [] sẽ:",
        "options": [
            "A. Chạy mỗi lần component render",
            "B. Chạy một lần khi component mount",
            "C. Chạy khi bất kỳ state thay đổi",
            "D. Không bao giờ chạy"
        ],
        "correct": "B"
    }
]

# Update lessons
def update_lessons_and_quizzes():
    """Update all lessons with comprehensive content"""
    
    print("🔄 Cập nhật nội dung bài học...")
    
    # 1. Update Intro Programming
    course = db.query(Course).filter(Course.course_name == "Nhập môn lập trình").first()
    if course:
        lessons = db.query(Lesson).filter(Lesson.course_id == course.id).all()
        for lesson in lessons:
            if lesson.title in INTRO_PROGRAMMING_LESSONS:
                lesson.content = INTRO_PROGRAMMING_LESSONS[lesson.title]
                db.commit()
                print(f"  ✅ {lesson.title}")
        
        # Update quiz
        quiz = db.query(Assessment).filter(Assessment.course_id == course.id).first()
        if quiz:
            questions = db.query(Question).filter(Question.assessment_id == quiz.id).all()
            for i, q in enumerate(questions):
                if i < len(INTRO_PROGRAMMING_QUIZ):
                    q_data = INTRO_PROGRAMMING_QUIZ[i]
                    q.question_text = q_data["question"]
                    q.is_active = True
            db.commit()
            print(f"  ✅ Quiz questions updated")
    
    # 2. Update Data Structures
    course = db.query(Course).filter(Course.course_name == "Cấu trúc dữ liệu và giải thuật").first()
    if course:
        lessons = db.query(Lesson).filter(Lesson.course_id == course.id).all()
        for lesson in lessons:
            if lesson.title in DATA_STRUCTURES_LESSONS:
                lesson.content = DATA_STRUCTURES_LESSONS[lesson.title]
                db.commit()
                print(f"  ✅ {lesson.title}")
        
        quiz = db.query(Assessment).filter(Assessment.course_id == course.id).first()
        if quiz:
            questions = db.query(Question).filter(Question.assessment_id == quiz.id).all()
            for i, q in enumerate(questions):
                if i < len(DATA_STRUCTURES_QUIZ):
                    q_data = DATA_STRUCTURES_QUIZ[i]
                    q.question_text = q_data["question"]
                    q.is_active = True
            db.commit()
            print(f"  ✅ Quiz questions updated")
    
    # 3. Update Web React
    course = db.query(Course).filter(Course.course_name == "Web Development với React").first()
    if course:
        lessons = db.query(Lesson).filter(Lesson.course_id == course.id).all()
        for lesson in lessons:
            if lesson.title in WEB_REACT_LESSONS:
                lesson.content = WEB_REACT_LESSONS[lesson.title]
                db.commit()
                print(f"  ✅ {lesson.title}")
        
        quiz = db.query(Assessment).filter(Assessment.course_id == course.id).first()
        if quiz:
            questions = db.query(Question).filter(Question.assessment_id == quiz.id).all()
            for i, q in enumerate(questions):
                if i < len(WEB_REACT_QUIZ):
                    q_data = WEB_REACT_QUIZ[i]
                    q.question_text = q_data["question"]
                    q.is_active = True
            db.commit()
            print(f"  ✅ Quiz questions updated")
    
    print("\n✨ Hoàn thành cập nhật nội dung!")

if __name__ == "__main__":
    update_lessons_and_quizzes()
    db.close()

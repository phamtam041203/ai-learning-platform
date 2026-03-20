import requests

BASE_URL = "http://localhost:8000/api"

def test_my_courses():
    # Login first
    print("Logging in...")
    login_response = requests.post(f"{BASE_URL}/auth/login", data={
        "username": "quiztest@vanlanguni.vn",
        "password": "123456"
    })
    
    if login_response.status_code != 200:
        print(f"Login failed: {login_response.status_code}")
        print(login_response.text)
        return
    
    token = login_response.json()["access_token"]
    print(f"Logged in successfully")
    
    # Test /courses/my-courses
    print("\nTesting GET /courses/my-courses")
    headers = {"Authorization": f"Bearer {token}"}
    
    response = requests.get(f"{BASE_URL}/courses/my-courses", headers=headers)
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"Courses loaded: {len(data)} courses")
        for i, enrollment in enumerate(data):
            print(f"\n  Course {i+1}:")
            print(f"    - Enrollment ID: {enrollment.get('enrollment_id')}")
            if enrollment.get('course'):
                print(f"    - Course ID: {enrollment['course'].get('id')}")
                print(f"    - Course Name: {enrollment['course'].get('course_name')}")
                print(f"    - Course Code: {enrollment['course'].get('course_code')}")
            print(f"    - Progress: {enrollment.get('progress')}%")
            print(f"    - Completed: {enrollment.get('completed_lessons')}/{enrollment.get('total_lessons')}")
    else:
        print(f"Failed: {response.status_code}")
        print(response.text)

if __name__ == "__main__":
    test_my_courses()

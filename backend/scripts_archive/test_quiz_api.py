"""
Test quiz API endpoints
"""
import requests
import json

BASE_URL = "http://localhost:8000"

# Login first to get token
def login():
    response = requests.post(f"{BASE_URL}/api/auth/login", json={
        "email": "quiztest@vanlanguni.vn",
        "password": "123456"
    })
    if response.status_code == 200:
        data = response.json()
        return data['access_token']
    else:
        print(f"Login failed: {response.status_code}")
        print(response.text)
        return None

# Test get quiz
def test_get_quiz(token):
    headers = {"Authorization": f"Bearer {token}"}
    lesson_file = "Lecture 00 - Course Introduction.pdf"
    
    print(f"\n1. Testing GET /api/lessons/{lesson_file}/quiz")
    response = requests.get(
        f"{BASE_URL}/api/lessons/{lesson_file}/quiz",
        headers=headers
    )
    
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Quiz loaded: {data['title']}")
        print(f"   Questions: {data['total_questions']}")
        return data
    else:
        print(f"❌ Error: {response.text}")
        return None

# Test submit quiz
def test_submit_quiz(token):
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    lesson_file = "Lecture 00 - Course Introduction.pdf"
    
    # Sample answers (question_id -> option_index)
    answers = {
        1: 1,  # Question 1, option B (index 1)
        2: 2,  # Question 2, option C (index 2)
        3: 1,  # Question 3, option B (index 1)
        4: 1,  # Question 4, option B (index 1)
        5: 2   # Question 5, option C (index 2)
    }
    
    print(f"\n2. Testing POST /api/lessons/{lesson_file}/quiz/submit")
    print(f"Answers: {answers}")
    
    response = requests.post(
        f"{BASE_URL}/api/lessons/{lesson_file}/quiz/submit",
        headers=headers,
        json=answers
    )
    
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Quiz submitted successfully!")
        print(f"   Score: {data['score']}%")
        print(f"   Correct: {data['correct_count']}/{data['total_questions']}")
        print(f"   Passed: {data['passed']}")
        print(f"   Message: {data['message']}")
        return data
    else:
        print(f"❌ Error: {response.text}")
        return None

if __name__ == "__main__":
    print("🧪 Testing Quiz API Endpoints")
    print("=" * 50)
    
    # Login
    print("\n0. Logging in...")
    token = login()
    
    if not token:
        print("❌ Cannot proceed without token")
        exit(1)
    
    print(f"✅ Token obtained: {token[:20]}...")
    
    # Test get quiz
    quiz_data = test_get_quiz(token)
    
    # Test submit quiz
    if quiz_data:
        result = test_submit_quiz(token)
    
    print("\n" + "=" * 50)
    print("✅ Test completed!")

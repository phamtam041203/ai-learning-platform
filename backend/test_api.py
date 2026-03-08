import requests
import json

# Test login
print("Testing login...")
login_resp = requests.post('http://localhost:8000/api/auth/login', json={
    'email': 'tam.2174802010372@vanlanguni.vn',
    'password': '123456'
})

if login_resp.status_code == 200:
    token = login_resp.json()['access_token']
    print('✅ Login successful')
    print('Token:', token[:50] + '...')
    
    # Test specialization-courses endpoint
    print("\nTesting /api/student/specialization-courses...")
    courses_resp = requests.get('http://localhost:8000/api/student/specialization-courses',
        headers={'Authorization': f'Bearer {token}'}
    )
    
    print('Status:', courses_resp.status_code)
    if courses_resp.status_code == 200:
        courses = courses_resp.json()
        print('Total courses returned:', len(courses))
        
        enrolled = [c for c in courses if c.get('is_enrolled')]
        print('Enrolled courses:', len(enrolled))
        
        if courses:
            print('\nFirst course structure:')
            print(json.dumps(courses[0], indent=2, default=str))
        
        if enrolled:
            print('\nFirst 3 enrolled courses:')
            for c in enrolled[:3]:
                print(f"  - {c.get('course_name')} (is_enrolled: {c.get('is_enrolled')}, progress: {c.get('progress')})")
    else:
        print('Error:', courses_resp.json())
else:
    print('Login failed:', login_resp.status_code, login_resp.text)

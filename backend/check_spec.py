from app.database import SessionLocal
from app.models import User, StudentProfile

db = SessionLocal()
user = db.query(User).filter(User.email == 'tam.2174802010372@vanlanguni.vn').first()
if user:
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == user.id).first()
    if profile:
        print(f'Specialization: "{profile.specialization}"')
        print(f'Type: {type(profile.specialization).__name__}')
        print(f'Is None: {profile.specialization is None}')
        print(f'Repr: {repr(profile.specialization)}')
    else:
        print('No profile')
else:
    print('No user')
db.close()

import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';

import LandingPage from './pages/Landing/LandingPage';
import LoginPage from './pages/Auth/LoginPage';
import RegisterPage from './pages/Auth/RegisterPage';
import TeamsCallbackPage from './pages/Auth/TeamsCallbackPage';
import TeamsCompleteProfilePage from './pages/Auth/TeamsCompleteProfilePage';
import TeacherDashboard from './pages/teacher/TeacherDashboard';
import TeacherDashboardPage from './pages/teacher/DashboardPage';
import ContentPage from './pages/teacher/ContentPage';
import StudentsPage from './pages/teacher/StudentsPage';
import AnalyticsPage from './pages/teacher/AnalyticsPage';
import EssayReviewPage from './pages/teacher/EssayReviewPage';
import CourseDetailPage from './pages/teacher/CourseDetailPage';
import QuizManagerPage from './pages/teacher/QuizManagerPage';
import DashboardPage from './pages/student/DashboardPage.jsx';
import CourseDetail from './pages/student/CourseDetail.jsx';
import CoursesPage from './pages/student/CoursesPage.jsx';
import BrowseCoursesPage from './pages/student/BrowseCoursesPage.jsx';
import ProfilePage from './pages/student/ProfilePage.jsx';
import CourseLessonsPage from './pages/student/CourseLessonsPage.jsx';
import LessonPage from './pages/student/LessonPage.jsx';
import WebDevCoursePage from './pages/student/WebDevCoursePage.jsx';
import RecommendationsPage from './pages/student/RecommendationsPage.jsx';
import GradesPage from './pages/student/GradesPage.jsx';
import ProgressPage from './pages/student/ProgressPage.jsx';
import ChatbotPage from './pages/student/ChatbotPage.jsx';
import AIAdvisorPage from './pages/student/AIAdvisorPage.jsx';
import StudentRoadmapPage from './pages/student/StudentRoadmapPage.jsx';
import CertificatePage from './pages/student/CertificatePage.jsx';
import AdminDashboard from './pages/admin/AdminDashboard.jsx';
import AdminProgressPage from './pages/admin/AdminProgressPage.jsx';
import StudentTutorGateway from './components/StudentTutorGateway.jsx';

function App() {
  return (
    <BrowserRouter>
      <StudentTutorGateway />
      <Routes>
        {/* Public */}
        <Route path="/" element={<LandingPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/auth/teams/callback" element={<TeamsCallbackPage />} />
        <Route path="/auth/teams/complete-profile" element={<TeamsCompleteProfilePage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/register/teacher" element={<Navigate to="/login" replace />} />

        {/* Protected - Student */}
        <Route path="/student/dashboard" element={<DashboardPage />} />
        <Route path="/student/courses" element={<CoursesPage />} />
        <Route path="/student/browse-courses" element={<BrowseCoursesPage />} />
        <Route path="/student/recommendations" element={<RecommendationsPage />} />
        <Route path="/student/grades" element={<GradesPage />} />
        <Route path="/student/progress" element={<ProgressPage />} />
        <Route path="/student/skill-assessment" element={<Navigate to="/student/progress" replace />} />
        <Route path="/student/roadmap" element={<StudentRoadmapPage />} />
        <Route path="/student/certificate" element={<CertificatePage />} />
        <Route path="/student/chatbot" element={<ChatbotPage />} />
        <Route path="/student/ai-advisor" element={<AIAdvisorPage />} />
        <Route path="/student/courses/web-dev" element={<WebDevCoursePage />} />
        <Route path="/student/course/:courseId" element={<CourseDetail />} />
        <Route path="/student/courses/:courseId/lessons" element={<CourseLessonsPage />} />
        <Route path="/student/courses/:courseId/lessons/:lessonId" element={<LessonPage />} />
        <Route path="/student/profile" element={<ProfilePage />} />
        
        {/* Protected - Teacher */}
        <Route path="/teacher" element={<TeacherDashboard />} />
        <Route path="/teacher/dashboard" element={<TeacherDashboardPage />} />
        <Route path="/teacher/content" element={<ContentPage />} />
        <Route path="/teacher/courses/:courseId" element={<CourseDetailPage />} />
        <Route path="/teacher/courses/:courseId/quizzes" element={<QuizManagerPage />} />
        <Route path="/teacher/students" element={<StudentsPage />} />
        <Route path="/teacher/analytics" element={<AnalyticsPage />} />
        <Route path="/teacher/essays" element={<EssayReviewPage />} />
        <Route path="/teacher/courses/:courseId/essays" element={<EssayReviewPage />} />

        {/* Protected - Admin */}
        <Route path="/admin/dashboard" element={<AdminDashboard />} />
        <Route path="/admin/progress" element={<AdminProgressPage />} />

        {/* 404 */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
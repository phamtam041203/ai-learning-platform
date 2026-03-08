import { useMemo } from 'react';
import { matchPath, useLocation } from 'react-router-dom';
import LessonAssistant from './LessonAssistant';

const STUDENT_PAGE_LABELS = {
  '/student/dashboard': {
    title: 'Bảng điều khiển học tập',
    description: 'Hỏi nhanh về kế hoạch học, ưu tiên tiếp theo và cách cải thiện tiến độ.'
  },
  '/student/courses': {
    title: 'Khóa học của bạn',
    description: 'Hỏi về thứ tự học, cách chọn khóa học và chiến lược hoàn thành môn.'
  },
  '/student/browse-courses': {
    title: 'Khám phá khóa học',
    description: 'Hỏi về khóa học nên đăng ký, độ phù hợp và lộ trình tiếp theo.'
  },
  '/student/recommendations': {
    title: 'Gợi ý học tập',
    description: 'Hỏi về lý do được gợi ý khóa học và cách tận dụng các đề xuất này.'
  },
  '/student/grades': {
    title: 'Kết quả học tập',
    description: 'Hỏi cách cải thiện điểm số, ôn tập và xử lý phần còn yếu.'
  },
  '/student/progress': {
    title: 'Tiến độ học tập',
    description: 'Hỏi nên ưu tiên chặng nào, môn nào để tăng tiến độ nhanh hơn.'
  },
  '/student/roadmap': {
    title: 'Lộ trình cá nhân',
    description: 'Hỏi về hướng đi tiếp theo, kỹ năng cần bổ sung và mục tiêu ngắn hạn.'
  },
  '/student/chatbot': {
    title: 'Khu vực AI hỗ trợ',
    description: 'Bạn có thể tiếp tục đặt câu hỏi học tập tổng quát tại đây.'
  },
  '/student/ai-advisor': {
    title: 'AI Advisor',
    description: 'Hỏi thêm về chiến lược học, động lực và định hướng cá nhân hóa.'
  },
  '/student/profile': {
    title: 'Hồ sơ cá nhân',
    description: 'Hỏi về cách tối ưu mục tiêu học tập và kế hoạch phát triển.'
  }
};

const StudentTutorGateway = () => {
  const location = useLocation();

  const isStudentRoute = location.pathname.startsWith('/student/');
  const lessonMatch = matchPath('/student/courses/:courseId/lessons/:lessonId', location.pathname);

  const pageMeta = useMemo(() => {
    return STUDENT_PAGE_LABELS[location.pathname] || {
      title: 'AI Tutor 24/7',
      description: 'Hỏi về học tập, định hướng môn học và kế hoạch cải thiện tiến độ.'
    };
  }, [location.pathname]);

  if (!isStudentRoute || lessonMatch) {
    return null;
  }

  return (
    <LessonAssistant
      mode="advisor"
      lessonTitle={pageMeta.title}
      lessonDescription={pageMeta.description}
    />
  );
};

export default StudentTutorGateway;
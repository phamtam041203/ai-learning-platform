const toNumber = (value) => {
  const numericValue = Number(value);
  return Number.isFinite(numericValue) ? numericValue : null;
};

export const convertScore10ToGpa4 = (score10) => {
  if (score10 == null) {
    return 0;
  }

  if (score10 >= 9.0) return 4.0;
  if (score10 >= 8.5) return 3.7;
  if (score10 >= 8.0) return 3.5;
  if (score10 >= 7.0) return 3.0;
  if (score10 >= 6.5) return 2.5;
  if (score10 >= 5.5) return 2.0;
  if (score10 >= 5.0) return 1.5;
  if (score10 >= 4.0) return 1.0;
  return 0;
};

export const normalizeRecommendation = (recommendation = {}) => {
  const courseName = recommendation.course_name || recommendation.title || 'Khóa học được đề xuất';
  const description = recommendation.reason
    || recommendation.description
    || recommendation.reasons?.[0]
    || 'Gợi ý này được tạo dựa trên hồ sơ học tập hiện tại của bạn.';

  return {
    id: recommendation.id,
    course_id: recommendation.course_id || recommendation.id,
    course_code: recommendation.course_code || recommendation.major || 'AI',
    course_name: courseName,
    title: courseName,
    reason: description,
    description,
    level: recommendation.level || recommendation.major || 'Đề xuất AI',
    major: recommendation.major || recommendation.level || 'Chung',
    credit_hours: recommendation.credit_hours || 0,
    score: recommendation.score || 0,
    reasons: recommendation.reasons || [],
    icon: recommendation.icon || '📚',
    color: recommendation.color || '#b91c1c'
  };
};

export const normalizeRecommendations = (recommendations = []) => {
  return recommendations.map(normalizeRecommendation);
};

export const buildGradesSnapshotFromEnrollments = (enrollments = []) => {
  const grades = enrollments
    .filter((enrollment) => enrollment?.course)
    .map((enrollment) => {
      const total = toNumber(enrollment.grades?.total);
      const midterm = toNumber(enrollment.grades?.midterm);
      const final = toNumber(enrollment.grades?.final);
      const assignment = toNumber(enrollment.grades?.assignment);

      return {
        id: enrollment.course.id || enrollment.enrollment_id,
        enrollment_id: enrollment.enrollment_id,
        course_code: enrollment.course.course_code,
        course_name: enrollment.course.course_name,
        credits: enrollment.course.credit_hours || 0,
        progress: enrollment.progress || 0,
        status: enrollment.status,
        grade_letter: enrollment.grades?.letter || '-',
        scores: {
          midterm,
          final,
          assignment,
          total
        }
      };
    });

  const gradedCourses = grades.filter((grade) => grade.scores.total != null);
  const totalCredits = gradedCourses.reduce((sum, grade) => sum + (grade.credits || 0), 0);
  const average10 = gradedCourses.length
    ? gradedCourses.reduce((sum, grade) => sum + grade.scores.total, 0) / gradedCourses.length
    : 0;
  const gpa4 = gradedCourses.length
    ? gradedCourses.reduce((sum, grade) => sum + convertScore10ToGpa4(grade.scores.total), 0) / gradedCourses.length
    : 0;

  return {
    grades,
    summary: {
      gpa_4: gpa4.toFixed(2),
      average_10: average10.toFixed(2),
      total_credits: totalCredits,
      passed: gradedCourses.filter((grade) => grade.scores.total >= 5).length,
      highest_score: gradedCourses.length
        ? Math.max(...gradedCourses.map((grade) => grade.scores.total))
        : 0,
      completed_courses: enrollments.filter((enrollment) => (enrollment.progress || 0) >= 100).length,
      total_courses: enrollments.length
    }
  };
};
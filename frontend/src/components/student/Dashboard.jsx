// frontend/src/components/student/Dashboard.jsx
import { useState, useEffect } from 'react';
import { 
  BookOpen, 
  TrendingUp, 
  Clock, 
  Award,
  ChevronRight,
  Sparkles
} from 'lucide-react';
import { api } from '../../services/api';

const StatCard = ({ icon: Icon, title, value, subtitle, color }) => (
  <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition">
    <div className="flex items-center justify-between mb-4">
      <div className={`p-3 rounded-lg ${color}`}>
        <Icon className="w-6 h-6 text-white" />
      </div>
      <span className="text-sm text-gray-500">{subtitle}</span>
    </div>
    <h3 className="text-2xl font-bold text-gray-800">{value}</h3>
    <p className="text-sm text-gray-600 mt-1">{title}</p>
  </div>
);

const RecommendationCard = ({ material, onView }) => (
  <div className="bg-white rounded-lg p-4 border border-gray-200 hover:border-blue-400 hover:shadow-md transition cursor-pointer"
       onClick={() => onView(material)}>
    <div className="flex items-start justify-between">
      <div className="flex-1">
        <div className="flex items-center gap-2 mb-2">
          <span className={`px-2 py-1 rounded text-xs font-medium
            ${material.difficulty === 1 ? 'bg-green-100 text-green-700' :
              material.difficulty === 2 ? 'bg-blue-100 text-blue-700' :
              material.difficulty === 3 ? 'bg-yellow-100 text-yellow-700' :
              'bg-red-100 text-red-700'}`}>
            Cấp độ {material.difficulty}
          </span>
          <span className="text-xs text-gray-500">
            {material.estimated_time} phút
          </span>
        </div>
        <h4 className="font-semibold text-gray-800 mb-1">{material.title}</h4>
        <p className="text-sm text-gray-600 line-clamp-2">{material.description}</p>
        
        <div className="flex items-center gap-2 mt-3">
          <div className="flex-1 bg-gray-200 rounded-full h-2">
            <div 
              className="bg-blue-500 h-2 rounded-full transition-all"
              style={{ width: `${material.score * 100}%` }}
            />
          </div>
          <span className="text-xs font-medium text-gray-700">
            {Math.round(material.score * 100)}% phù hợp
          </span>
        </div>
      </div>
      <ChevronRight className="w-5 h-5 text-gray-400 ml-4" />
    </div>
  </div>
);

const ActivityItem = ({ activity }) => (
  <div className="flex items-center gap-3 p-3 hover:bg-gray-50 rounded-lg transition">
    <div className={`w-10 h-10 rounded-full flex items-center justify-center
      ${activity.type === 'complete' ? 'bg-green-100' :
        activity.type === 'view' ? 'bg-blue-100' : 'bg-purple-100'}`}>
      <BookOpen className={`w-5 h-5
        ${activity.type === 'complete' ? 'text-green-600' :
          activity.type === 'view' ? 'text-blue-600' : 'text-purple-600'}`} />
    </div>
    <div className="flex-1">
      <p className="text-sm font-medium text-gray-800">{activity.material}</p>
      <p className="text-xs text-gray-500">{activity.course}</p>
    </div>
    <span className="text-xs text-gray-400">{activity.time}</span>
  </div>
);

export default function Dashboard() {
  const [loading, setLoading] = useState(true);
  const [dashboardData, setDashboardData] = useState(null);
  const [recommendations, setRecommendations] = useState([]);
  const [selectedTab, setSelectedTab] = useState('overview');

  useEffect(() => {
    fetchDashboardData();
    fetchRecommendations();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const response = await api.get('/student/dashboard');
      setDashboardData(response.data);
    } catch (error) {
      console.error('Error fetching dashboard:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchRecommendations = async () => {
    try {
      const response = await api.get('/student/recommendations?n=6&method=hybrid');
      setRecommendations(response.data);
    } catch (error) {
      console.error('Error fetching recommendations:', error);
    }
  };

  const handleViewMaterial = (material) => {
    // Navigate to material detail page
    window.location.href = `/materials/${material.id}`;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  const stats = dashboardData?.statistics || {};

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white py-8 px-6">
        <div className="max-w-7xl mx-auto">
          <h1 className="text-3xl font-bold mb-2">
            Chào {dashboardData?.user?.name}! 👋
          </h1>
          <p className="text-blue-100">
            Hãy tiếp tục hành trình học tập của bạn
          </p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatCard
            icon={BookOpen}
            title="Môn học đang theo"
            value={stats.enrolled_courses || 0}
            subtitle="Học kỳ này"
            color="bg-blue-500"
          />
          <StatCard
            icon={Clock}
            title="Giờ học tuần này"
            value={`${stats.weekly_hours || 0}h`}
            subtitle="+12% so với tuần trước"
            color="bg-green-500"
          />
          <StatCard
            icon={TrendingUp}
            title="Điểm trung bình"
            value={stats.avg_score?.toFixed(1) || '0.0'}
            subtitle="Tất cả môn học"
            color="bg-purple-500"
          />
          <StatCard
            icon={Award}
            title="Hoàn thành"
            value={`${stats.completion_rate || 0}%`}
            subtitle="Tài liệu đã học"
            color="bg-orange-500"
          />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* AI Recommendations */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-2">
                  <Sparkles className="w-6 h-6 text-purple-500" />
                  <h2 className="text-xl font-bold text-gray-800">
                    Gợi ý cho bạn
                  </h2>
                </div>
                <button className="text-sm text-blue-600 hover:text-blue-700 font-medium">
                  Xem tất cả
                </button>
              </div>

              <div className="space-y-4">
                {recommendations.slice(0, 4).map((rec, idx) => (
                  <RecommendationCard
                    key={idx}
                    material={{
                      id: rec.material_id,
                      title: rec.title || `Tài liệu ${rec.material_id}`,
                      description: rec.description || 'Tài liệu học tập phù hợp với trình độ của bạn',
                      difficulty: rec.difficulty_level || 2,
                      estimated_time: rec.estimated_time || 30,
                      score: rec.score
                    }}
                    onView={handleViewMaterial}
                  />
                ))}
              </div>
            </div>

            {/* Current Courses */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h2 className="text-xl font-bold text-gray-800 mb-4">
                Môn học của bạn
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {dashboardData?.courses?.map((course, idx) => (
                  <div key={idx} 
                       className="border border-gray-200 rounded-lg p-4 hover:border-blue-400 transition cursor-pointer">
                    <h3 className="font-semibold text-gray-800 mb-2">
                      {course.name}
                    </h3>
                    <p className="text-sm text-gray-600 mb-3">{course.code}</p>
                    <div className="flex items-center justify-between">
                      <span className="text-xs text-gray-500">
                        Tiến độ: {course.progress}%
                      </span>
                      <div className="w-24 bg-gray-200 rounded-full h-1.5">
                        <div 
                          className="bg-blue-500 h-1.5 rounded-full"
                          style={{ width: `${course.progress}%` }}
                        />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Recent Activity */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h2 className="text-lg font-bold text-gray-800 mb-4">
                Hoạt động gần đây
              </h2>
              <div className="space-y-1">
                {dashboardData?.recent_activities?.slice(0, 5).map((activity, idx) => (
                  <ActivityItem key={idx} activity={activity} />
                ))}
              </div>
            </div>

            {/* Study Streak */}
            <div className="bg-gradient-to-br from-orange-500 to-pink-500 rounded-xl p-6 text-white">
              <h3 className="text-lg font-bold mb-2">🔥 Chuỗi học tập</h3>
              <div className="text-4xl font-bold mb-1">
                {stats.study_streak || 0} ngày
              </div>
              <p className="text-orange-100 text-sm">
                Bạn đã học liên tục! Tiếp tục phát huy nhé!
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
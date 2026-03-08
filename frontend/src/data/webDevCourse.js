/**
 * Web Development Course - 8 Lessons
 * Data cho khóa học "Lập trình ứng dụng Web"
 */

export const webDevCourseData = {
  id: "web-dev-cnpm",
  code: "CNPM101",
  title: "Lập Trình Ứng Dụng Web",
  description: "Khóa học toàn diện về phát triển ứng dụng web sử dụng HTML, JavaScript, React, Redux và Angular",
  instructor: "Giảng viên CNPM",
  duration: "8 tuần",
  level: "Beginner to Intermediate",
  lessons: [
    {
      id: 1,
      number: "Lecture 00",
      title: "Course Introduction",
      description: "Giới thiệu về khóa học, mục tiêu học tập và tổng quan về phát triển web hiện đại",
      duration: "30 phút",
      fileName: "Lecture 00 - Course Introduction.pdf",
      topics: [
        "Giới thiệu khóa học",
        "Mục tiêu và kết quả học tập",
        "Lộ trình học tập",
        "Công cụ cần thiết"
      ],
      status: "not-started"
    },
    {
      id: 2,
      number: "Lecture 01",
      title: "HTML & JavaScript",
      description: "Nền tảng của web development - HTML để cấu trúc, JavaScript để tương tác",
      duration: "45 phút",
      fileName: "Lecture 01 - HTMLJavaScript.pdf",
      topics: [
        "HTML Structure",
        "HTML Elements & Tags",
        "JavaScript Basics",
        "DOM Manipulation",
        "Event Handling"
      ],
      status: "not-started"
    },
    {
      id: 3,
      number: "Lecture 02",
      title: "Getting Started with React",
      description: "Giới thiệu React - thư viện JavaScript phổ biến nhất để xây dựng UI",
      duration: "60 phút",
      fileName: "Lecture 02 - Getting Started with React.pdf",
      topics: [
        "React Introduction",
        "JSX Syntax",
        "Components",
        "Props",
        "State Basics",
        "React DOM"
      ],
      status: "not-started"
    },
    {
      id: 4,
      number: "Lecture 03",
      title: "React Components",
      description: "Tìm hiểu chi tiết về các loại component và lifecycle trong React",
      duration: "75 phút",
      fileName: "Lecture 03 - React Components.pdf",
      topics: [
        "Functional Components",
        "Class Components",
        "Component Lifecycle",
        "Hooks",
        "useState Hook",
        "useEffect Hook"
      ],
      status: "not-started"
    },
    {
      id: 5,
      number: "Lecture 04",
      title: "Handling Interactions",
      description: "Cách xử lý tương tác người dùng - events, forms và user input",
      duration: "60 phút",
      fileName: "Lecture 04 - Handling Interactions.pdf",
      topics: [
        "Event Handling",
        "Forms in React",
        "Input Elements",
        "Form Validation",
        "Controlled Components",
        "Uncontrolled Components"
      ],
      status: "not-started"
    },
    {
      id: 6,
      number: "Lecture 05",
      title: "Building Components and Applications",
      description: "Xây dựng các ứng dụng phức tạp với các component tái sử dụng",
      duration: "90 phút",
      fileName: "Lecture 05 - Building components and applications with React.pdf",
      topics: [
        "Component Composition",
        "Code Reusability",
        "Component Best Practices",
        "Custom Hooks",
        "API Integration",
        "Data Fetching"
      ],
      status: "not-started"
    },
    {
      id: 7,
      number: "Lecture 06",
      title: "Redux Fundamentals",
      description: "State management với Redux - quản lý trạng thái ứng dụng tập trung",
      duration: "75 phút",
      fileName: "Lecture 06 - Redux Fundamentals.pdf",
      topics: [
        "Redux Basics",
        "Store, Actions, Reducers",
        "Dispatching Actions",
        "Selectors",
        "Redux DevTools",
        "Middleware"
      ],
      status: "not-started"
    },
    {
      id: 8,
      number: "Lecture 07",
      title: "Angular Reactive Forms",
      description: "Giới thiệu Angular framework và reactive forms - cách tiếp cận hiện đại",
      duration: "80 phút",
      fileName: "Lecture 07 - Angular Reactive Forms.pdf",
      topics: [
        "Angular Introduction",
        "Reactive Forms",
        "FormControl & FormGroup",
        "Validation",
        "Form Arrays",
        "Dynamic Forms"
      ],
      status: "not-started"
    }
  ]
};

export default webDevCourseData;

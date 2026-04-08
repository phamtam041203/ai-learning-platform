--
-- PostgreSQL database dump
--

\restrict nu9VTYCJN2ay4qJ8hoyomIwumcakveapRW99x9akrbOQ3CnoptLBiDqxv1D0WEk

-- Dumped from database version 14.22 (Debian 14.22-1.pgdg13+1)
-- Dumped by pg_dump version 14.22 (Debian 14.22-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: assessmenttype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.assessmenttype AS ENUM (
    'QUIZ',
    'ASSIGNMENT',
    'MIDTERM',
    'FINAL',
    'PROJECT',
    'LAB'
);


ALTER TYPE public.assessmenttype OWNER TO postgres;

--
-- Name: courselevel; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.courselevel AS ENUM (
    'BEGINNER',
    'INTERMEDIATE',
    'ADVANCED'
);


ALTER TYPE public.courselevel OWNER TO postgres;

--
-- Name: enrollmentstatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enrollmentstatus AS ENUM (
    'ACTIVE',
    'COMPLETED',
    'DROPPED',
    'PENDING'
);


ALTER TYPE public.enrollmentstatus OWNER TO postgres;

--
-- Name: userrole; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.userrole AS ENUM (
    'STUDENT',
    'TEACHER',
    'ADMIN'
);


ALTER TYPE public.userrole OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: assessments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assessments (
    id integer NOT NULL,
    course_id integer,
    title character varying(255) NOT NULL,
    description text,
    instructions text,
    assessment_type public.assessmenttype,
    max_score double precision,
    weight double precision,
    passing_score double precision,
    due_date timestamp with time zone,
    start_date timestamp with time zone,
    duration_minutes integer,
    is_published boolean,
    allow_late_submission boolean,
    late_penalty_percent double precision,
    max_attempts integer,
    attachment_url character varying(500),
    attachment_name character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.assessments OWNER TO postgres;

--
-- Name: assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.assessments_id_seq OWNER TO postgres;

--
-- Name: assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.assessments_id_seq OWNED BY public.assessments.id;


--
-- Name: courses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.courses (
    id integer NOT NULL,
    course_code character varying(50) NOT NULL,
    course_name character varying(255) NOT NULL,
    description text,
    teacher_id integer,
    major character varying(100),
    specialization character varying(100),
    credit_hours integer,
    semester character varying(50),
    academic_year character varying(20),
    level public.courselevel,
    thumbnail character varying(500),
    duration_weeks integer,
    max_students integer,
    is_active boolean,
    is_featured boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.courses OWNER TO postgres;

--
-- Name: courses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.courses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.courses_id_seq OWNER TO postgres;

--
-- Name: courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.courses_id_seq OWNED BY public.courses.id;


--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enrollments (
    id integer NOT NULL,
    student_id integer,
    course_id integer,
    enrolled_at timestamp with time zone DEFAULT now(),
    completed_at timestamp with time zone,
    status public.enrollmentstatus,
    progress integer,
    completed_lessons integer,
    total_time_spent integer,
    last_accessed timestamp with time zone,
    midterm_score double precision,
    final_score double precision,
    assignment_score double precision,
    total_score double precision,
    grade_letter character varying(5)
);


ALTER TABLE public.enrollments OWNER TO postgres;

--
-- Name: enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.enrollments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.enrollments_id_seq OWNER TO postgres;

--
-- Name: enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.enrollments_id_seq OWNED BY public.enrollments.id;


--
-- Name: essay_submissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.essay_submissions (
    id integer NOT NULL,
    lesson_id integer,
    student_id integer,
    course_id integer,
    text_content text,
    file_url character varying(500),
    file_name character varying(255),
    file_type character varying(100),
    file_size integer,
    status character varying(50),
    score double precision,
    max_score double precision,
    feedback text,
    graded_by integer,
    submitted_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    graded_at timestamp with time zone
);


ALTER TABLE public.essay_submissions OWNER TO postgres;

--
-- Name: essay_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.essay_submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.essay_submissions_id_seq OWNER TO postgres;

--
-- Name: essay_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.essay_submissions_id_seq OWNED BY public.essay_submissions.id;


--
-- Name: grade_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grade_history (
    id integer NOT NULL,
    enrollment_id integer,
    student_id integer,
    course_id integer,
    grade_type character varying(50),
    old_score double precision,
    new_score double precision,
    changed_by integer,
    reason text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.grade_history OWNER TO postgres;

--
-- Name: grade_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.grade_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.grade_history_id_seq OWNER TO postgres;

--
-- Name: grade_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.grade_history_id_seq OWNED BY public.grade_history.id;


--
-- Name: learning_activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.learning_activities (
    id integer NOT NULL,
    user_id integer NOT NULL,
    activity_type character varying(50) NOT NULL,
    activity_metadata json,
    created_at timestamp without time zone
);


ALTER TABLE public.learning_activities OWNER TO postgres;

--
-- Name: learning_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.learning_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.learning_activities_id_seq OWNER TO postgres;

--
-- Name: learning_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.learning_activities_id_seq OWNED BY public.learning_activities.id;


--
-- Name: lesson_comment_likes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lesson_comment_likes (
    id integer NOT NULL,
    comment_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.lesson_comment_likes OWNER TO postgres;

--
-- Name: lesson_comment_likes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lesson_comment_likes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lesson_comment_likes_id_seq OWNER TO postgres;

--
-- Name: lesson_comment_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lesson_comment_likes_id_seq OWNED BY public.lesson_comment_likes.id;


--
-- Name: lesson_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lesson_comments (
    id integer NOT NULL,
    lesson_id integer NOT NULL,
    user_id integer NOT NULL,
    parent_id integer,
    content text NOT NULL,
    likes_count integer,
    is_deleted boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.lesson_comments OWNER TO postgres;

--
-- Name: lesson_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lesson_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lesson_comments_id_seq OWNER TO postgres;

--
-- Name: lesson_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lesson_comments_id_seq OWNED BY public.lesson_comments.id;


--
-- Name: lesson_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lesson_progress (
    id integer NOT NULL,
    student_id integer,
    lesson_id integer,
    is_completed boolean,
    completed_at timestamp with time zone,
    time_spent integer,
    last_position integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.lesson_progress OWNER TO postgres;

--
-- Name: lesson_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lesson_progress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lesson_progress_id_seq OWNER TO postgres;

--
-- Name: lesson_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lesson_progress_id_seq OWNED BY public.lesson_progress.id;


--
-- Name: lessons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lessons (
    id integer NOT NULL,
    course_id integer,
    title character varying(255) NOT NULL,
    description text,
    content text,
    video_url character varying(500),
    pdf_file_name character varying(500),
    duration_minutes integer,
    "order" integer,
    is_published boolean,
    is_free_preview boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.lessons OWNER TO postgres;

--
-- Name: lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lessons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lessons_id_seq OWNER TO postgres;

--
-- Name: lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lessons_id_seq OWNED BY public.lessons.id;


--
-- Name: login_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.login_history (
    id integer NOT NULL,
    user_id integer,
    login_at timestamp with time zone DEFAULT now(),
    ip_address character varying(50),
    user_agent text,
    success boolean
);


ALTER TABLE public.login_history OWNER TO postgres;

--
-- Name: login_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.login_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.login_history_id_seq OWNER TO postgres;

--
-- Name: login_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.login_history_id_seq OWNED BY public.login_history.id;


--
-- Name: materials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.materials (
    id integer NOT NULL,
    course_id integer,
    lesson_id integer,
    title character varying(255) NOT NULL,
    description text,
    file_url character varying(500),
    file_size integer,
    material_type character varying(50),
    "order" integer,
    download_count integer,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.materials OWNER TO postgres;

--
-- Name: materials_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.materials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.materials_id_seq OWNER TO postgres;

--
-- Name: materials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.materials_id_seq OWNED BY public.materials.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    recipient_id integer NOT NULL,
    actor_id integer NOT NULL,
    notif_type character varying(50) NOT NULL,
    message text NOT NULL,
    lesson_id integer,
    comment_id integer,
    is_read boolean,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.questions (
    id integer NOT NULL,
    assessment_id integer,
    question_text text NOT NULL,
    question_type character varying(50),
    option_a text,
    option_b text,
    option_c text,
    option_d text,
    correct_answer character varying(10),
    explanation text,
    points double precision,
    "order" integer
);


ALTER TABLE public.questions OWNER TO postgres;

--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.questions_id_seq OWNER TO postgres;

--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.questions_id_seq OWNED BY public.questions.id;


--
-- Name: quiz_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quiz_results (
    id integer NOT NULL,
    user_id integer,
    lesson_id integer,
    score double precision NOT NULL,
    total_questions integer NOT NULL,
    correct_answers integer NOT NULL,
    completed_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.quiz_results OWNER TO postgres;

--
-- Name: quiz_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quiz_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quiz_results_id_seq OWNER TO postgres;

--
-- Name: quiz_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quiz_results_id_seq OWNED BY public.quiz_results.id;


--
-- Name: recommendations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recommendations (
    id integer NOT NULL,
    student_id integer,
    recommendation_type character varying(50),
    item_id integer,
    item_type character varying(50),
    confidence_score double precision,
    reason text,
    created_at timestamp with time zone DEFAULT now(),
    is_viewed character varying(20),
    is_accepted character varying(20)
);


ALTER TABLE public.recommendations OWNER TO postgres;

--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.recommendations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.recommendations_id_seq OWNER TO postgres;

--
-- Name: recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recommendations_id_seq OWNED BY public.recommendations.id;


--
-- Name: student_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_profiles (
    id integer NOT NULL,
    user_id integer,
    student_id character varying(50) NOT NULL,
    major character varying(255),
    specialization character varying(255),
    class_name character varying(100),
    intake_year integer,
    gpa character varying(10),
    phone character varying(20),
    address text,
    date_of_birth date,
    education_type character varying(10),
    learning_style character varying(50),
    preferred_difficulty character varying(50)
);


ALTER TABLE public.student_profiles OWNER TO postgres;

--
-- Name: student_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_profiles_id_seq OWNER TO postgres;

--
-- Name: student_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_profiles_id_seq OWNED BY public.student_profiles.id;


--
-- Name: student_skill_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_skill_profiles (
    id integer NOT NULL,
    student_id integer NOT NULL,
    skill_id character varying(100) NOT NULL,
    confidence double precision,
    attempts integer,
    correct integer,
    last_updated timestamp with time zone DEFAULT now()
);


ALTER TABLE public.student_skill_profiles OWNER TO postgres;

--
-- Name: student_skill_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_skill_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_skill_profiles_id_seq OWNER TO postgres;

--
-- Name: student_skill_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_skill_profiles_id_seq OWNED BY public.student_skill_profiles.id;


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.submissions (
    id integer NOT NULL,
    assessment_id integer,
    student_id integer,
    content text,
    file_url character varying(500),
    answers_json text,
    score double precision,
    max_score double precision,
    percentage double precision,
    status character varying(50),
    attempt_number integer,
    feedback text,
    graded_by integer,
    submitted_at timestamp with time zone DEFAULT now(),
    graded_at timestamp with time zone,
    is_late boolean
);


ALTER TABLE public.submissions OWNER TO postgres;

--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.submissions_id_seq OWNER TO postgres;

--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.submissions_id_seq OWNED BY public.submissions.id;


--
-- Name: teacher_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teacher_profiles (
    id integer NOT NULL,
    user_id integer,
    teacher_id character varying(50) NOT NULL,
    department character varying(255),
    "position" character varying(100),
    specialization text,
    phone character varying(20),
    office_location character varying(255),
    bio text,
    years_of_experience integer,
    courses_taught text
);


ALTER TABLE public.teacher_profiles OWNER TO postgres;

--
-- Name: teacher_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teacher_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teacher_profiles_id_seq OWNER TO postgres;

--
-- Name: teacher_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teacher_profiles_id_seq OWNED BY public.teacher_profiles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    role public.userrole NOT NULL,
    is_active boolean,
    is_verified boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: assessments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments ALTER COLUMN id SET DEFAULT nextval('public.assessments_id_seq'::regclass);


--
-- Name: courses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses ALTER COLUMN id SET DEFAULT nextval('public.courses_id_seq'::regclass);


--
-- Name: enrollments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments ALTER COLUMN id SET DEFAULT nextval('public.enrollments_id_seq'::regclass);


--
-- Name: essay_submissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.essay_submissions ALTER COLUMN id SET DEFAULT nextval('public.essay_submissions_id_seq'::regclass);


--
-- Name: grade_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_history ALTER COLUMN id SET DEFAULT nextval('public.grade_history_id_seq'::regclass);


--
-- Name: learning_activities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.learning_activities ALTER COLUMN id SET DEFAULT nextval('public.learning_activities_id_seq'::regclass);


--
-- Name: lesson_comment_likes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_comment_likes ALTER COLUMN id SET DEFAULT nextval('public.lesson_comment_likes_id_seq'::regclass);


--
-- Name: lesson_comments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_comments ALTER COLUMN id SET DEFAULT nextval('public.lesson_comments_id_seq'::regclass);


--
-- Name: lesson_progress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_progress ALTER COLUMN id SET DEFAULT nextval('public.lesson_progress_id_seq'::regclass);


--
-- Name: lessons id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons ALTER COLUMN id SET DEFAULT nextval('public.lessons_id_seq'::regclass);


--
-- Name: login_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_history ALTER COLUMN id SET DEFAULT nextval('public.login_history_id_seq'::regclass);


--
-- Name: materials id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.materials ALTER COLUMN id SET DEFAULT nextval('public.materials_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: questions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions ALTER COLUMN id SET DEFAULT nextval('public.questions_id_seq'::regclass);


--
-- Name: quiz_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_results ALTER COLUMN id SET DEFAULT nextval('public.quiz_results_id_seq'::regclass);


--
-- Name: recommendations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recommendations ALTER COLUMN id SET DEFAULT nextval('public.recommendations_id_seq'::regclass);


--
-- Name: student_profiles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_profiles ALTER COLUMN id SET DEFAULT nextval('public.student_profiles_id_seq'::regclass);


--
-- Name: student_skill_profiles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_skill_profiles ALTER COLUMN id SET DEFAULT nextval('public.student_skill_profiles_id_seq'::regclass);


--
-- Name: submissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submissions ALTER COLUMN id SET DEFAULT nextval('public.submissions_id_seq'::regclass);


--
-- Name: teacher_profiles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_profiles ALTER COLUMN id SET DEFAULT nextval('public.teacher_profiles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: assessments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assessments (id, course_id, title, description, instructions, assessment_type, max_score, weight, passing_score, due_date, start_date, duration_minutes, is_published, allow_late_submission, late_penalty_percent, max_attempts, attachment_url, attachment_name, created_at, updated_at) FROM stdin;
86	70	Bài quizz 1 C++	Bài học 1	\N	QUIZ	1	1	5	\N	\N	\N	f	t	10	1	\N	\N	2026-03-08 05:17:54.506712+00	2026-03-08 05:19:43.356458+00
64	36	📄 QUIZ 01	Quiz 1 cho môn Nhập môn Công nghệ thông tin	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:05.946077+00	\N
65	36	📄 QUIZ 02	Quiz 2 cho môn Nhập môn Công nghệ thông tin	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:05.989856+00	\N
66	36	📄 QUIZ 03	Quiz 3 cho môn Nhập môn Công nghệ thông tin	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.012384+00	\N
67	36	📄 QUIZ 04	Quiz 4 cho môn Nhập môn Công nghệ thông tin	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.032911+00	\N
68	36	📄 QUIZ 05	Quiz 5 cho môn Nhập môn Công nghệ thông tin	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.048196+00	\N
69	36	📄 QUIZ 06	Quiz 6 cho môn Nhập môn Công nghệ thông tin	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.065123+00	\N
70	36	📄 QUIZ 07	Quiz 7 cho môn Nhập môn Công nghệ thông tin	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.081161+00	\N
71	36	📄 QUIZ 08	Quiz 8 cho môn Nhập môn Công nghệ thông tin	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.0943+00	\N
72	36	📄 QUIZ 09	Quiz 9 cho môn Nhập môn Công nghệ thông tin	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.106276+00	\N
73	36	📄 QUIZ 10	Quiz 10 cho môn Nhập môn Công nghệ thông tin	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.122821+00	\N
74	43	Quiz_Lecture_00_Course_Introduction	Quiz 1 cho môn Lập trình ứng dụng Web	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.142358+00	\N
75	43	Quiz_Lecture_01_HTML_CSS_JavaScript	Quiz 2 cho môn Lập trình ứng dụng Web	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.150836+00	\N
76	43	Quiz_Lecture_02_Getting_Started_with_React	Quiz 3 cho môn Lập trình ứng dụng Web	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.158468+00	\N
77	43	Quiz_Lecture_03_React_Components	Quiz 4 cho môn Lập trình ứng dụng Web	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.165329+00	\N
78	43	Quiz_Lecture_04_Handling_Interactions	Quiz 5 cho môn Lập trình ứng dụng Web	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.171394+00	\N
79	43	Quiz_Lecture_05_Building_React_Applications	Quiz 6 cho môn Lập trình ứng dụng Web	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.181142+00	\N
80	43	Quiz_Lecture_06_Redux_Fundamentals	Quiz 7 cho môn Lập trình ứng dụng Web	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.187531+00	\N
81	43	Quiz_Lecture_07_Angular_Reactive_Forms	Quiz 8 cho môn Lập trình ứng dụng Web	\N	QUIZ	10	1	5	\N	\N	\N	t	t	10	3	\N	\N	2026-02-03 14:57:06.194225+00	\N
85	67	Quizz1		\N	QUIZ	2	1	5	\N	\N	\N	t	t	10	1	\N	\N	2026-03-08 03:04:37.918204+00	\N
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.courses (id, course_code, course_name, description, teacher_id, major, specialization, credit_hours, semester, academic_year, level, thumbnail, duration_weeks, max_students, is_active, is_featured, created_at, updated_at) FROM stdin;
13	CNTT101	Nhập môn Công nghệ thông tin	Giai đoạn: Cơ sở ngành\nLoại: foundation\nTiên quyết: Không	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
14	CNTT102	Cơ sở lập trình	Giai đoạn: Cơ sở ngành\nLoại: foundation\nTiên quyết: Không	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
15	CNTT103	Kỹ thuật lập trình	Giai đoạn: Cơ sở ngành\nLoại: foundation\nTiên quyết: CNTT102	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
16	CNTT104	Nhập môn Mạng máy tính và điện toán đám mây	Giai đoạn: Cơ sở ngành\nLoại: foundation\nTiên quyết: Không	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
17	CNTT105	Cấu trúc dữ liệu và giải thuật	Giai đoạn: Cơ sở ngành\nLoại: foundation\nTiên quyết: CNTT103	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
18	CNTT201	Cơ sở dữ liệu	Giai đoạn: Môn bắt buộc\nLoại: core\nTiên quyết: CNTT105	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
19	CNTT202	Lập trình hướng đối tượng	Giai đoạn: Môn bắt buộc\nLoại: core\nTiên quyết: CNTT103	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
20	CNTT203	Lập trình ứng dụng Web	Giai đoạn: Môn bắt buộc\nLoại: core\nTiên quyết: CNTT202	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
21	CNTT301	Hệ Quản trị Cơ sở dữ liệu	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: CNTT201	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
22	CNTT302	Lập trình ứng dụng Java	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: CNTT202	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
23	CNTT303	An ninh Mạng máy tính	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: CNTT104	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
24	CNTT304	Quản lý Dự án CNTT	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: Không	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
25	CNTT305	Thiết kế giao diện người dùng	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: Không	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
26	CNTT306	Lập trình ứng dụng di động	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: CNTT202	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
27	CNTT307	Quản lý và phát triển các hệ thống thông tin	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: Không	\N	CNTT	\N	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
28	CNPM401	Nhập môn Công nghệ phần mềm	Giai đoạn: Chuyên ngành CNPM\nLoại: specialization\nTiên quyết: CNTT203	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
29	CNPM402	Kỹ thuật lấy yêu cầu	Giai đoạn: Chuyên ngành CNPM\nLoại: specialization\nTiên quyết: CNPM401	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
30	CNPM403	Kiểm thử phần mềm	Giai đoạn: Chuyên ngành CNPM\nLoại: specialization\nTiên quyết: CNPM401	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
31	CNPM404	Phân tích và thiết kế hệ thống theo Hướng đối tượng	Giai đoạn: Chuyên ngành CNPM\nLoại: specialization\nTiên quyết: CNPM401, CNTT202	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
32	CNPM405	Lập trình Web nâng cao	Giai đoạn: Chuyên ngành CNPM\nLoại: specialization\nTiên quyết: CNTT203	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
33	CNPM406	Quản lý dự án phần mềm	Giai đoạn: Chuyên ngành CNPM\nLoại: specialization\nTiên quyết: CNPM402	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
34	CNPM490	Đồ án thực tập	Giai đoạn: Giai đoạn tốt nghiệp\nLoại: capstone\nTiên quyết: CNPM406	\N	CNTT	CNPM	4	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
35	CNPM499	Khoá luận tốt nghiệp hoặc chuyên đề tốt nghiệp	Giai đoạn: Giai đoạn tốt nghiệp\nLoại: capstone\nTiên quyết: CNPM490	\N	CNTT	CNPM	6	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-01 11:01:22.017127+00	\N
36	IT101	Nhập môn Công nghệ thông tin	Giai đoạn: Cơ sở ngành\nLoại: foundation\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
37	PR101	Cơ sở lập trình	Giai đoạn: Cơ sở ngành\nLoại: foundation\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
38	PR102	Kỹ thuật lập trình	Giai đoạn: Cơ sở ngành\nLoại: foundation\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
39	NET101	Nhập môn Mạng máy tính và điện toán đám mây	Giai đoạn: Cơ sở ngành\nLoại: foundation\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
40	DSA101	Cấu trúc dữ liệu và giải thuật	Giai đoạn: Cơ sở ngành\nLoại: foundation\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
41	DB101	Cơ sở dữ liệu	Giai đoạn: Môn bắt buộc\nLoại: core\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
42	OOP101	Lập trình hướng đối tượng	Giai đoạn: Môn bắt buộc\nLoại: core\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
43	WEB101	Lập trình ứng dụng Web	Giai đoạn: Môn bắt buộc\nLoại: core\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
44	EL201	Hệ Quản trị Cơ sở dữ liệu	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
45	EL202	Lập trình ứng dụng Java	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
46	EL203	An ninh Mạng máy tính	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
47	EL204	Quản lý Dự án CNTT	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
48	EL205	Thiết kế giao diện người dùng	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
49	EL206	Lập trình ứng dụng di động	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
50	EL207	Quản lý và phát triển các hệ thống thông tin	Giai đoạn: Môn tự chọn (chọn 2)\nLoại: elective\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
51	SE101	Nhập môn Công nghệ phần mềm	Giai đoạn: Chuyên ngành CNPM\nLoại: specialization\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
52	RE101	Kỹ thuật lấy yêu cầu	Giai đoạn: Chuyên ngành CNPM\nLoại: specialization\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
53	TEST101	Kiểm thử phần mềm	Giai đoạn: Chuyên ngành CNPM\nLoại: specialization\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
54	SAD101	Phân tích và thiết kế hệ thống theo Hướng đối tượng	Giai đoạn: Chuyên ngành CNPM\nLoại: specialization\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
55	WEB201	Lập trình Web nâng cao	Giai đoạn: Chuyên ngành CNPM\nLoại: specialization\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
56	SEPM101	Quản lý dự án phần mềm	Giai đoạn: Chuyên ngành CNPM\nLoại: specialization\nTiên quyết: Không	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
57	INTERN401	Đồ án thực tập	Giai đoạn: Giai đoạn tốt nghiệp\nLoại: capstone\nTiên quyết: Không	\N	CNTT	CNPM	4	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
58	GRAD401	Khoá luận tốt nghiệp hoặc chuyên đề tốt nghiệp	Giai đoạn: Giai đoạn tốt nghiệp\nLoại: capstone\nTiên quyết: Không	\N	CNTT	CNPM	6	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-03 02:29:01.986248+00	\N
59	ADV201	Trí tuệ nhân tạo	Course ADV201 - Trí tuệ nhân tạo	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-04 05:05:13.65558+00	\N
60	ADV202	Machine Learning cơ bản	Course ADV202 - Machine Learning cơ bản	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-04 05:05:13.65558+00	\N
61	ADV203	DevOps và CI/CD	Course ADV203 - DevOps và CI/CD	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-04 05:05:13.65558+00	\N
62	ADV204	Điện toán đám mây	Course ADV204 - Điện toán đám mây	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-04 05:05:13.65558+00	\N
63	MATH101	Toán rời rạc	Course MATH101 - Toán rời rạc	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-04 05:05:13.65558+00	\N
64	PROJ101	Đồ án môn học	Course PROJ101 - Đồ án môn học	\N	CNTT	CNPM	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-02-04 05:05:13.65558+00	\N
67	GV-5D20ACA0	Python nâng cao	Python nâng cao	17	Teacher Managed	programming	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-03-08 02:20:38.567811+00	\N
70	GV-6C6B5686	C++ Nâng cao	khoá học cc	17	Teacher Managed	programming	3	\N	\N	BEGINNER	\N	15	50	t	f	2026-03-08 05:16:13.143671+00	2026-03-08 05:16:25.660824+00
\.


--
-- Data for Name: enrollments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.enrollments (id, student_id, course_id, enrolled_at, completed_at, status, progress, completed_lessons, total_time_spent, last_accessed, midterm_score, final_score, assignment_score, total_score, grade_letter) FROM stdin;
115	24	37	2026-02-04 05:49:04.332798+00	2026-02-03 22:49:20.786222+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
117	24	39	2026-02-04 05:49:20.78138+00	2026-02-03 22:49:20.788722+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
119	24	63	2026-02-04 05:49:20.78138+00	2026-02-03 22:49:20.790722+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
116	24	38	2026-02-04 05:49:20.78138+00	2026-02-03 22:49:36.293402+00	COMPLETED	100	0	0	\N	\N	\N	\N	10	A+
118	24	40	2026-02-04 05:49:20.78138+00	2026-02-03 22:49:49.008516+00	COMPLETED	100	0	0	\N	\N	\N	\N	10	A+
120	24	41	2026-02-04 05:50:02.519276+00	2026-02-03 22:50:27.50478+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
121	24	42	2026-02-04 05:50:27.502558+00	2026-02-03 22:50:27.505778+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
122	24	43	2026-02-04 05:50:27.502558+00	2026-02-03 22:50:27.506779+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
123	24	51	2026-02-04 05:50:28.793518+00	2026-02-03 22:50:28.796489+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
124	24	52	2026-02-04 05:50:28.793518+00	2026-02-03 22:50:28.797988+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
125	24	53	2026-02-04 05:50:28.793518+00	2026-02-03 22:50:28.799488+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
126	24	44	2026-02-04 05:50:28.793518+00	2026-02-03 22:50:28.800489+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
127	24	45	2026-02-04 05:50:28.793518+00	2026-02-03 22:50:28.801989+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
128	24	55	2026-02-04 05:50:29.936597+00	2026-02-03 22:50:29.940239+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
129	24	56	2026-02-04 05:50:29.936597+00	2026-02-03 22:50:29.941737+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
130	24	64	2026-02-04 05:50:29.936597+00	2026-02-03 22:50:29.943237+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
131	24	59	2026-02-04 05:50:29.936597+00	2026-02-03 22:50:29.945237+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
132	24	60	2026-02-04 05:50:29.936597+00	2026-02-03 22:50:29.946737+00	COMPLETED	100	0	0	\N	\N	\N	\N	8	B+
133	25	36	2026-03-07 08:20:35.211179+00	\N	ACTIVE	0	0	0	\N	\N	\N	\N	\N	\N
134	26	36	2026-03-07 11:57:25.746989+00	\N	ACTIVE	0	0	0	\N	\N	\N	\N	\N	\N
135	26	37	2026-03-07 14:44:50.277668+00	\N	ACTIVE	0	0	0	\N	\N	\N	\N	\N	\N
136	27	37	2026-03-07 14:45:42.741447+00	\N	ACTIVE	0	0	0	\N	\N	\N	\N	\N	\N
138	24	67	2026-03-08 09:31:27.883687+00	2026-03-08 10:11:38.123907+00	COMPLETED	100	0	0	\N	\N	\N	\N	100	\N
139	28	67	2026-03-08 11:30:05.471123+00	\N	ACTIVE	0	0	0	\N	\N	\N	\N	\N	\N
140	26	70	2026-03-08 12:20:03.803806+00	\N	ACTIVE	0	0	0	\N	\N	\N	\N	\N	\N
137	27	36	2026-03-07 23:28:44.592847+00	\N	ACTIVE	8	0	0	\N	\N	\N	\N	100	\N
141	30	36	2026-03-09 03:20:43.575706+00	\N	ACTIVE	8	0	0	\N	\N	\N	\N	70	\N
142	24	70	2026-03-09 04:13:36.260924+00	\N	ACTIVE	0	0	0	\N	\N	\N	\N	\N	\N
114	24	36	2026-02-04 05:48:00.883501+00	2026-03-09 07:13:35.068166+00	COMPLETED	100	0	0	\N	\N	\N	\N	67.5	A+
143	24	57	2026-03-09 08:07:49.371119+00	\N	ACTIVE	0	0	0	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: essay_submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.essay_submissions (id, lesson_id, student_id, course_id, text_content, file_url, file_name, file_type, file_size, status, score, max_score, feedback, graded_by, submitted_at, updated_at, graded_at) FROM stdin;
2	123	24	37	hehe	\N	\N	\N	\N	submitted	\N	10	\N	\N	2026-03-09 05:27:07.891927+00	\N	\N
1	191	28	67	ádasdasdasd	/uploads/essays/essay_28_191_5292f019.docx	PhamThanhTam-2174802010372-VLU.ĐAKLTN.02. Phiếu đăng ký thực hiện ĐATN.docx	application/vnd.openxmlformats-officedocument.wordprocessingml.document	52838	graded	9	10	ok	17	2026-03-08 11:37:04.9462+00	2026-03-12 07:29:59.506407+00	2026-03-12 07:29:59.508756+00
\.


--
-- Data for Name: grade_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grade_history (id, enrollment_id, student_id, course_id, grade_type, old_score, new_score, changed_by, reason, created_at) FROM stdin;
\.


--
-- Data for Name: learning_activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.learning_activities (id, user_id, activity_type, activity_metadata, created_at) FROM stdin;
\.


--
-- Data for Name: lesson_comment_likes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lesson_comment_likes (id, comment_id, user_id, created_at) FROM stdin;
1	2	27	2026-03-07 14:45:53.760282+00
2	1	27	2026-03-07 14:46:00.404907+00
3	3	26	2026-03-07 14:59:46.884987+00
4	5	27	2026-03-07 15:01:25.601947+00
6	10	30	2026-03-09 03:51:23.752234+00
7	9	30	2026-03-09 03:51:25.909217+00
8	8	30	2026-03-09 03:51:26.267982+00
9	10	24	2026-03-09 04:10:47.699802+00
10	8	24	2026-03-09 07:48:23.01335+00
\.


--
-- Data for Name: lesson_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lesson_comments (id, lesson_id, user_id, parent_id, content, likes_count, is_deleted, created_at, updated_at) FROM stdin;
2	121	26	1	bài này hay nhỉ	1	f	2026-03-07 14:45:04.234157+00	2026-03-07 14:45:53.760282+00
1	121	24	\N	hay quá	1	f	2026-03-07 14:43:52.336039+00	2026-03-07 14:46:00.404907+00
4	121	27	1	kkkk	0	f	2026-03-07 14:53:55.370921+00	\N
3	121	27	1	hihi	1	f	2026-03-07 14:45:58.077364+00	2026-03-07 14:59:46.884987+00
6	122	27	5	đúng rồi	0	f	2026-03-07 15:01:13.252499+00	\N
5	122	24	\N	bài hày jay quá	1	f	2026-03-07 15:00:55.117053+00	2026-03-07 15:01:25.601947+00
7	110	18	\N	Binh luan test notification - admin	0	f	2026-03-07 16:11:14.585735+00	\N
10	109	30	\N	Tâm provip cute	2	f	2026-03-09 03:51:17.980778+00	2026-03-09 04:10:47.699802+00
11	109	24	\N	tamdeptrai	0	f	2026-03-09 04:10:54.960557+00	\N
9	109	26	8	Bài này có những điểm mình còn chưa hiểu	1	f	2026-03-08 12:10:31.100031+00	2026-03-09 07:48:22.440724+00
8	109	24	\N	Hay và hấp dẫn	2	f	2026-03-08 12:08:55.826775+00	2026-03-09 07:48:23.01335+00
\.


--
-- Data for Name: lesson_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lesson_progress (id, student_id, lesson_id, is_completed, completed_at, time_spent, last_position, created_at, updated_at) FROM stdin;
83	24	111	t	2026-02-03 22:49:41.614324+00	0	0	2026-02-04 05:49:33.670608+00	2026-02-04 05:49:41.609049+00
84	24	112	t	2026-02-03 22:49:41.615325+00	0	0	2026-02-04 05:49:33.670608+00	2026-02-04 05:49:41.609049+00
85	24	113	t	2026-02-03 22:49:41.616325+00	0	0	2026-02-04 05:49:33.670608+00	2026-02-04 05:49:41.609049+00
86	24	114	t	2026-02-03 22:49:41.616823+00	0	0	2026-02-04 05:49:33.670608+00	2026-02-04 05:49:41.609049+00
87	24	115	t	2026-02-03 22:49:41.617824+00	0	0	2026-02-04 05:49:33.670608+00	2026-02-04 05:49:41.609049+00
88	24	116	t	2026-02-03 22:49:41.619325+00	0	0	2026-02-04 05:49:33.670608+00	2026-02-04 05:49:41.609049+00
89	24	117	t	2026-02-03 22:49:41.620824+00	0	0	2026-02-04 05:49:33.670608+00	2026-02-04 05:49:41.609049+00
90	24	118	t	2026-02-03 22:49:41.621824+00	0	0	2026-02-04 05:49:33.670608+00	2026-02-04 05:49:41.609049+00
91	24	119	t	2026-02-03 22:49:41.622824+00	0	0	2026-02-04 05:49:33.670608+00	2026-02-04 05:49:41.609049+00
92	24	120	t	2026-02-03 22:49:41.623824+00	0	0	2026-02-04 05:49:33.670608+00	2026-02-04 05:49:41.609049+00
93	24	110	t	2026-02-03 22:49:41.624824+00	0	0	2026-02-04 05:49:33.670608+00	2026-02-04 05:49:41.609049+00
94	24	139	t	2026-02-03 22:49:49.005016+00	0	0	2026-02-04 05:49:38.872865+00	2026-02-04 05:49:49.001504+00
95	24	140	t	2026-02-03 22:49:49.005517+00	0	0	2026-02-04 05:49:38.872865+00	2026-02-04 05:49:49.001504+00
96	24	141	t	2026-02-03 22:49:49.006019+00	0	0	2026-02-04 05:49:38.872865+00	2026-02-04 05:49:49.001504+00
97	24	142	t	2026-02-03 22:49:49.006519+00	0	0	2026-02-04 05:49:38.872865+00	2026-02-04 05:49:49.001504+00
98	24	143	t	2026-02-03 22:49:49.007019+00	0	0	2026-02-04 05:49:38.872865+00	2026-02-04 05:49:49.001504+00
99	24	144	t	2026-02-03 22:49:49.007519+00	0	0	2026-02-04 05:49:38.872865+00	2026-02-04 05:49:49.001504+00
100	27	113	t	2026-03-07 23:31:06.537025+00	0	0	2026-03-07 23:31:06.524666+00	\N
101	24	191	t	2026-03-08 10:11:38.119956+00	0	0	2026-03-08 10:05:28.560858+00	2026-03-08 10:11:38.109395+00
102	26	192	t	2026-03-08 12:20:25.520767+00	0	0	2026-03-08 12:20:25.515448+00	\N
103	27	109	t	2026-03-08 13:01:32.828238+00	0	0	2026-03-08 13:01:32.81614+00	\N
104	30	109	t	2026-03-09 03:50:24.879027+00	0	0	2026-03-09 03:46:44.140253+00	2026-03-09 03:50:24.873669+00
82	24	109	t	2026-03-09 07:13:35.066173+00	0	0	2026-02-04 05:48:49.533999+00	2026-03-09 07:13:35.059192+00
\.


--
-- Data for Name: lessons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lessons (id, course_id, title, description, content, video_url, pdf_file_name, duration_minutes, "order", is_published, is_free_preview, created_at, updated_at) FROM stdin;
111	36	Slide 05 Ngôn ngữ lập trình	Tài liệu: Slide 05_Ngôn ngữ lập trình.pptx	\N	\N	IT101__Slide 05_Ngôn ngữ lập trình.pdf	0	3	t	f	2026-02-03 11:38:39.214939+00	2026-02-03 13:57:58.25969+00
112	36	Slide 00 Giới thiệu môn Nhập môn CNTT	Tài liệu: Slide-00_Giới thiệu môn Nhập môn CNTT.pptx	\N	\N	IT101__Slide-00_Giới thiệu môn Nhập môn CNTT.pdf	0	4	t	f	2026-02-03 11:38:39.214939+00	2026-02-03 13:57:58.25969+00
113	36	Slide 01 Tổng quan về CNTT Phần cứng máy tính Hệ đếm	Tài liệu: Slide-01_Tổng quan về CNTT-Phần cứng máy tính  Hệ đếm.pptx	\N	\N	IT101__Slide-01_Tổng quan về CNTT-Phần cứng máy tính  Hệ đếm.pdf	0	5	t	f	2026-02-03 11:38:39.214939+00	2026-02-03 13:57:58.25969+00
114	36	Slide 04 WWW và HTML	Tài liệu: Slide-04_WWW và HTML.pptx	\N	\N	IT101__Slide-04_WWW và HTML.pdf	0	6	t	f	2026-02-03 11:38:39.214939+00	2026-02-03 13:57:58.25969+00
115	36	Slide 05 First Java Program	Tài liệu: Slide-05_First Java Program.pptx	\N	\N	IT101__Slide-05_First Java Program.pdf	0	7	t	f	2026-02-03 11:38:39.214939+00	2026-02-03 13:57:58.25969+00
116	36	Slide 06 Sử dụng AI và Đạo đức khi sử dụng AI	Tài liệu: Slide-06_Sử dụng AI và Đạo đức khi sử dụng AI.pptx	\N	\N	IT101__Slide-06_Sử dụng AI và Đạo đức khi sử dụng AI.pdf	0	8	t	f	2026-02-03 11:38:39.214939+00	2026-02-03 13:57:58.25969+00
109	36	Lab1. Phan Cung May Tinh He Dem v2	Tài liệu: Lab1. Phan Cung May Tinh  He Dem_v2.pdf	\N	\N	IT101__Lab1. Phan Cung May Tinh  He Dem_v2.pdf	0	1	t	f	2026-02-03 11:38:39.214939+00	\N
117	36	TH 03 Khám phá Mạng và Lưu trữ Cloud	Tài liệu: TH-03_Khám phá Mạng và Lưu trữ Cloud.pdf	\N	\N	IT101__TH-03_Khám phá Mạng và Lưu trữ Cloud.pdf	0	9	t	f	2026-02-03 11:38:39.214939+00	\N
118	36	TH 06 Lập trình Javascript	Tài liệu: TH-06_Lập trình Javascript.pdf	\N	\N	IT101__TH-06_Lập trình Javascript.pdf	0	10	t	f	2026-02-03 11:38:39.214939+00	\N
119	36	Thực hành 04 HTML	Tài liệu: Thực hành 04_HTML.pdf	\N	\N	IT101__Thực hành 04_HTML.pdf	0	11	t	f	2026-02-03 11:38:39.214939+00	\N
120	36	Thực hành 05 Ngôn ngữ Java	Tài liệu: Thực hành 05_Ngôn ngữ Java.pdf	\N	\N	IT101__Thực hành 05_Ngôn ngữ Java.pdf	0	12	t	f	2026-02-03 11:38:39.214939+00	\N
121	37	Basic Java Exam	Tài liệu: Basic_Java_Exam.pdf	\N	\N	PR101__Basic_Java_Exam.pdf	0	1	t	f	2026-02-03 11:38:39.214939+00	\N
122	37	Chapter 2 Basic of Java	Tài liệu: Chapter 2 - Basic of Java.pdf	\N	\N	PR101__Chapter 2 - Basic of Java.pdf	0	2	t	f	2026-02-03 11:38:39.214939+00	\N
123	37	Chapter 3 Variables and Types	Tài liệu: Chapter 3 - Variables and Types.pdf	\N	\N	PR101__Chapter 3 - Variables and Types.pdf	0	3	t	f	2026-02-03 11:38:39.214939+00	\N
124	37	Chapter 4 Operators	Tài liệu: Chapter 4 - Operators.pdf	\N	\N	PR101__Chapter 4 - Operators.pdf	0	4	t	f	2026-02-03 11:38:39.214939+00	\N
125	37	Chapter 5 Flow control	Tài liệu: Chapter 5 - Flow control.pdf	\N	\N	PR101__Chapter 5 - Flow control.pdf	0	5	t	f	2026-02-03 11:38:39.214939+00	\N
126	37	Loop and Array Exercises	Tài liệu: Loop_and_Array_Exercises.pdf	\N	\N	PR101__Loop_and_Array_Exercises.pdf	0	6	t	f	2026-02-03 11:38:39.214939+00	\N
127	39	ch04 Lecture 4	Tài liệu: ch04-Lecture 4.pdf	\N	\N	NET101__ch04-Lecture 4.pdf	0	1	t	f	2026-02-03 11:38:39.214939+00	\N
128	39	ch07 lecture 3	Tài liệu: ch07-lecture 3.pdf	\N	\N	NET101__ch07-lecture 3.pdf	0	2	t	f	2026-02-03 11:38:39.214939+00	\N
129	39	ch08 Lecture 5	Tài liệu: ch08 - Lecture 5.pdf	\N	\N	NET101__ch08 - Lecture 5.pdf	0	3	t	f	2026-02-03 11:38:39.214939+00	\N
130	39	ch09 Lecture 7	Tài liệu: ch09 - Lecture 7.pdf	\N	\N	NET101__ch09 - Lecture 7.pdf	0	4	t	f	2026-02-03 11:38:39.214939+00	\N
131	39	ch13 Lecture 6	Tài liệu: ch13 - Lecture 6.pdf	\N	\N	NET101__ch13 - Lecture 6.pdf	0	5	t	f	2026-02-03 11:38:39.214939+00	\N
132	39	ch15 Lecture 9	Tài liệu: ch15-Lecture 9.pdf	\N	\N	NET101__ch15-Lecture 9.pdf	0	6	t	f	2026-02-03 11:38:39.214939+00	\N
133	39	ch19 Lecture 8 Logical Address	Tài liệu: ch19 - Lecture 8 - Logical Address.pdf	\N	\N	NET101__ch19 - Lecture 8 - Logical Address.pdf	0	7	t	f	2026-02-03 11:38:39.214939+00	\N
134	39	LAB 2. CẤU HÌNH CƠ BẢN TRÊN THIẾT BỊ SWITCH CISCO	Tài liệu: LAB 2. CẤU HÌNH CƠ BẢN TRÊN THIẾT BỊ SWITCH CISCO.pdf	\N	\N	NET101__LAB 2. CẤU HÌNH CƠ BẢN TRÊN THIẾT BỊ SWITCH CISCO.pdf	0	8	t	f	2026-02-03 11:38:39.214939+00	\N
135	39	LAB 3. THIẾT LẬP MẠNG LAN CƠ BẢN	Tài liệu: LAB 3. THIẾT LẬP MẠNG LAN CƠ BẢN.pdf	\N	\N	NET101__LAB 3. THIẾT LẬP MẠNG LAN CƠ BẢN.pdf	0	9	t	f	2026-02-03 11:38:39.214939+00	\N
136	39	LAB QUY HOẠCH IP VÀ SUBNET	Tài liệu: LAB QUY HOẠCH IP VÀ SUBNET.pdf	\N	\N	NET101__LAB QUY HOẠCH IP VÀ SUBNET.pdf	0	10	t	f	2026-02-03 11:38:39.214939+00	\N
137	39	Lecture 1 ch01	Tài liệu: Lecture 1 - ch01.pdf	\N	\N	NET101__Lecture 1 - ch01.pdf	0	11	t	f	2026-02-03 11:38:39.214939+00	\N
110	36	Slide 02 Phần mềm và Vận hành Doanh nghiệp	Tài liệu: Slide 02_Phần mềm và Vận hành Doanh nghiệp.pptx	\N	\N	IT101__Slide 02_Phần mềm và Vận hành Doanh nghiệp.pdf	0	2	t	f	2026-02-03 11:38:39.214939+00	2026-02-03 13:57:58.25969+00
138	39	Lecture 2 ch02	Tài liệu: Lecture 2 - ch02.pdf	\N	\N	NET101__Lecture 2 - ch02.pdf	0	12	t	f	2026-02-03 11:38:39.214939+00	\N
139	40	CTDL GT (LT + TH) Chương 01 HK233	Tài liệu: CTDL GT (LT + TH) - Chương 01 - HK233.pdf	\N	\N	DSA101__CTDL GT (LT + TH) - Chương 01 - HK233.pdf	0	1	t	f	2026-02-03 11:38:39.214939+00	\N
140	40	CTDL GT Chuong 3 Lý thuyết đồ thị (LT + TH) HK223	Tài liệu: CTDL GT - Chuong 3 -Lý thuyết đồ thị (LT + TH) HK223.pdf	\N	\N	DSA101__CTDL GT - Chuong 3 -Lý thuyết đồ thị (LT + TH) HK223.pdf	0	2	t	f	2026-02-03 11:38:39.214939+00	\N
141	40	CTDL GT Chuong 4 Array List Linked List (LT + TH)	Tài liệu: CTDL GT - Chuong 4 - Array List  Linked List (LT + TH).pdf	\N	\N	DSA101__CTDL GT - Chuong 4 - Array List  Linked List (LT + TH).pdf	0	3	t	f	2026-02-03 11:38:39.214939+00	\N
142	40	CTDL GT Chuong 5 Stack + Queue (LT +TH)	Tài liệu: CTDL GT - Chuong 5 - Stack + Queue  (LT +TH).pdf	\N	\N	DSA101__CTDL GT - Chuong 5 - Stack + Queue  (LT +TH).pdf	0	4	t	f	2026-02-03 11:38:39.214939+00	\N
143	40	CTDL GT Chuong 6 Bảng băm Hash Table (LT + TH)	Tài liệu: CTDL GT - Chuong 6 - Bảng băm-Hash Table  (LT + TH).pdf	\N	\N	DSA101__CTDL GT - Chuong 6 - Bảng băm-Hash Table  (LT + TH).pdf	0	5	t	f	2026-02-03 11:38:39.214939+00	\N
144	40	CTDL GT Chuong 7 Cây nhị phân tìm kiếm (LT + TH)	Tài liệu: CTDL GT - Chuong 7 - Cây nhị phân tìm kiếm  (LT + TH).pdf	\N	\N	DSA101__CTDL GT - Chuong 7 - Cây nhị phân tìm kiếm  (LT + TH).pdf	0	6	t	f	2026-02-03 11:38:39.214939+00	\N
145	41	01 Chuong1 Tong quat ve csdl	Tài liệu: 01-Chuong1_Tong quat ve csdl.pdf	\N	\N	DB101__01-Chuong1_Tong quat ve csdl.pdf	0	1	t	f	2026-02-03 11:38:39.214939+00	\N
146	41	02 Chuong2 Mo hinh hoa du lieu	Tài liệu: 02-Chuong2_Mo hinh hoa du lieu.pdf	\N	\N	DB101__02-Chuong2_Mo hinh hoa du lieu.pdf	0	2	t	f	2026-02-03 11:38:39.214939+00	\N
147	41	04 Chuong3 Mo hinh lien ket thuc the mo rong	Tài liệu: 04-Chuong3_Mo hinh lien ket thuc the mo rong.pdf	\N	\N	DB101__04-Chuong3_Mo hinh lien ket thuc the mo rong.pdf	0	3	t	f	2026-02-03 11:38:39.214939+00	\N
148	41	06 Chuong4 Mo hinh quan he va tk csdl	Tài liệu: 06-Chuong4_Mo hinh quan he va tk csdl.pdf	\N	\N	DB101__06-Chuong4_Mo hinh quan he va tk csdl.pdf	0	4	t	f	2026-02-03 11:38:39.214939+00	\N
149	41	07 Chuong5 Ngon ngu SQL	Tài liệu: 07-Chuong5_Ngon ngu SQL.pdf	\N	\N	DB101__07-Chuong5_Ngon ngu SQL.pdf	0	5	t	f	2026-02-03 11:38:39.214939+00	\N
150	41	10 Chuong6 Chuan hoa du lieu	Tài liệu: 10-Chuong6_Chuan hoa du lieu.pdf	\N	\N	DB101__10-Chuong6_Chuan hoa du lieu.pdf	0	6	t	f	2026-02-03 11:38:39.214939+00	\N
151	41	12 Chuong7 Dai so quan he	Tài liệu: 12-Chuong7_Dai so quan he.pdf	\N	\N	DB101__12-Chuong7_Dai so quan he.pdf	0	7	t	f	2026-02-03 11:38:39.214939+00	\N
152	43	Lecture 00 Course Introduction	Tài liệu: Lecture 00 - Course Introduction.pdf	\N	\N	WEB101__Lecture 00 - Course Introduction.pdf	0	1	t	f	2026-02-03 11:38:39.214939+00	\N
153	43	Lecture 01 HTMLJavaScript	Tài liệu: Lecture 01 - HTMLJavaScript.pdf	\N	\N	WEB101__Lecture 01 - HTMLJavaScript.pdf	0	2	t	f	2026-02-03 11:38:39.214939+00	\N
154	43	Lecture 02 Getting Started with React	Tài liệu: Lecture 02 - Getting Started with React.pdf	\N	\N	WEB101__Lecture 02 - Getting Started with React.pdf	0	3	t	f	2026-02-03 11:38:39.214939+00	\N
155	43	Lecture 03 React Components	Tài liệu: Lecture 03 - React Components.pdf	\N	\N	WEB101__Lecture 03 - React Components.pdf	0	4	t	f	2026-02-03 11:38:39.214939+00	\N
156	43	Lecture 04 Handling Interactions	Tài liệu: Lecture 04 - Handling Interactions.pdf	\N	\N	WEB101__Lecture 04 - Handling Interactions.pdf	0	5	t	f	2026-02-03 11:38:39.214939+00	\N
157	43	Lecture 05 Building components and applications with React	Tài liệu: Lecture 05 - Building components and applications with React.pdf	\N	\N	WEB101__Lecture 05 - Building components and applications with React.pdf	0	6	t	f	2026-02-03 11:38:39.214939+00	\N
158	43	Lecture 06 Redux Fundamentals	Tài liệu: Lecture 06 - Redux Fundamentals.pdf	\N	\N	WEB101__Lecture 06 - Redux Fundamentals.pdf	0	7	t	f	2026-02-03 11:38:39.214939+00	\N
159	43	Lecture 07 Angular Reactive Forms	Tài liệu: Lecture 07 - Angular Reactive Forms.pdf	\N	\N	WEB101__Lecture 07 - Angular Reactive Forms.pdf	0	8	t	f	2026-02-03 11:38:39.214939+00	\N
160	42	OOP@01. Introductions to Java	Tài liệu: OOP@01. Introductions to Java.pdf	\N	\N	OOP101__OOP@01. Introductions to Java.pdf	0	1	t	f	2026-02-03 11:38:39.214939+00	\N
161	42	OOP@02. Java Language Basics	Tài liệu: OOP@02. Java Language Basics.pdf	\N	\N	OOP101__OOP@02. Java Language Basics.pdf	0	2	t	f	2026-02-03 11:38:39.214939+00	\N
162	42	OOP@03. Classes and Objects	Tài liệu: OOP@03. Classes and Objects.pdf	\N	\N	OOP101__OOP@03. Classes and Objects.pdf	0	3	t	f	2026-02-03 11:38:39.214939+00	\N
163	42	OOP@04. Static Fields and Static Methods	Tài liệu: OOP@04. Static Fields and Static Methods.pdf	\N	\N	OOP101__OOP@04. Static Fields and Static Methods.pdf	0	4	t	f	2026-02-03 11:38:39.214939+00	\N
164	42	OOP@05. Inheritance and Polymorphism	Tài liệu: OOP@05. Inheritance and Polymorphism.pdf	\N	\N	OOP101__OOP@05. Inheritance and Polymorphism.pdf	0	5	t	f	2026-02-03 11:38:39.214939+00	\N
165	42	OOP@06. Exception Handling	Tài liệu: OOP@06. Exception Handling.pdf	\N	\N	OOP101__OOP@06. Exception Handling.pdf	0	6	t	f	2026-02-03 11:38:39.214939+00	\N
166	42	OOP@07. Interface and Abstract Class	Tài liệu: OOP@07. Interface and Abstract Class.pdf	\N	\N	OOP101__OOP@07. Interface and Abstract Class.pdf	0	7	t	f	2026-02-03 11:38:39.214939+00	\N
167	42	OOP@08. Collections	Tài liệu: OOP@08. Collections.pdf	\N	\N	OOP101__OOP@08. Collections.pdf	0	8	t	f	2026-02-03 11:38:39.214939+00	\N
168	42	OOP@09. IO Streams	Tài liệu: OOP@09. IO Streams.pdf	\N	\N	OOP101__OOP@09. IO Streams.pdf	0	9	t	f	2026-02-03 11:38:39.214939+00	\N
169	44		Tài liệu: .DS_Store	\N	\N	EL201__.DS_Store	0	1	t	f	2026-02-03 11:38:39.214939+00	\N
170	44	Chuong 1.Tong quan ve he QTCSDL	Tài liệu: Chuong 1.Tong quan ve he QTCSDL.pdf	\N	\N	EL201__Chuong 1.Tong quan ve he QTCSDL.pdf	0	2	t	f	2026-02-03 11:38:39.214939+00	\N
171	44	Chuong 10 Giao Tac Va Truy Xuat Dong Thoi	Tài liệu: Chuong 10_Giao Tac Va Truy Xuat Dong Thoi.pdf	\N	\N	EL201__Chuong 10_Giao Tac Va Truy Xuat Dong Thoi.pdf	0	3	t	f	2026-02-03 11:38:39.214939+00	\N
172	44	Chuong 11. Ky thuat toi uu hoa truy van	Tài liệu: Chuong 11. Ky thuat toi uu hoa truy van.pdf	\N	\N	EL201__Chuong 11. Ky thuat toi uu hoa truy van.pdf	0	4	t	f	2026-02-03 11:38:39.214939+00	\N
173	44	Chuong 2. Khung nhin	Tài liệu: Chuong 2. Khung nhin.pdf	\N	\N	EL201__Chuong 2. Khung nhin.pdf	0	5	t	f	2026-02-03 11:38:39.214939+00	\N
174	44	Chuong 3. Stored Procedure&Trigger	Tài liệu: Chuong 3. Stored Procedure&Trigger.pdf	\N	\N	EL201__Chuong 3. Stored Procedure&Trigger.pdf	0	6	t	f	2026-02-03 11:38:39.214939+00	\N
175	44	Chuong 4. Function&Cursor	Tài liệu: Chuong 4. Function&Cursor.pdf	\N	\N	EL201__Chuong 4. Function&Cursor.pdf	0	7	t	f	2026-02-03 11:38:39.214939+00	\N
176	44	Chuong 5. Phu Toi Thieu	Tài liệu: Chuong 5. Phu Toi Thieu.pdf	\N	\N	EL201__Chuong 5. Phu Toi Thieu.pdf	0	8	t	f	2026-02-03 11:38:39.214939+00	\N
177	44	Chuong 6. Dai so quan he nang cao	Tài liệu: Chuong 6. Dai so quan he nang cao.pdf	\N	\N	EL201__Chuong 6. Dai so quan he nang cao.pdf	0	9	t	f	2026-02-03 11:38:39.214939+00	\N
178	44	Chuong 7. Toi uu hoa cau truy van	Tài liệu: Chuong 7. Toi uu hoa cau truy van.pdf	\N	\N	EL201__Chuong 7. Toi uu hoa cau truy van.pdf	0	10	t	f	2026-02-03 11:38:39.214939+00	\N
179	44	Chuong 8. Chi Muc	Tài liệu: Chuong 8. Chi Muc.pdf	\N	\N	EL201__Chuong 8. Chi Muc.pdf	0	11	t	f	2026-02-03 11:38:39.214939+00	\N
180	44	Chuong 9. An toan va Khoi phuc du lieu	Tài liệu: Chuong 9. An toan va Khoi phuc du lieu.pdf	\N	\N	EL201__Chuong 9. An toan va Khoi phuc du lieu.pdf	0	12	t	f	2026-02-03 11:38:39.214939+00	\N
181	52	233 RE Orientation	Tài liệu: 233_RE_Orientation.pdf	\N	\N	RE101__233_RE_Orientation.pdf	0	1	t	f	2026-02-03 11:38:39.214939+00	\N
182	52	L2 RE Views and Product Vision	Tài liệu: L2_RE_Views and Product Vision.pdf	\N	\N	RE101__L2_RE_Views and Product Vision.pdf	0	2	t	f	2026-02-03 11:38:39.214939+00	\N
183	52	L6 RE Requirements Specification	Tài liệu: L6_RE_Requirements Specification.pdf	\N	\N	RE101__L6_RE_Requirements Specification.pdf	0	3	t	f	2026-02-03 11:38:39.214939+00	\N
184	53	01. Introduction to ST	Tài liệu: 01. Introduction to ST.pdf	\N	\N	TEST101__01. Introduction to ST.pdf	0	1	t	f	2026-02-03 11:38:39.214939+00	\N
185	53	02. Principles of ST	Tài liệu: 02. Principles of ST.pdf	\N	\N	TEST101__02. Principles of ST.pdf	0	2	t	f	2026-02-03 11:38:39.214939+00	\N
186	53	03. Types of Testing	Tài liệu: 03. Types of Testing.pdf	\N	\N	TEST101__03. Types of Testing.pdf	0	3	t	f	2026-02-03 11:38:39.214939+00	\N
187	53	04. WhiteBox Testing	Tài liệu: 04. WhiteBox Testing.pdf	\N	\N	TEST101__04. WhiteBox Testing.pdf	0	4	t	f	2026-02-03 11:38:39.214939+00	\N
188	53	05. BlackBox Testing	Tài liệu: 05. BlackBox Testing.pdf	\N	\N	TEST101__05. BlackBox Testing.pdf	0	5	t	f	2026-02-03 11:38:39.214939+00	\N
189	53	06. JUNIT	Tài liệu: 06. JUNIT.pdf	\N	\N	TEST101__06. JUNIT.pdf	0	6	t	f	2026-02-03 11:38:39.214939+00	\N
190	53	07. Selenium WebDriver	Tài liệu: 07. Selenium WebDriver.pdf	\N	\N	TEST101__07. Selenium WebDriver.pdf	0	7	t	f	2026-02-03 11:38:39.214939+00	\N
191	67	Bài 1	Bài 1	\N	https://www.youtube.com/watch?v=69b7C04OzRk	lesson_67_c91f3a6823b645b4abda379a154d0e07.pdf	0	1	t	f	2026-03-08 03:03:11.46415+00	\N
192	70	Bài 1	Bài học 1	\N	\N	lesson_70_29d31e13bfab4924a912b14807a52896.pdf	0	1	t	f	2026-03-08 05:17:08.38844+00	\N
\.


--
-- Data for Name: login_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.login_history (id, user_id, login_at, ip_address, user_agent, success) FROM stdin;
\.


--
-- Data for Name: materials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.materials (id, course_id, lesson_id, title, description, file_url, file_size, material_type, "order", download_count, created_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, recipient_id, actor_id, notif_type, message, lesson_id, comment_id, is_read, created_at) FROM stdin;
1	24	26	reply	Phạm Thành Tâm đã trả lời bình luận của bạn: "Bài này có những điểm mình còn chưa hiểu"	109	9	t	2026-03-08 12:10:31.100031+00
\.


--
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.questions (id, assessment_id, question_text, question_type, option_a, option_b, option_c, option_d, correct_answer, explanation, points, "order") FROM stdin;
1	246	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2	246	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
3	246	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
4	246	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
5	246	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
6	247	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
7	247	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
8	247	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
9	247	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
10	247	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
11	248	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
12	248	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
13	248	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
14	248	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
15	248	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
16	249	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
17	249	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
18	249	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
19	249	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
20	249	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
21	250	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
22	250	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
23	250	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
24	250	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
25	250	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
26	251	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
27	251	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
28	251	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
29	251	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
30	251	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
31	252	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
32	252	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
33	252	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
34	252	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
35	252	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
36	253	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
37	253	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
38	253	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
39	253	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
40	253	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
41	254	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
42	254	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
43	254	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
44	254	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
45	254	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1701	586	Lập trình là gì?	multiple_choice	Sửa máy	Viết code cho máy	Bán máy	Chơi game	b	\N	1	1
46	255	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
47	255	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
48	255	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
49	255	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
50	255	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
51	256	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
52	256	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
53	256	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
54	256	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
55	256	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
56	257	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
57	257	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
58	257	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
59	257	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
60	257	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
61	258	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
62	258	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
63	258	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
64	258	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
65	258	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
66	259	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
67	259	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
68	259	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
69	259	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
70	259	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
71	260	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
72	260	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
73	260	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
74	260	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
75	260	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
76	261	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
77	261	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
78	261	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
79	261	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
80	261	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
81	262	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
82	262	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
83	262	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
84	262	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
85	262	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
86	263	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
87	263	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
88	263	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
89	263	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
90	263	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
2222	65	CNTT đóng vai trò quan trọng nhất trong lĩnh vực nào sau đây?	multiple_choice	Giải trí	Giáo dục	Doanh nghiệp và đời sống xã hội	Thể thao	A	\N	1	2
91	264	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
92	264	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
93	264	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
94	264	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
95	264	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
96	265	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
97	265	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
98	265	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
99	265	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
100	265	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
101	266	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
102	266	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
103	266	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
104	266	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
105	266	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
106	267	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
107	267	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
108	267	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
109	267	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
110	267	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
111	268	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
112	268	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
113	268	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
114	268	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
115	268	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
116	269	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
117	269	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
118	269	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
119	269	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
120	269	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
121	270	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
122	270	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
123	270	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
124	270	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
125	270	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
126	271	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
127	271	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
128	271	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
129	271	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
130	271	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
131	272	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
132	272	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
133	272	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
134	272	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
135	272	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
2259	67	Back-end có nhiệm vụ chính là:	multiple_choice	Hiển thị giao diện	Xử lý logic và dữ liệu	Thiết kế giao diện	Tạo hiệu ứng	B	\N	1	9
136	273	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
137	273	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
138	273	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
139	273	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
140	273	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
141	274	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
142	274	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
143	274	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
144	274	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
145	274	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
146	275	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
147	275	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
148	275	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
149	275	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
150	275	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
151	276	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
152	276	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
153	276	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
154	276	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
155	276	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
156	277	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
157	277	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
158	277	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
159	277	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
160	277	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
161	278	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
162	278	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
163	278	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
164	278	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
165	278	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
166	279	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
167	279	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
168	279	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
169	279	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
170	279	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
171	280	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
172	280	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
173	280	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
174	280	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
175	280	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
176	281	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
177	281	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
178	281	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
179	281	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
180	281	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
2260	67	API là gì?	multiple_choice	Phần mềm đồ họa	Giao diện lập trình ứng dụng	Hệ điều hành	Trình duyệt	B	\N	1	10
181	282	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
182	282	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
183	282	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
184	282	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
185	282	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
186	283	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
187	283	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
188	283	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
189	283	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
190	283	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
191	284	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
192	284	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
193	284	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
194	284	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
195	284	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
196	285	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
197	285	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
198	285	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
199	285	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
200	285	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
201	286	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
202	286	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
203	286	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
204	286	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
205	286	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
206	287	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
207	287	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
208	287	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
209	287	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
210	287	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
211	288	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
212	288	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
213	288	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
214	288	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
215	288	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
216	289	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
217	289	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
218	289	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
219	289	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
220	289	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
221	290	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
222	290	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
223	290	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
224	290	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
225	290	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
226	291	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
227	291	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
228	291	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
229	291	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
230	291	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
231	292	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
232	292	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
233	292	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
234	292	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
235	292	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
236	293	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
237	293	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
238	293	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
239	293	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
240	293	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
241	294	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
242	294	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
243	294	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
244	294	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
245	294	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
246	295	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
247	295	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
248	295	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
249	295	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
250	295	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
251	296	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
252	296	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
253	296	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
254	296	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
255	296	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
256	297	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
257	297	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
258	297	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
259	297	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
260	297	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
261	298	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
262	298	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
263	298	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
264	298	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
265	298	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
266	299	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
267	299	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
268	299	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
269	299	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
270	299	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
271	300	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2261	67	Phần mềm doanh nghiệp (Enterprise Software) thường có đặc điểm nào?	multiple_choice	Quy mô nhỏ	Ít người sử dụng	Tích hợp nhiều chức năng	Không cần bảo mật	C	\N	1	11
272	300	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
273	300	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
274	300	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
275	300	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
276	301	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
277	301	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
278	301	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
279	301	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
280	301	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
281	302	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
282	302	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
283	302	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
284	302	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
285	302	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
286	303	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
287	303	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
288	303	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
289	303	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
290	303	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
291	304	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
292	304	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
293	304	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
294	304	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
295	304	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
296	305	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
297	305	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
298	305	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
299	305	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
300	305	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
301	306	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
302	306	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
303	306	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
304	306	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
305	306	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
306	307	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
307	307	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
308	307	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
309	307	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
310	307	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
311	308	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
312	308	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
313	308	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
314	308	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
315	308	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
316	309	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2262	67	ERP là viết tắt của:	multiple_choice	Enterprise Resource Planning	Electronic Resource Program	Enterprise Remote  Platform	Electronic Report Process	A	\N	1	12
317	309	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
318	309	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
319	309	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
320	309	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
321	310	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
322	310	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
323	310	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
324	310	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
325	310	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
326	311	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
327	311	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
328	311	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
329	311	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
330	311	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
331	312	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
332	312	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
333	312	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
334	312	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
335	312	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
336	313	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
337	313	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
338	313	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
339	313	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
340	313	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
341	314	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
342	314	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
343	314	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
344	314	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
345	314	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
346	315	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
347	315	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
348	315	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
349	315	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
350	315	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
351	316	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
352	316	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
353	316	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
354	316	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
355	316	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
356	317	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
357	317	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
358	317	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
359	317	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
360	317	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
361	318	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1711	588	React là gì?	multiple_choice	Ngôn ngữ	Thư viện	Framework backend	Database	b	\N	1	1
362	318	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
363	318	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
364	318	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
365	318	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
366	319	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
367	319	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
368	319	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
369	319	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
370	319	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
371	320	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
372	320	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
373	320	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
374	320	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
375	320	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
376	321	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
377	321	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
378	321	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
379	321	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
380	321	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
381	322	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
382	322	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
383	322	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
384	322	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
385	322	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
386	323	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
387	323	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
388	323	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
389	323	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
390	323	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
391	324	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
392	324	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
393	324	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
394	324	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
395	324	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
396	325	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
397	325	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
398	325	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
399	325	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
400	325	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
401	326	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
402	326	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
403	326	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
404	326	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
405	326	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
406	327	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2263	67	CRM dùng để:	multiple_choice	Quản lý tài nguyên	Quản lý khách hàng	Quản lý mạng	Quản lý phần cứng	B	\N	1	13
407	327	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
408	327	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
409	327	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
410	327	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
411	328	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
412	328	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
413	328	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
414	328	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
415	328	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
416	329	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
417	329	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
418	329	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
419	329	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
420	329	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
421	330	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
422	330	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
423	330	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
424	330	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
425	330	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
426	331	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
427	331	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
428	331	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
429	331	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
430	331	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
431	332	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
432	332	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
433	332	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
434	332	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
435	332	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
436	333	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
437	333	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
438	333	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
439	333	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
440	333	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
441	334	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
442	334	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
443	334	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
444	334	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
445	334	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
446	335	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
447	335	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
448	335	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
449	335	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
450	335	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
451	336	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2264	67	Cloud Computing là gì?	multiple_choice	Lưu trữ dữ liệu trên ổ cứng cá nhân	Cung cấp tài nguyên CNTT qua Internet	Phần mềm văn phòng	Thiết bị mạng	B	\N	1	14
452	336	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
453	336	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
454	336	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
455	336	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
456	337	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
457	337	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
458	337	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
459	337	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
460	337	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
461	338	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
462	338	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
463	338	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
464	338	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
465	338	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
466	339	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
467	339	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
468	339	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
469	339	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
470	339	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
471	340	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
472	340	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
473	340	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
474	340	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
475	340	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
476	341	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
477	341	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
478	341	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
479	341	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
480	341	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
481	342	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
482	342	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
483	342	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
484	342	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
485	342	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
486	343	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
487	343	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
488	343	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
489	343	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
490	343	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
491	344	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
492	344	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
493	344	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
494	344	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
495	344	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
496	345	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1716	589	FastAPI server nào?	multiple_choice	Apache	Nginx	Uvicorn	IIS	c	\N	1	1
497	345	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
498	345	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
499	345	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
500	345	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
501	346	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
502	346	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
503	346	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
504	346	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
505	346	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
506	347	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
507	347	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
508	347	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
509	347	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
510	347	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
511	348	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
512	348	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
513	348	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
514	348	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
515	348	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
516	349	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
517	349	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
518	349	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
519	349	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
520	349	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
521	350	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
522	350	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
523	350	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
524	350	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
525	350	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
526	351	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
527	351	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
528	351	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
529	351	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
530	351	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
531	352	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
532	352	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
533	352	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
534	352	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
535	352	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
536	353	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
537	353	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
538	353	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
539	353	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
540	353	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
541	354	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1717	589	ORM là gì?	multiple_choice	Object Relational Mapping	Online Resource Manager	Object Remote Memory	Operating Resource Model	a	\N	1	2
542	354	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
543	354	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
544	354	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
545	354	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
546	355	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
547	355	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
548	355	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
549	355	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
550	355	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
551	356	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
552	356	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
553	356	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
554	356	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
555	356	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
556	357	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
557	357	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
558	357	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
559	357	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
560	357	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
561	358	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
562	358	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
563	358	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
564	358	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
565	358	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
566	359	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
567	359	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
568	359	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
569	359	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
570	359	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
571	360	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
572	360	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
573	360	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
574	360	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
575	360	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
576	361	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
577	361	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
578	361	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
579	361	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
580	361	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
581	362	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
582	362	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
583	362	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
584	362	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
585	362	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
586	363	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1718	589	JWT dùng để?	multiple_choice	Database	Xác thực	Routing	Testing	b	\N	1	3
587	363	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
588	363	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
589	363	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
590	363	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
591	364	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
592	364	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
593	364	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
594	364	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
595	364	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
596	365	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
597	365	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
598	365	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
599	365	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
600	365	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
601	366	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
602	366	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
603	366	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
604	366	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
605	366	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
606	367	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
607	367	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
608	367	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
609	367	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
610	367	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
611	368	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
612	368	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
613	368	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
614	368	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
615	368	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
616	369	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
617	369	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
618	369	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
619	369	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
620	369	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
621	370	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
622	370	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
623	370	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
624	370	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
625	370	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
626	371	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
627	371	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
628	371	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
629	371	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
630	371	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
631	372	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1719	589	Decorator GET/POST?	multiple_choice	@app.get(), @app.post()	get(), post()	#get, #post	GET(), POST()	a	\N	1	4
1720	589	Kiểm tra quyền FastAPI?	multiple_choice	Middleware	Depends()	Headers	Query	b	\N	1	5
632	372	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
633	372	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
634	372	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
635	372	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
636	373	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
637	373	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
638	373	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
639	373	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
640	373	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
641	374	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
642	374	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
643	374	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
644	374	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
645	374	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
646	375	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
647	375	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
648	375	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
649	375	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
650	375	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
651	376	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
652	376	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
653	376	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
654	376	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
655	376	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
656	377	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
657	377	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
658	377	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
659	377	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
660	377	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
661	378	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
662	378	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
663	378	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
664	378	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
665	378	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
666	379	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
667	379	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
668	379	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
669	379	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
670	379	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
671	380	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
672	380	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
673	380	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
674	380	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
675	380	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
676	381	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1721	590	CSDL quan hệ chứa?	multiple_choice	Đối tượng	Bảng, hàng, cột	Hàm	Hình ảnh	b	\N	1	1
1722	590	SELECT dùng để?	multiple_choice	Thêm	Lấy	Sửa	Xóa	b	\N	1	2
677	381	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
678	381	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
679	381	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
680	381	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
681	382	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
682	382	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
683	382	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
684	382	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
685	382	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
686	383	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
687	383	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
688	383	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
689	383	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
690	383	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
691	384	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
692	384	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
693	384	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
694	384	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
695	384	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
696	385	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
697	385	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
698	385	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
699	385	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
700	385	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
701	386	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
702	386	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
703	386	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
704	386	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
705	386	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
706	387	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
707	387	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
708	387	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
709	387	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
710	387	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
711	388	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
712	388	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
713	388	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
714	388	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
715	388	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
716	389	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
717	389	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
718	389	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
719	389	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
720	389	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
721	390	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1723	590	INNER JOIN trả về?	multiple_choice	Giao	Hợp	Hiệu	Bù	a	\N	1	3
722	390	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
723	390	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
724	390	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
725	390	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
726	391	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
727	391	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
728	391	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
729	391	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
730	391	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
731	392	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
732	392	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
733	392	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
734	392	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
735	392	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
736	393	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
737	393	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
738	393	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
739	393	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
740	393	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
741	394	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
742	394	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
743	394	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
744	394	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
745	394	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
746	395	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
747	395	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
748	395	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
749	395	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
750	395	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
751	396	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
752	396	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
753	396	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
754	396	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
755	396	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
756	397	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
757	397	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
758	397	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
759	397	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
760	397	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
761	398	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
762	398	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
763	398	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
764	398	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
765	398	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
766	399	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1724	590	Index tác dụng?	multiple_choice	Thêm dữ liệu	Xóa dữ liệu	Tăng tốc truy vấn	Bảo mật	c	\N	1	4
767	399	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
768	399	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
769	399	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
770	399	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
771	400	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
772	400	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
773	400	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
774	400	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
775	400	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
776	401	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
777	401	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
778	401	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
779	401	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
780	401	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
781	402	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
782	402	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
783	402	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
784	402	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
785	402	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
786	403	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
787	403	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
788	403	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
789	403	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
790	403	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
791	404	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
792	404	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
793	404	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
794	404	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
795	404	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
796	405	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
797	405	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
798	405	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
799	405	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
800	405	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
801	406	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
802	406	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
803	406	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
804	406	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
805	406	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
806	407	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
807	407	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
808	407	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
809	407	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
810	407	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
811	408	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1725	590	Khóa chính dùng?	multiple_choice	Tìm kiếm	Xác định duy nhất	Liên kết bảng	Sắp xếp	b	\N	1	5
812	408	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
813	408	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
814	408	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
815	408	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
816	409	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
817	409	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
818	409	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
819	409	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
820	409	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
821	410	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
822	410	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
823	410	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
824	410	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
825	410	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
826	411	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
827	411	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
828	411	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
829	411	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
830	411	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
831	412	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
832	412	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
833	412	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
834	412	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
835	412	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
836	413	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
837	413	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
838	413	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
839	413	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
840	413	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
841	414	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
842	414	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
843	414	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
844	414	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
845	414	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
846	415	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
847	415	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
848	415	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
849	415	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
850	415	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
851	416	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
852	416	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
853	416	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
854	416	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
855	416	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
856	417	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1702	586	Biến trong lập trình là gì?	multiple_choice	int	float	str	bool	b	\N	1	2
1703	586	Kiểu dữ liệu Integer được dùng để:	multiple_choice	!=	==	=>	<=	b	\N	1	3
857	417	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
858	417	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
859	417	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
860	417	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
861	418	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
862	418	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
863	418	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
864	418	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
865	418	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
866	419	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
867	419	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
868	419	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
869	419	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
870	419	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
871	420	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
872	420	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
873	420	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
874	420	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
875	420	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
876	421	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
877	421	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
878	421	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
879	421	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
880	421	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
881	422	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
882	422	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
883	422	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
884	422	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
885	422	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
886	423	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
887	423	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
888	423	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
889	423	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
890	423	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
891	424	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
892	424	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
893	424	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
894	424	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
895	424	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
896	425	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
897	425	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
898	425	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
899	425	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
900	425	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
901	426	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1704	586	Toán tử // trong Python là gì?	multiple_choice	FIFO	LIFO	LILO	OILF	b	\N	1	4
2431	85	Python là gì	multiple_choice	Ngôn ngữ lập trình	Hehe	Là python	Keke	a	Vì vậy đó	1	1
902	426	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
903	426	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
904	426	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
905	426	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
906	427	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
907	427	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
908	427	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
909	427	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
910	427	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
911	428	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
912	428	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
913	428	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
914	428	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
915	428	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
916	429	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
917	429	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
918	429	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
919	429	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
920	429	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
921	430	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
922	430	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
923	430	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
924	430	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
925	430	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
926	431	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
927	431	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
928	431	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
929	431	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
930	431	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
931	432	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
932	432	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
933	432	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
934	432	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
935	432	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
936	433	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
937	433	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
938	433	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
939	433	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
940	433	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
941	434	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
942	434	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
943	434	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
944	434	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
945	434	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
946	435	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1705	586	Câu lệnh IF được sử dụng để:	multiple_choice	Không biết số lần	Biết số lần lặp	Kiểm tra điều kiện	Thoát khỏi chương trình	b	\N	1	5
947	435	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
948	435	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
949	435	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
950	435	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
951	436	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
952	436	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
953	436	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
954	436	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
955	436	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
956	437	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
957	437	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
958	437	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
959	437	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
960	437	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
961	438	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
962	438	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
963	438	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
964	438	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
965	438	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
966	439	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
967	439	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
968	439	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
969	439	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
970	439	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
971	440	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
972	440	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
973	440	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
974	440	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
975	440	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
976	441	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
977	441	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
978	441	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
979	441	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
980	441	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
981	442	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
982	442	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
983	442	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
984	442	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
985	442	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
986	443	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
987	443	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
988	443	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
989	443	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
990	443	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
991	444	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1706	587	Array là gì?	multiple_choice	O(n)	O(n²)	O(1)	O(log n)	c	\N	1	1
1707	587	Stack là LIFO có nghĩa là:	multiple_choice	LIFO	FIFO	LILO	Random	b	\N	1	2
992	444	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
993	444	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
994	444	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
995	444	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
996	445	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
997	445	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
998	445	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
999	445	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1000	445	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1001	446	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1002	446	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1003	446	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1004	446	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1005	446	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1006	447	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1007	447	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1008	447	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1009	447	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1010	447	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1011	448	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1012	448	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1013	448	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1014	448	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1015	448	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1016	449	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1017	449	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1018	449	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1019	449	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1020	449	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1021	450	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1022	450	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1023	450	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1024	450	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1025	450	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1026	451	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1027	451	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1028	451	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1029	451	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1030	451	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1031	452	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1032	452	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1033	452	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1034	452	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1035	452	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1036	453	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1708	587	Queue được sử dụng trong trường hợp:	multiple_choice	O(n)	O(n²)	O(n log n)	O(log n)	c	\N	1	3
1037	453	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1038	453	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1039	453	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1040	453	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1041	454	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1042	454	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1043	454	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1044	454	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1045	454	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1046	455	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1047	455	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1048	455	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1049	455	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1050	455	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1051	456	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1052	456	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1053	456	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1054	456	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1055	456	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1056	457	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1057	457	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1058	457	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1059	457	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1060	457	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1061	458	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1062	458	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1063	458	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1064	458	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1065	458	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1066	459	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1067	459	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1068	459	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1069	459	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1070	459	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1071	460	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1072	460	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1073	460	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1074	460	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1075	460	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1076	461	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1077	461	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1078	461	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1079	461	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1080	461	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1081	462	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1709	587	Linked List so với Array, thế mạnh là:	multiple_choice	O(1)	O(n)	O(n²)	O(log n)	a	\N	1	4
2432	85	Ai dạy môn này	multiple_choice	Thầy Sơn	Cô Hồng	Cô Vân	Cô Vy	a		1	2
1082	462	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1083	462	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1084	462	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1085	462	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1086	463	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1087	463	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1088	463	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1089	463	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1090	463	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1091	464	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1092	464	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1093	464	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1094	464	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1095	464	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1096	465	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1097	465	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1098	465	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1099	465	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1100	465	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1101	466	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1102	466	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1103	466	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1104	466	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1105	466	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1106	467	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1107	467	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1108	467	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1109	467	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1110	467	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1111	468	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1112	468	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1113	468	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1114	468	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1115	468	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1116	469	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1117	469	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1118	469	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1119	469	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1120	469	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1121	470	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1122	470	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1123	470	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1124	470	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1125	470	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1126	471	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1710	587	Cho dữ liệu lớn (100,000 phần tử), nên dùng thuật toán sắp xếp nào?	multiple_choice	Queue	Stack	Array	Tree	b	\N	1	5
1127	471	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1128	471	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1129	471	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1130	471	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1131	472	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1132	472	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1133	472	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1134	472	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1135	472	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1136	473	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1137	473	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1138	473	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1139	473	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1140	473	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1141	474	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1142	474	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1143	474	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1144	474	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1145	474	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1146	475	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1147	475	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1148	475	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1149	475	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1150	475	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1151	476	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1152	476	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1153	476	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1154	476	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1155	476	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1156	477	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1157	477	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1158	477	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1159	477	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1160	477	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1161	478	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1162	478	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1163	478	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1164	478	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1165	478	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1166	479	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1167	479	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1168	479	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1169	479	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1170	479	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1171	480	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1712	588	Props trong React dùng để:	multiple_choice	Lưu state	Truyền dữ liệu	Render lại	Gọi API	b	\N	1	2
1172	480	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1173	480	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1174	480	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1175	480	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1176	481	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1177	481	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1178	481	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1179	481	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1180	481	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1181	482	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1182	482	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1183	482	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1184	482	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1185	482	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1186	483	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1187	483	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1188	483	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1189	483	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1190	483	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1191	484	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1192	484	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1193	484	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1194	484	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1195	484	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1196	485	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1197	485	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1198	485	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1199	485	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1200	485	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1201	486	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1202	486	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1203	486	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1204	486	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1205	486	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1206	487	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1207	487	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1208	487	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1209	487	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1210	487	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1211	488	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1212	488	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1213	488	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1214	488	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1215	488	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1216	489	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1713	588	State khác Props ở chỗ:	multiple_choice	State	[state, setState]	setState	value	b	\N	1	3
1217	489	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1218	489	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1219	489	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1220	489	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1221	490	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1222	490	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1223	490	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1224	490	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1225	490	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1226	491	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1227	491	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1228	491	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1229	491	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1230	491	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1231	492	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1232	492	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1233	492	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1234	492	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1235	492	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1236	493	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1237	493	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1238	493	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1239	493	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1240	493	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1241	494	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1242	494	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1243	494	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1244	494	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1245	494	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1246	495	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1247	495	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1248	495	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1249	495	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1250	495	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1251	496	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1252	496	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1253	496	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1254	496	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1255	496	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1256	497	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1257	497	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1258	497	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1259	497	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1260	497	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1261	498	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1714	588	useState Hook được sử dụng để:	multiple_choice	Không bắt buộc	Bắt buộc luôn	Tùy case	Chỉ với async	c	\N	1	4
1262	498	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1263	498	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1264	498	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1265	498	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1266	499	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1267	499	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1268	499	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1269	499	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1270	499	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1271	500	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1272	500	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1273	500	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1274	500	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1275	500	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1276	501	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1277	501	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1278	501	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1279	501	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1280	501	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1281	502	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1282	502	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1283	502	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1284	502	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1285	502	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1286	503	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1287	503	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1288	503	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1289	503	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1290	503	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1291	504	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1292	504	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1293	504	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1294	504	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1295	504	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1296	505	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1297	505	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1298	505	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1299	505	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1300	505	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1301	506	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1302	506	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1303	506	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1304	506	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1305	506	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1306	507	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1715	588	useEffect Hook với dependency array rỗng [] sẽ:	multiple_choice	Router	BrowserRouter	Route	Tất cả	d	\N	1	5
1307	507	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1308	507	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1309	507	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1310	507	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1311	508	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1312	508	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1313	508	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1314	508	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1315	508	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1316	509	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1317	509	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1318	509	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1319	509	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1320	509	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1321	510	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1322	510	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1323	510	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1324	510	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1325	510	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1326	511	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1327	511	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1328	511	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1329	511	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1330	511	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1331	512	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1332	512	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1333	512	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1334	512	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1335	512	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1336	513	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1337	513	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1338	513	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1339	513	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1340	513	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1341	514	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1342	514	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1343	514	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1344	514	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1345	514	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1346	515	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1347	515	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1348	515	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1349	515	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1350	515	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1351	516	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2437	86	Bài học có hay không	multiple_choice	có	kó	ko	không	a		1	1
1352	516	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1353	516	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1354	516	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1355	516	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1356	517	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1357	517	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1358	517	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1359	517	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1360	517	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1361	518	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1362	518	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1363	518	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1364	518	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1365	518	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1366	519	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1367	519	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1368	519	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1369	519	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1370	519	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1371	520	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1372	520	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1373	520	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1374	520	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1375	520	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1376	521	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1377	521	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1378	521	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1379	521	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1380	521	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1381	522	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1382	522	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1383	522	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1384	522	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1385	522	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1386	523	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1387	523	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1388	523	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1389	523	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1390	523	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1391	524	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1392	524	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1393	524	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1394	524	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1395	524	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1396	525	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2265	67	Mô hình SaaS là:	multiple_choice	Thuê hạ tầng	Thuê nền tảng	Thuê phần mềm qua Internet	Tự xây dựng phần  mềm	C	\N	1	15
1397	525	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1398	525	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1399	525	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1400	525	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1401	526	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1402	526	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1403	526	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1404	526	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1405	526	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1406	527	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1407	527	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1408	527	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1409	527	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1410	527	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1411	528	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1412	528	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1413	528	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1414	528	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1415	528	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1416	529	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1417	529	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1418	529	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1419	529	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1420	529	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1421	530	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1422	530	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1423	530	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1424	530	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1425	530	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1426	531	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1427	531	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1428	531	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1429	531	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1430	531	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1431	532	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1432	532	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1433	532	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1434	532	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1435	532	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1436	533	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1437	533	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1438	533	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1439	533	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1440	533	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1441	534	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2266	67	SDLC là viết tắt của:	multiple_choice	Software Development Life Cycle	System Data Logic Control	Software Data Link  Code		A	\N	1	16
1442	534	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1443	534	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1444	534	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1445	534	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1446	535	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1447	535	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1448	535	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1449	535	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1450	535	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1451	536	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1452	536	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1453	536	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1454	536	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1455	536	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1456	537	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1457	537	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1458	537	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1459	537	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1460	537	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1461	538	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1462	538	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1463	538	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1464	538	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1465	538	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1466	539	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1467	539	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1468	539	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1469	539	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1470	539	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1471	540	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1472	540	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1473	540	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1474	540	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1475	540	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1476	541	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1477	541	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1478	541	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1479	541	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1480	541	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1481	542	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1482	542	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1483	542	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1484	542	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1485	542	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1486	543	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2267	67	Giai đoạn nào trong SDLC dùng để tìm và sửa lỗi?	multiple_choice	Phân tích	Thiết kế	Kiểm thử		C	\N	1	17
1487	543	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1488	543	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1489	543	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1490	543	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1491	544	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1492	544	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1493	544	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1494	544	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1495	544	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1496	545	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1497	545	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1498	545	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1499	545	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1500	545	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1501	546	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1502	546	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1503	546	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1504	546	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1505	546	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1506	547	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1507	547	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1508	547	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1509	547	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1510	547	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1511	548	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1512	548	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1513	548	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1514	548	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1515	548	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1516	549	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1517	549	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1518	549	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1519	549	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1520	549	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1521	550	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1522	550	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1523	550	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1524	550	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1525	550	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1526	551	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1527	551	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1528	551	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1529	551	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1530	551	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1531	552	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2268	67	Yếu tố nào quan trọng nhất khi doanh nghiệp lựa chọn phần mềm?	multiple_choice	Màu sắc giao diện	Giá rẻ	Bảo mật và khả năng mở rộng	Ít chức năng	C	\N	1	18
1532	552	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1533	552	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1534	552	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1535	552	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1536	553	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1537	553	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1538	553	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1539	553	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1540	553	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1541	554	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1542	554	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1543	554	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1544	554	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1545	554	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1546	555	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1547	555	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1548	555	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1549	555	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1550	555	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1551	556	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1552	556	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1553	556	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1554	556	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1555	556	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1556	557	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1557	557	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1558	557	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1559	557	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1560	557	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1561	558	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1562	558	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1563	558	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1564	558	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1565	558	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1566	559	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1567	559	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1568	559	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1569	559	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1570	559	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1571	560	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1572	560	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1573	560	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1574	560	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1575	560	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1576	561	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2269	67	On-Premise là mô hình triển khai phần mềm:	multiple_choice	Trên đám mây	Thuê dịch vụ	Cài đặt và vận hành tại doanh nghiệp	Không cần  máy chủ	C	\N	1	19
1577	561	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1578	561	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1579	561	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1580	561	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1581	562	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1582	562	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1583	562	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1584	562	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1585	562	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1586	563	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1587	563	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1588	563	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1589	563	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1590	563	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1591	564	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1592	564	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1593	564	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1594	564	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1595	564	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1596	565	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1597	565	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1598	565	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1599	565	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1600	565	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1601	566	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1602	566	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1603	566	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1604	566	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1605	566	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1606	567	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1607	567	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1608	567	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1609	567	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1610	567	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1611	568	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1612	568	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1613	568	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1614	568	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1615	568	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1616	569	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1617	569	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1618	569	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1619	569	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1620	569	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1621	570	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2270	67	Vai trò của CNTT trong doanh nghiệp là:	multiple_choice	Giảm nhân sự	Tăng hiệu quả và khả năng cạnh tranh	Thay thế hoàn toàn con  người	Chỉ phục vụ kế toán	B	\N	1	20
1622	570	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1623	570	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1624	570	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1625	570	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1626	571	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1627	571	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1628	571	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1629	571	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1630	571	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1631	572	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1632	572	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1633	572	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1634	572	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1635	572	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1636	573	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1637	573	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1638	573	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1639	573	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1640	573	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1641	574	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1642	574	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1643	574	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1644	574	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1645	574	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1646	575	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1647	575	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1648	575	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1649	575	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1650	575	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1651	576	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1652	576	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1653	576	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1654	576	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1655	576	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1656	577	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1657	577	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1658	577	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1659	577	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1660	577	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1661	578	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1662	578	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1663	578	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1664	578	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1665	578	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1666	579	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
2271	68	World Wide Web (WWW) là gì?	multiple_choice	Một hệ điều hành	Một dịch vụ hoạt động trên Internet	Một mạng máy tính	Một phần mềm văn phòng	B	\N	1	1
1667	579	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1668	579	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1669	579	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1670	579	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1671	580	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1672	580	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1673	580	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1674	580	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1675	580	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1676	581	Câu 1: Khái niệm chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1677	581	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Giới thiệu và Khái niệm cơ bản'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1678	581	Câu 3: Bước đầu tiên trong 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1679	581	Câu 4: Lợi ích chính của 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1680	581	Câu 5: Thách thức khi áp dụng 'Giới thiệu và Khái niệm cơ bản' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1681	582	Câu 1: Khái niệm chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1682	582	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Các nguyên tắc và lý thuyết'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1683	582	Câu 3: Bước đầu tiên trong 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1684	582	Câu 4: Lợi ích chính của 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1685	582	Câu 5: Thách thức khi áp dụng 'Các nguyên tắc và lý thuyết' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1686	583	Câu 1: Khái niệm chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1687	583	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Ứng dụng thực tế'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1688	583	Câu 3: Bước đầu tiên trong 'Ứng dụng thực tế' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1689	583	Câu 4: Lợi ích chính của 'Ứng dụng thực tế' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1690	583	Câu 5: Thách thức khi áp dụng 'Ứng dụng thực tế' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1691	584	Câu 1: Khái niệm chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1692	584	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Công cụ và Kỹ thuật'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1693	584	Câu 3: Bước đầu tiên trong 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1694	584	Câu 4: Lợi ích chính của 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1695	584	Câu 5: Thách thức khi áp dụng 'Công cụ và Kỹ thuật' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
1696	585	Câu 1: Khái niệm chính của 'Dự án cuối khoá' là gì?	multiple_choice	Đáp án A: Định nghĩa đúng	Đáp án B: Định nghĩa sai	Đáp án C: Định nghĩa sai	Đáp án D: Định nghĩa sai	a	Đây là khái niệm đúng dựa trên nội dung bài học.	2	1
1697	585	Câu 2: Ứng dụng nào là ví dụ thực tế của 'Dự án cuối khoá'?	multiple_choice	Ứng dụng A không phù hợp	Ứng dụng B là chính xác	Ứng dụng C không phù hợp	Ứng dụng D không phù hợp	b	Ứng dụng B là ví dụ đúng được đề cập trong bài học.	2	2
1698	585	Câu 3: Bước đầu tiên trong 'Dự án cuối khoá' là gì?	multiple_choice	Bước A là đúng	Bước B không đúng	Bước C không đúng	Bước D không đúng	a	Bước A là bước khởi đầu được giải thích chi tiết trong bài học.	2	3
1699	585	Câu 4: Lợi ích chính của 'Dự án cuối khoá' là gì?	multiple_choice	Lợi ích A là đúng	Lợi ích B không phù hợp	Lợi ích C không phù hợp	Lợi ích D không phù hợp	a	Lợi ích A được nhấn mạnh trong bài học này.	2	4
1700	585	Câu 5: Thách thức khi áp dụng 'Dự án cuối khoá' là gì?	multiple_choice	Thách thức A không phải là vấn đề	Thách thức B là vấn đề chính	Thách thức C không phải là vấn đề	Thách thức D không phải là vấn đề	b	Thách thức B là vấn đề chính được thảo luận trong bài học.	2	5
2201	64	Thành phần nào được xem là “bộ não” của máy tính?	multiple_choice	RAM	CPU	Ổ cứng	Card đồ họa	B	\N	1	1
2202	64	Chức năng chính của RAM là gì?	multiple_choice	Lưu trữ dữ liệu lâu dài	Xử lý đồ họa	Lưu trữ tạm thời dữ liệu khi máy đang hoạt động	Cung cấp nguồn điện	C	\N	1	2
2203	64	Thiết bị nào sau đây dùng để lưu trữ dữ liệu lâu dài?	multiple_choice	RAM	CPU	Ổ cứng (HDD/SS	D. Cache	C	\N	1	3
2204	64	Công cụ nào trong Windows dùng để xem nhanh hiệu năng CPU, RAM?	multiple_choice	Control Panel	Task Manager	Device Manager	File Explorer	B	\N	1	4
2205	64	Lệnh nào dùng để xem thông tin chi tiết cấu hình hệ thống trong Windows?	multiple_choice	dxdiag	taskmgr	msinfo32	cmd	C	\N	1	5
2206	64	dxdiag chủ yếu dùng để kiểm tra thông tin nào?	multiple_choice	Ổ cứng	Card mạng	Card đồ họa và âm thanh	Nguồn điện	C	\N	1	6
2207	64	Hệ đếm nhị phân sử dụng bao nhiêu ký số?	multiple_choice	2	8	10	16	A	\N	1	7
2208	64	Các ký số của hệ nhị phân là:	multiple_choice	0, 1	0 – 7	0 – 9	0 – F	A	\N	1	8
2209	64	Hệ đếm thập lục phân có cơ số là:	multiple_choice	2	8	10	16	D	\N	1	9
2210	64	Trong hệ thập lục phân, ký tự “A” tương ứng với giá trị thập phân nào?	multiple_choice	9	10	11	15	B	\N	1	10
2211	64	Số nhị phân 1010₂ tương đương với số thập phân nào?	multiple_choice	8	9	10	12	C	\N	1	11
2212	64	Số thập phân 15₁₀ tương đương với số nhị phân nào?	multiple_choice	1010	1100	1111	1001	C	\N	1	12
2213	64	Hệ bát phân có cơ số là:	multiple_choice	2	8	10	16	B	\N	1	13
2214	64	Đơn vị đo thông tin nhỏ nhất trong máy tính là:	multiple_choice	Byte	D. MB	K		B	\N	1	14
2215	64	Một byte tương đương với bao nhiêu bit?	multiple_choice	4	6	8	16	C	\N	1	15
2216	64	Hệ đếm nào được sử dụng trực tiếp trong hoạt động của máy tính?	multiple_choice	Thập phân	Bát phân	Thập lục phân	Nhị phân	D	\N	1	16
2217	64	Ứng dụng phổ biến của hệ thập lục phân trong CNTT là:	multiple_choice	Tính toán số học	Mã màu, địa chỉ bộ nhớ	Soạn thảo văn bản	Lập trình giao diện	B	\N	1	17
2218	64	CPU trên máy tính để bàn thường mạnh hơn CPU điện thoại vì:	multiple_choice	Có pin lớn hơn	Có khả năng tản nhiệt tốt hơn	Có màn hình lớn hơn	Có hệ điều  hành khác	B	\N	1	18
2219	64	Thiết bị nào sau đây KHÔNG phải là phần cứng?	multiple_choice	RAM	Windows	CPU	Ổ cứng	B	\N	1	19
2220	64	Mục tiêu chính của việc học hệ đếm trong CNTT là:	multiple_choice	Ghi nhớ công thức	Hiểu cách máy tính biểu diễn và xử lý dữ liệu	Tăng tốc độ máy	Lập trình giao diện	B	\N	1	20
2221	65	Mục tiêu chính của môn Nhập môn Công nghệ Thông tin là:	multiple_choice	Dạy lập trình nâng cao	Cung cấp kiến thức tổng quan về CNTT	Chỉ học phần  cứng máy tính	Chỉ học phần mềm văn phòng	A	\N	1	1
2223	65	Một trong những kỹ năng sinh viên được rèn luyện trong môn học là:	multiple_choice	Kỹ năng vẽ kỹ thuật	Kỹ năng tìm kiếm và khai thác thông tin	Kỹ năng thiết kế đồ  họa nâng cao	Kỹ năng quản trị mạng chuyên sâu	A	\N	1	3
2224	65	Nội dung nào KHÔNG thuộc phạm vi môn học?	multiple_choice	Phần cứng máy tính	Phần mềm	Mạng máy tính	Lập trình trí tuệ nhân tạo nâng  cao	A	\N	1	4
2225	65	Môn học giúp sinh viên định hướng điều gì?	multiple_choice	Nghề nghiệp trong lĩnh vực CNTT	Chỉ học lập trình	Chỉ học thiết kế web	Chỉ  học sửa chữa máy tính	A	\N	1	5
2226	65	Hình thức đánh giá trong môn học bao gồm:	multiple_choice	Chỉ thi cuối kỳ	Chỉ làm bài tập nhóm	Quá trình và thi cuối kỳ	Không có đánh  giá	A	\N	1	6
2227	65	Điểm chuyên cần được tính dựa trên yếu tố nào?	multiple_choice	Điểm thi cuối kỳ	Tham gia đầy đủ các buổi học	Làm bài tập về nhà	Thuyết  trình nhóm	A	\N	1	7
2228	65	Chuẩn đầu ra (CLO) dùng để:	multiple_choice	Đánh giá giảng viên	Xác định mục tiêu học tập của sinh viên	Xác định học phí	Xác định lịch thi	A	\N	1	8
2229	65	Môn Nhập môn CNTT thường được học vào:	multiple_choice	Năm cuối	Học kỳ đầu tiên	Học kỳ cuối	Sau khi tốt nghiệp	A	\N	1	9
2230	65	Sinh viên cần chuẩn bị gì khi tham gia môn học?	multiple_choice	Máy tính cá nhân	Giấy bút ghi chép	Tham gia đầy đủ các buổi học	Tất cả các	A	\N	1	10
2231	66	Theo Luật Công nghệ Thông tin Việt Nam, CNTT là gì?	multiple_choice	Ngành học về máy tính	Tập hợp các phương pháp và công cụ xử lý thông tin số	Chỉ bao gồm phần mềm	Chỉ bao gồm phần cứng	B	\N	1	1
2232	66	CNTT được cấu thành từ bao nhiêu trụ cột chính?	multiple_choice	2	3	4	5	C	\N	1	2
2233	66	Thành phần nào sau đây KHÔNG thuộc trụ cột của CNTT?	multiple_choice	Phần cứng	Phần mềm	Mạng máy tính	Trí tuệ nhân tạo	D	\N	1	3
2234	66	Thiết bị nào sau đây là phần cứng?	multiple_choice	Windows	Microsoft Word	CPU	Google Chrome	C	\N	1	4
2235	66	Chức năng chính của CPU là:	multiple_choice	Lưu trữ dữ liệu	Xử lý và điều khiển hoạt động của máy tính	Hiển thị hình ảnh	Cung cấp nguồn điện	B	\N	1	5
2236	66	RAM là loại bộ nhớ:	multiple_choice	Lưu trữ lâu dài	Chỉ đọc	Lưu trữ tạm thời khi máy hoạt động	Lưu trữ hệ điều  hành vĩnh viễn	C	\N	1	6
2237	66	Thiết bị nào sau đây thuộc nhóm thiết bị ngoại vi?	multiple_choice	CPU	RAM	Bàn phím	Bo mạch chủ	C	\N	1	7
2238	66	Bus hệ thống có chức năng:	multiple_choice	Lưu trữ dữ liệu	Kết nối và truyền dữ liệu giữa các thành phần	Cung cấp điện	Hiển thị hình ảnh	B	\N	1	8
2239	66	Máy tính thế hệ thứ nhất sử dụng linh kiện chính nào?	multiple_choice	Transistor	Mạch tích hợp	Ống chân không	Vi xử lý	C	\N	1	9
2240	66	Mạch tích hợp (IC) xuất hiện ở thế hệ máy tính nào?	multiple_choice	Thế hệ 1	Thế hệ 2	Thế hệ 3		C	\N	1	10
2241	66	Cách mạng công nghiệp 4.0 gắn liền với công nghệ nào?	multiple_choice	Máy hơi nước	Điện khí hóa	Tự động hóa cơ bản	Trí tuệ nhân tạo và IoT	D	\N	1	11
2242	66	Đơn vị đo thông tin nhỏ nhất là:	multiple_choice	Byte	D. MB	K		B	\N	1	12
2243	66	Hệ đếm là gì?	multiple_choice	Cách lưu trữ dữ liệu	Tập hợp ký hiệu và quy tắc biểu diễn số	Phần mềm tính  toán	Thiết bị phần cứng	B	\N	1	13
2244	66	Hệ nhị phân có cơ số là:	multiple_choice	2	8	10	16	A	\N	1	14
2245	66	Hệ thập phân sử dụng các ký số nào?	multiple_choice	0 – 1	0 – 7	0 – 9	0 – F	C	\N	1	15
2246	66	Hệ thập lục phân thường được dùng để:	multiple_choice	Soạn thảo văn bản	Biểu diễn màu sắc và địa chỉ bộ nhớ	Lưu trữ âm thanh	Lập  trình giao diện	B	\N	1	16
2247	66	Một byte tương đương với:	multiple_choice	4 bit	6 bit	8 bit	16 bit	C	\N	1	17
2248	66	Hệ đếm nào được máy tính sử dụng trực tiếp?	multiple_choice	Thập phân	Bát phân	Thập lục phân	Nhị phân	D	\N	1	18
2249	66	Bảng mã ASCII dùng để:	multiple_choice	Lưu trữ hình ảnh	Biểu diễn ký tự bằng mã số	Tăng tốc độ xử lý	Mã hóa dữ liệu	B	\N	1	19
2250	66	Vai trò quan trọng nhất của CNTT trong xã hội hiện đại là:	multiple_choice	Giải trí	Tăng khả năng cạnh tranh và phát triển kinh tế	Thay thế con người	Chỉ  phục vụ học tập	B	\N	1	20
2251	67	Phần mềm (Software) là gì?	multiple_choice	Thiết bị vật lý của máy tính	Tập hợp các chương trình và dữ liệu điều khiển phần  cứng	Hệ thống mạng	Thiết bị lưu trữ	B	\N	1	1
2252	67	Phần mềm được chia thành mấy loại chính?	multiple_choice	2	3	4	5	B	\N	1	2
2253	67	Phần mềm hệ thống có chức năng chính là:	multiple_choice	Soạn thảo văn bản	Quản lý và điều khiển phần cứng	Thiết kế đồ họa	Lập trình  ứng dụng	B	\N	1	3
2254	67	Ví dụ nào sau đây là phần mềm hệ thống?	multiple_choice	Microsoft Word	Google Chrome	Windows	Photoshop	C	\N	1	4
2255	67	Phần mềm trung gian (Middleware) có vai trò gì?	multiple_choice	Giao tiếp trực tiếp với người dùng	Kết nối và hỗ trợ giao tiếp giữa các hệ thống	Quản lý phần cứng	Lưu trữ dữ liệu	B	\N	1	5
2256	67	Ví dụ nào sau đây là Middleware?	multiple_choice	Excel	Apache Web Server	Windows	PowerPoint	B	\N	1	6
2257	67	Phần mềm ứng dụng dùng để:	multiple_choice	Quản lý CPU	Phục vụ nhu cầu cụ thể của người dùng	Điều khiển thiết bị ngoại vi	Quản lý bộ nhớ	B	\N	1	7
2258	67	Front-end trong một ứng dụng là:	multiple_choice	Phần xử lý dữ liệu	Phần giao diện người dùng	Cơ sở dữ liệu	Máy chủ	B	\N	1	8
2272	68	Internet và WWW khác nhau ở điểm nào?	multiple_choice	Internet là dịch vụ, WWW là hạ tầng	Internet là hạ tầng, WWW là dịch vụ	Hai  khái niệm giống nhau	WWW không cần Internet	B	\N	1	2
2273	68	Ai là người đề xuất ý tưởng về World Wide Web?	multiple_choice	Bill Gates	Steve Jobs	Tim Berners-Lee	Mark Zuckerberg	C	\N	1	3
2274	68	HTML là gì?	multiple_choice	Ngôn ngữ lập trình	Ngôn ngữ đánh dấu siêu văn bản	Phần mềm thiết kế	Trình duyệt web	B	\N	1	4
2275	68	Thẻ nào dùng để tạo tiêu đề lớn nhất trong HTML?	multiple_choice	<h6>	<p>	<h1>	<title>	C	\N	1	5
2276	68	Thẻ nào dùng để tạo liên kết trong HTML?	multiple_choice	<link>	<a>	<href>	<url>	B	\N	1	6
2277	68	Thuộc tính nào của thẻ <img> dùng để chỉ đường dẫn hình ảnh?	multiple_choice	alt	href	src	link	C	\N	1	7
2278	68	Thẻ nào dùng để tạo danh sách không thứ tự?	multiple_choice	<ol>	<li>	<ul>	<dl>	C	\N	1	8
2279	68	HTML5 mang lại lợi ích chính nào?	multiple_choice	Tăng tốc độ Internet	Thêm các thẻ ngữ nghĩa giúp cấu trúc web rõ ràng hơn	Thay thế JavaScript	Thay thế CSS	B	\N	1	9
2280	68	Một website hoàn chỉnh thường kết hợp những công nghệ nào?	multiple_choice	HTML và Word	HTML, CSS và JavaScript	HTML và Excel	HTML và PowerPoint	B	\N	1	10
2281	69	Ngôn ngữ lập trình là gì?	multiple_choice	Phần mềm văn phòng	Ngôn ngữ dùng để giao tiếp giữa người với người	Ngôn  ngữ dùng để viết chương trình cho máy tính thực hiện	Hệ điều hành	C	\N	1	1
2282	69	Ngôn ngữ lập trình biên dịch (Compiled language) là:	multiple_choice	Thực thi từng dòng lệnh	Dịch toàn bộ chương trình sang mã máy trước khi chạy	Không cần biên dịch	Chỉ dùng cho web	B	\N	1	2
2283	69	Ngôn ngữ lập trình thông dịch (Interpreted language) có đặc điểm nào?	multiple_choice	Chạy nhanh hơn biên dịch	Dịch và thực thi từng dòng lệnh	Không có mã nguồn	Không có lỗi	B	\N	1	3
2284	69	Ngôn ngữ nào sau đây là ngôn ngữ biên dịch?	multiple_choice	Python	JavaScript	Java	PHP	C	\N	1	4
2285	69	Ngôn ngữ nào sau đây là ngôn ngữ thông dịch?	multiple_choice	C++	Java	Python	C#	C	\N	1	5
2286	69	Ưu điểm của ngôn ngữ biên dịch là:	multiple_choice	Dễ viết	Tốc độ thực thi nhanh	Không cần biên dịch	Dễ sửa lỗi	B	\N	1	6
2287	69	Java là ngôn ngữ lập trình có đặc điểm nào?	multiple_choice	Chỉ chạy trên Windows	Không hướng đối tượng	Độc lập nền tảng	Chỉ dùng  cho web	C	\N	1	7
2288	69	JavaScript thường được dùng để:	multiple_choice	Lập trình hệ điều hành	Tạo trang web tương tác	Quản lý cơ sở dữ liệu	Thiết  kế phần cứng	B	\N	1	8
2289	69	Sự khác nhau chính giữa Java và JavaScript là:	multiple_choice	Cú pháp giống nhau hoàn toàn	Java là biên dịch, JavaScript là thông dịch	JavaScript mạnh hơn Java	Java không cần biên dịch	B	\N	1	9
2290	69	Mục tiêu học ngôn ngữ lập trình trong môn Nhập môn CNTT là:	multiple_choice	Trở thành lập trình viên chuyên nghiệp	Hiểu khái niệm và nền tảng lập trình	Viết  phần mềm lớn	Phát triển trí tuệ nhân tạo	B	\N	1	10
2291	70	Trong Java, mọi chương trình đều phải nằm trong:	multiple_choice	Một hàm	Một file HTML	Một class	Một package	C	\N	1	1
2292	70	Phương thức nào là điểm bắt đầu thực thi của chương trình Java?	multiple_choice	start()	run()	main()	init()	C	\N	1	2
2293	70	Cú pháp đúng của phương thức main trong Java là:	multiple_choice	public void main()	static main(String args[])	public static void main(String[] args)	void main(String args)	C	\N	1	3
2294	70	Lệnh nào dùng để in nội dung ra màn hình trong Java?	multiple_choice	print()	echo	System.out.println()	cout	C	\N	1	4
2295	70	Tên file Java phải:	multiple_choice	Tùy ý đặt	Trùng với tên class	Giống tên biến	Giống tên package	B	\N	1	5
2296	70	Kiểu dữ liệu nào dùng để lưu số nguyên trong Java?	multiple_choice	double	String	int	boolean	C	\N	1	6
2297	70	Kiểu dữ liệu nào dùng để lưu chuỗi ký tự?	multiple_choice	char	int	String	boolean	C	\N	1	7
2298	70	Lớp Scanner trong Java dùng để:	multiple_choice	In dữ liệu	Nhập dữ liệu từ bàn phím	Tạo giao diện	Xử lý đồ họa	B	\N	1	8
2299	70	Để sử dụng Scanner, cần import thư viện nào?	multiple_choice	java.io.Scanner	java.lang.Scanner	java.util.Scanner	java.system.Scanner	C	\N	1	9
2300	70	Chú thích (comment) trong Java có tác dụng gì?	multiple_choice	Làm chương trình chạy nhanh hơn	Giải thích code, không ảnh hưởng khi chạy	Tạo biến	Tạo hàm	B	\N	1	10
2301	71	Trí tuệ nhân tạo (AI) là gì?	multiple_choice	Một phần mềm văn phòng	Một lĩnh vực của khoa học máy tính mô phỏng trí tuệ  con người	Một thiết bị phần cứng	Một hệ điều hành	B	\N	1	1
2302	71	Loại AI đang được sử dụng phổ biến hiện nay là:	multiple_choice	AI tổng quát	AI hẹp	AI sinh học	AI tự nhận thức	B	\N	1	2
2303	71	Ví dụ nào sau đây là AI tạo sinh (Generative AI)?	multiple_choice	Microsoft Word	ChatGPT	Windows	Excel	B	\N	1	3
2304	71	AI đóng vai trò gì đối với sinh viên CNTT?	multiple_choice	Thay thế hoàn toàn việc học	Công cụ hỗ trợ học tập và làm việc	Chỉ dùng để giải  trí	Không liên quan đến học tập	B	\N	1	4
2305	71	Việc sử dụng AI trong học tập được phép khi nào?	multiple_choice	Sao chép toàn bộ nội dung	Không cần hiểu nội dung	Hiểu và giải thích được nội  dung sử dụng	Giao toàn bộ cho AI	C	\N	1	5
2342	75	Thuộc  tính  nào  dùng  để thay  đổi  nội  dung  của  phần  tử HTML  bằng\nJavaScript?	multiple_choice	innerText	innerHTML	textContent	value	A	\N	1	2
2343	75	Cách nào sau đây dùng để truy cập phần tử theo ID trong JavaScript?	multiple_choice	document.querySelector()	document.getElementsByClassName()	document.getElementById()	trong JavaScript?	A	\N	1	3
2306	71	Hành vi nào sau đây bị xem là vi phạm đạo đức học thuật?	multiple_choice	Tham khảo AI để tìm ý tưởng	Nhờ AI giải thích khái niệm	Sao chép nội dung AI  mà không hiểu	Dùng AI để học tập cá nhân	C	\N	1	6
2307	71	Nguyên tắc quan trọng nhất khi sử dụng AI là:	multiple_choice	Sử dụng càng nhiều càng tốt	Minh bạch và chịu trách nhiệm	Không cần kiểm  chứng	Không cần trích dẫn	B	\N	1	7
2308	71	Rủi ro khi lạm dụng AI trong học tập là:	multiple_choice	Học nhanh hơn	Mất nền tảng kiến thức	Tăng kỹ năng tư duy	Hiểu sâu hơn	B	\N	1	8
2309	71	AI không nên được sử dụng để:	multiple_choice	Gợi ý ý tưởng	Hỗ trợ debug code	Thay thế hoàn toàn tư duy của người học	Tổng hợp thông tin	C	\N	1	9
2310	71	Thông điệp cốt lõi khi sử dụng AI trong môn học là:	multiple_choice	AI làm thay con người	AI là đối thủ của con người	AI là công cụ hỗ trợ, con  người chịu trách nhiệm	AI không cần kiểm soát	C	\N	1	10
2311	72	Mạng máy tính là gì?	multiple_choice	Một phần mềm	Tập hợp các máy tính kết nối với nhau để chia sẻ tài nguyên	Một  thiết bị phần cứng	Một hệ điều hành	B	\N	1	1
2312	72	Lệnh nào dùng để kiểm tra tên máy tính trong mạng?	multiple_choice	ipconfig	ping	hostname	nslookup	C	\N	1	2
2313	72	Lệnh ipconfig trên Windows dùng để:	multiple_choice	Kiểm tra tốc độ mạng	Xem cấu hình mạng của máy tính	Kiểm tra lỗi phần cứng	Cài đặt mạng	B	\N	1	3
2314	72	Địa chỉ IPv4 có dạng nào?	multiple_choice	6 nhóm số thập lục phân	4 nhóm số thập phân, ngăn cách bởi dấu chấm	8 nhóm  số nhị phân	Chuỗi ký tự	B	\N	1	4
2315	72	Lệnh ping dùng để:	multiple_choice	Kiểm tra kết nối mạng	Xem địa chỉ MA	C. Cài đặt IP	Chia sẻ dữ liệu	A	\N	1	5
2316	72	Lệnh nslookup dùng để:	multiple_choice	Kiểm tra tốc độ Internet	Phân giải tên miền sang địa chỉ IP	Kiểm tra phần cứng	Chia sẻ file	B	\N	1	6
2317	72	Lưu trữ đám mây (Cloud Storage) là:	multiple_choice	Lưu dữ liệu trên US	B. Lưu dữ liệu trên ổ cứng cá nhân	Lưu dữ liệu trên máy chủ  qua Internet	Lưu dữ liệu trên RAM	C	\N	1	7
2318	72	Dịch vụ nào sau đây là lưu trữ đám mây?	multiple_choice	Notepad	OneDrive	Paint	Calculator	B	\N	1	8
2319	72	Ưu điểm của lưu trữ đám mây là:	multiple_choice	Không cần Internet	Chỉ dùng trên một máy	Dễ chia sẻ và cộng tác	Không cần  bảo mật	C	\N	1	9
2320	72	Cộng tác theo thời gian thực trên cloud cho phép:	multiple_choice	Chỉ một người chỉnh sửa	Nhiều người cùng chỉnh sửa một tài liệu	Không lưu lịch  sử	Không chia sẻ được	B	\N	1	10
2321	73	JavaScript là gì?	multiple_choice	Ngôn ngữ lập trình biên dịch	Ngôn ngữ lập trình kịch bản dùng cho web	Hệ  điều hành	Phần mềm thiết kế	B	\N	1	1
2322	73	JavaScript thường được dùng để:	multiple_choice	Quản lý phần cứng	Tạo trang web tương tác	Thiết kế cơ sở dữ liệu	Lập trình  hệ điều hành	B	\N	1	2
2323	73	Thẻ nào dùng để nhúng JavaScript trực tiếp vào HTML?	multiple_choice	<js>	<javascript>	<script>	<code>	C	\N	1	3
2324	73	Phương thức nào dùng để truy xuất phần tử HTML theo id?	multiple_choice	document.query()	document.getElementById()	document.getTag()	document.select()	B	\N	1	4
2325	73	Thuộc tính nào dùng để thay đổi nội dung của một phần tử HTML?	multiple_choice	value	text	innerHTML	content	C	\N	1	5
2326	73	Sự kiện nào xảy ra khi người dùng nhấn nút chuột?	multiple_choice	onchange	onsubmit	onclick	onhover	C	\N	1	6
2327	73	JavaScript thường được đặt ở đâu trong file HTML?	multiple_choice	Chỉ trong <head>	Chỉ trong <body>	Trong <head> hoặc <body>	Ngoài file  HTML	C	\N	1	7
2328	73	Form validation trong JavaScript dùng để:	multiple_choice	Trang trí giao diện	Kiểm tra dữ liệu người dùng nhập	Lưu dữ liệu vào database	Tăng tốc độ web	B	\N	1	8
2329	73	Hàm setInterval() dùng để:	multiple_choice	Thực hiện lệnh một lần	Lặp lại một hành động theo thời gian	Dừng chương trình	Tạo biến	B	\N	1	9
2330	73	Ưu điểm chính của JavaScript là:	multiple_choice	Chạy nhanh hơn mọi ngôn ngữ	Tạo tính tương tác cho trang web	Thay thế hoàn  toàn HTML	Không cần trình duyệt	B	\N	1	10
2331	74	Khóa học này tập trung vào công nghệ nào trong phát triển web?	multiple_choice	Django và Flask	React và Node.js	Angular và Vue.js	PHP và Laravel	B	\N	1	1
2332	74	Framework nào được sử dụng nhiều nhất theo khảo sát năm 2024?	multiple_choice	React	Angular	Node.js	Express	C	\N	1	2
2333	74	Express là gì?	multiple_choice	Một cơ sở dữ liệu	Một ngôn ngữ lập trình	Một framework của Node.js	Một công cụ thiết kế UI	C	\N	1	3
2334	74	MongoDB là loại cơ sở dữ liệu nào?	multiple_choice	Quan hệ	Dạng bảng	NoSQL		C	\N	1	4
2335	74	Mô hình Full Stack bao gồm những lớp nào?	multiple_choice	UI, API, Database	Frontend, Middleware, Backend	Presentation, Business Logic, Data Access	HTML, CSS, JS	C	\N	1	5
2336	74	Công cụ nào được khuyến nghị để lập trình trong khóa học?	multiple_choice	Eclipse	Visual Studio Code	NetBeans	Sublime Text	B	\N	1	6
2337	74	Để khởi tạo file package.json, dùng lệnh nào?	multiple_choice	node init	npm install	npm init	node start	C	\N	1	7
2338	74	Đâu là một trong các tài liệu tham khảo chính của khóa học?	multiple_choice	https://vuejs.org	https://angular.io	https://react.dev	https://laravel.com	C	\N	1	8
2339	74	Tỷ lệ điểm của đồ án cuối kỳ là bao nhiêu?	multiple_choice	30%	40%	20%	50%	D	\N	1	9
2340	74	Sinh viên sẽ bị cấm thi nếu vắng bao nhiêu buổi?	multiple_choice	4 buổi	5 buổi	6 buổi	7 buổi	C	\N	1	10
2341	75	DOM trong HTML là gì?	multiple_choice	Một ngôn ngữ lập trình	Một kiểu dữ liệu	Mô hình đối tượng tài liệu	Một thẻ HTML đặc biệt	A	\N	1	1
2344	75	Câu lệnh nào dùng để thêm phần tử mới vào DOM?	multiple_choice	document.append()	document.createElement()	document.addElement()	document.insert()	A	\N	1	4
2345	75	CSS có thể được áp dụng theo cách nào?	multiple_choice	Inline	Internal	External	Tất cả các cách trên	A	\N	1	5
2346	75	Thuộc tính nào của thẻ <label> giúp liên kết với <input>?	multiple_choice	id	name	for	value	A	\N	1	6
2347	75	Sự kiện nào được sử dụng để xử lý khi người dùng nhấn nút?	multiple_choice	onhover	onchange	onsubmit	onclick	A	\N	1	7
2348	75	JavaScript có thể thay đổi thuộc tính nào sau đây của phần tử HTML?	multiple_choice	style	src	innerHTML	Tất cả các	A	\N	1	8
2349	76	Node.js là gì?	multiple_choice	Một framework JavaScript để xây dựng UI	Một trình duyệt web	Môi trường thực thi JavaScript phía máy chủ	Một cơ sở dữ liệu NoSQL	C	\N	1	1
2350	76	Express là gì?	multiple_choice	Một thư viện CSS	Một framework phát triển ứng dụng web cho Node.js	Một công cụ biên dịch JSX	Một phần mềm quản lý cơ sở dữ liệu	B	\N	1	2
2351	76	React là gì?	multiple_choice	Một framework backend	Một thư viện JavaScript để xây dựng giao diện người dùng	Một hệ quản trị cơ sở dữ liệu	Một công cụ kiểm thử	B	\N	1	3
2352	76	JSX là gì?	multiple_choice	Một ngôn ngữ lập trình mới	Một định dạng dữ liệu giống JSON	Một cú pháp mở rộng cho JavaScript cho phép viết HTML trong JS	Một loại CSS đặc biệt	C	\N	1	4
2353	76	Virtual DOM là gì?	multiple_choice	Một bản sao của cơ sở dữ liệu	Một bản sao ảo của DOM giúp React cập nhật hiệu quả hơn	Một trình duyệt ảo	Một công cụ kiểm thử DOM	B	\N	1	5
2354	76	Babel dùng để làm gì?	multiple_choice	Biên dịch CSS	Chạy ứng dụng React	Chuyển đổi JSX thành JavaScript thuần	Tạo cơ sở dữ liệu	C	\N	1	6
2355	76	Create React App dùng để?	multiple_choice	Tạo ứng dụng Angular	Tạo cấu trúc dự án React sẵn sàng sử dụng	Tạo file HTML	Tạo API backend	B	\N	1	7
2356	76	Lệnh nào dùng để tạo ứng dụng React với npx?	multiple_choice	npx create-react-app my-app	npm install react	node create app	react-init my-app	A	\N	1	8
2357	76	File nào là điểm bắt đầu của ứng dụng React?	multiple_choice	App.js	index.html	index.js	main.js	C	\N	1	9
2358	76	Để chạy ứng dụng React sau khi tạo, dùng lệnh nào?	multiple_choice	npm build	npm install	npm start	node app.js	C	\N	1	10
2359	77	React Component là gì?	multiple_choice	Một phần mềm độc lập	Một hàm xử lý dữ liệu	Một khối giao diện có thể tái sử dụng	Một API backend	C	\N	1	1
2360	77	Function Component trong React là gì?	multiple_choice	Một class mở rộng từ React.Component	Một hàm JavaScript trả về JSX	Một đối tượng JSON	Một hook đặc biệt	B	\N	1	2
2361	77	Class Component yêu cầu phương thức nào?	multiple_choice	render()	return()	execute()	display()	A	\N	1	3
2362	77	JSX là gì?	multiple_choice	Một loại CSS	Một định dạng JSON	Một cú pháp mở rộng cho JavaScript để viết HTML	Một thư viện React	C	\N	1	4
2363	77	Sự khác biệt giữa export default và export thường là gì?	multiple_choice	export default cho phép xuất nhiều giá trị	export thường không thể import	export default chỉ dùng cho biến	export default chỉ có một giá trị duy nhất được xuất	D	\N	1	5
2364	77	Props trong React dùng để làm gì?	multiple_choice	Lưu trữ trạng thái nội bộ	Truyền dữ liệu từ component cha xuống con	Tạo hiệu ứng CSS	Kết nối với API	B	\N	1	6
2365	77	Thuộc tính children trong React là gì?	multiple_choice	Một component con mặc định	Một hook đặc biệt	Nội dung nằm giữa thẻ mở và đóng của component	Một props bắt buộc	C	\N	1	7
2366	77	Cách nào sau đây thể hiện conditional rendering?	multiple_choice	{isLoggedIn && <Welcome />}	<If isLoggedIn><Welcome /></If>	renderIf(isLoggedIn, <Welcome />)	<Welcome visible={isLoggedIn} />	A	\N	1	8
2367	77	Để hiển thị danh sách từ mảng, nên dùng phương thức nào?	multiple_choice	forEach()	map()	reduce()	find()	B	\N	1	9
2368	77	Phương thức filter() dùng để làm gì trong React?	multiple_choice	Tạo component mới	Lọc phần tử trong mảng theo điều kiện	Kết nối API	Tạo props	B	\N	1	10
2369	78	Trong React, su kien onClick duoc khai bao nhu the nao?	multiple_choice	onclick='handleClick()'	onClick='handleClick()'	onClick={handleClick}	click={handleClick}	C	\N	1	1
2370	78	useState hook dung de lam gi trong React?	multiple_choice	Gui du lieu den server	Quan ly trang thai (state) trong component	Tao component moi	Ket noi voi API	B	\N	1	2
2371	78	State trong React la gi?	multiple_choice	Mot bien toan cuc	Mot props dac biet	Bo nho cua component de luu tru du lieu thay doi	Mot hook de goi API	C	\N	1	3
2372	78	Khi nao React cap nhat giao dien sau khi goi setState?	multiple_choice	Ngay lap tuc	Sau 1 giay	Sau khi tat ca event handler hoan tat (batched)	Khi nguoi dung reload trang	C	\N	1	4
2373	78	Cach dung de cap nhat mot object trong state la gi?	multiple_choice	Gan truc tiep: state.user.name = 'John'	Dung setState voi object moi co spread: {...state, name: 'John'}	Dung push() de them thuoc tinh	Dung state.update()	B	\N	1	5
2374	78	Cu phap spread (...) trong JavaScript dung de lam gi?	multiple_choice	Gop cac component	Tao vong lap	Sao chep va mo rong object hoac array	Tao props moi	C	\N	1	6
2375	78	De them phan tu vao array trong state, ta nen:	multiple_choice	Dung push() truc tiep	Dung setState([...array, newItem])	Dung array.add(newItem)	Dung array.insert()	B	\N	1	7
2376	78	De xoa phan tu khoi array trong state, ta dung:	multiple_choice	array.remove(index)	array.pop()	array.splice()	filter() de tao mang moi khong chua phan tu can xoa	D	\N	1	8
2377	78	React batch cac cap nhat state trong truong hop nao?	multiple_choice	Trong event handler	Trong setTimeout	Trong fetch().then()	Trong console.log	A	\N	1	9
2378	78	Khi goi setState nhieu lan lien tiep trong cung mot ham, React se:	multiple_choice	Gop lai va cap nhat mot lan	Bo qua cac lenh sau	Gay loi	Tao nhieu ban sao DOM	A	\N	1	10
2379	79	“Thinking in React” yêu cầu bước đầu tiên là gì?	multiple_choice	Viết code JSX	Chia UI thành các component	Tạo state	Kết nối API	B	\N	1	1
2380	79	Component nào đứng ở đỉnh cây phân cấp trong ví dụ Product Table?	multiple_choice	ProductRow	SearchBar	ProductTable	FilterableProductTable	D	\N	1	2
2381	79	Component nào chịu trách nhiệm hiển thị ô tìm kiếm và checkbox?	multiple_choice	ProductTable	ProductCategoryRow	SearchBar	ProductRow	C	\N	1	3
2382	79	Dữ liệu gốc (products array) trong ứng dụng nên được lưu ở đâu?	multiple_choice	State	Props	LocalStorage	Redux	B	\N	1	4
2383	79	State nào sau đây cần được lưu trong React state?	multiple_choice	Danh sách sản phẩm	Danh sách đã lọc	Giá sản phẩm	Nội dung người dùng nhập vào ô tìm kiếm	D	\N	1	5
2384	79	Nguyên tắc DRY trong quản lý state có nghĩa là gì?	multiple_choice	Không dùng state	Không lặp lại dữ liệu	Không dùng props	Không dùng component	B	\N	1	6
2385	79	Component nào nên giữ state filterText và inStockOnly?	multiple_choice	SearchBar	ProductTable	FilterableProductTable	ProductRow	C	\N	1	7
2386	79	Cách truyền state từ component cha xuống component con là gì?	multiple_choice	useState	props	context	reducer	B	\N	1	8
2387	79	Khi checkbox “Only show products in stock” được bật, điều gì xảy ra?	multiple_choice	Tất cả sản phẩm hiển thị	Chỉ sản phẩm còn hàng hiển thị	Sản phẩm bị xóa	UI không thay đổi	B	\N	1	9
2388	79	Mục đích chính của việc “Make the UI interactive” là gì?	multiple_choice	Tối ưu CSS	Kết nối database	Phản hồi theo hành động người dùng	Tăng tốc độ build	C	\N	1	10
2389	80	Redux là gì?	multiple_choice	Một framework CSS	Một thư viện quản lý trạng thái ứng dụng JavaScript	Một cơ sở dữ liệu NoSQL	Một công cụ kiểm thử	B	\N	1	1
2390	80	Khi nào nên sử dụng Redux?	multiple_choice	Khi ứng dụng có ít component	Khi không cần chia sẻ state giữa các component	Khi nhiều component cần truy cập và cập nhật cùng một state	Khi chỉ dùng HTML thuần	C	\N	1	2
2391	80	Redux Toolkit là gì?	multiple_choice	Một bộ công cụ thiết kế UI	Một phần mở rộng của React	Cách tiếp cận được khuyến nghị để viết logic Redux	Một IDE cho Redux	C	\N	1	3
2392	80	React-Redux dùng để làm gì?	multiple_choice	Kết nối Redux với React	Tạo component mới	Quản lý CSS	Tạo API backend	A	\N	1	4
2393	80	Action trong Redux là gì?	multiple_choice	Một component React	Một object mô tả hành động cần thực hiện	Một hàm xử lý sự kiện	Một hook đặc biệt	B	\N	1	5
2394	80	Reducer là gì?	multiple_choice	Một hàm nhận state và action, trả về state mới	Một component React	Một hook để gọi API	Một hàm render UI	A	\N	1	6
2395	80	Store trong Redux là gì?	multiple_choice	Một nơi lưu trữ file	Một component cha	Một object lưu trữ toàn bộ state của ứng dụng	Một API endpoint	C	\N	1	7
2396	80	Dispatch trong Redux dùng để làm gì?	multiple_choice	Gửi dữ liệu đến server	Gọi reducer trực tiếp	Gửi action đến store để cập nhật state	Tạo component mới	C	\N	1	8
2397	80	Tính bất biến (immutability) trong Redux có nghĩa là gì?	multiple_choice	Có thể thay đổi state trực tiếp	Không bao giờ thay đổi state gốc, luôn tạo bản sao mới	Không cần cập nhật state	State chỉ thay đổi trong component con	B	\N	1	9
2398	80	Luồng dữ liệu trong Redux diễn ra như thế nào?	multiple_choice	UI → Reducer → Action → Store	Store → UI → Action → Reducer	Action → Reducer → Store → UI	UI → Store → Reducer → Action	C	\N	1	10
2399	81	Reactive Forms trong Angular dùng để làm gì?	multiple_choice	Thiết kế giao diện	Quản lý form với dữ liệu thay đổi theo thời gian	Kết nối API	Tạo component	B	\N	1	1
2400	81	Module nào cần import để sử dụng Reactive Forms?	multiple_choice	FormsModule	HttpClientModule	ReactiveFormsModule	BrowserModule	C	\N	1	2
2401	81	FormControl dùng để làm gì?	multiple_choice	Quản lý toàn bộ form	Quản lý một trường dữ liệu trong form	Gửi dữ liệu lên server	Tạo component	B	\N	1	3
2402	81	FormGroup là gì?	multiple_choice	Một component	Một tập hợp các FormControl	Một directive	Một service	B	\N	1	4
2403	81	Thuộc tính nào dùng để liên kết FormGroup với template?	multiple_choice	formControl	formGroup	ngModel	formArray	B	\N	1	5
2404	81	Validator 'Validators.required' dùng để làm gì?	multiple_choice	Kiểm tra email	Kiểm tra độ dài	Bắt buộc nhập dữ liệu	Kiểm tra số	C	\N	1	6
2405	81	Cách nào dùng để cập nhật giá trị FormControl?	multiple_choice	setValue()	update()	changeValue()	push()	A	\N	1	7
2406	81	Nested FormGroup dùng khi nào?	multiple_choice	Khi form có nhiều button	Khi form có cấu trúc dữ liệu lồng nhau	Khi form chỉ có một field	Khi form không cần validate	B	\N	1	8
2407	81	Thuộc tính nào kiểm tra trạng thái hợp lệ của form?	multiple_choice	touched	dirty	valid	disabled	C	\N	1	9
2408	81	Reactive Forms quản lý state của form ở đâu?	multiple_choice	Trong template	Trong component class	Trong CSS	Trong service	B	\N	1	10
\.


--
-- Data for Name: quiz_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quiz_results (id, user_id, lesson_id, score, total_questions, correct_answers, completed_at) FROM stdin;
104	24	111	100	10	10	2026-02-03 22:49:41.613825+00
105	24	112	100	10	10	2026-02-03 22:49:41.614824+00
106	24	113	100	10	10	2026-02-03 22:49:41.615825+00
107	24	114	100	10	10	2026-02-03 22:49:41.616325+00
108	24	115	100	10	10	2026-02-03 22:49:41.617325+00
109	24	116	100	10	10	2026-02-03 22:49:41.618324+00
111	24	117	100	10	10	2026-02-03 22:49:41.620325+00
112	24	118	100	10	10	2026-02-03 22:49:41.621324+00
113	24	119	100	10	10	2026-02-03 22:49:41.622324+00
114	24	120	100	10	10	2026-02-03 22:49:41.623324+00
115	24	110	100	10	10	2026-02-03 22:49:41.624324+00
116	24	139	100	10	10	2026-02-03 22:49:49.004516+00
117	24	140	100	10	10	2026-02-03 22:49:49.005517+00
118	24	141	100	10	10	2026-02-03 22:49:49.006019+00
119	24	142	100	10	10	2026-02-03 22:49:49.006519+00
120	24	143	100	10	10	2026-02-03 22:49:49.007019+00
121	24	144	100	10	10	2026-02-03 22:49:49.007519+00
122	27	113	100	10	10	2026-03-07 23:31:06.535032+00
123	24	191	100	2	2	2026-03-08 10:11:38.118906+00
124	26	192	100	1	1	2026-03-08 12:20:25.520261+00
125	27	109	70	20	14	2026-03-08 13:01:32.827241+00
126	30	109	85	20	17	2026-03-09 03:50:24.879027+00
110	24	109	85	20	17	2026-03-09 07:13:35.065166+00
\.


--
-- Data for Name: recommendations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recommendations (id, student_id, recommendation_type, item_id, item_type, confidence_score, reason, created_at, is_viewed, is_accepted) FROM stdin;
\.


--
-- Data for Name: student_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_profiles (id, user_id, student_id, major, specialization, class_name, intake_year, gpa, phone, address, date_of_birth, education_type, learning_style, preferred_difficulty) FROM stdin;
21	24	21748020001K27	Công nghệ thông tin	CNPM	CNPM-K27	27	\N	\N	\N	\N	0	\N	\N
22	25	21748020002K27	Công nghệ thông tin	CNPM	CNPM-K27	27	\N	\N	\N	\N	0	\N	\N
24	27	21748020004K27	Công nghệ thông tin	CNPM	CNPM-K27	27	\N	\N	\N	\N	0	\N	\N
25	28	21748020005K27	Công nghệ thông tin	CNPM	CNPM-K27	27	\N	\N	\N	\N	0	\N	\N
26	29	21748020006K27	Công nghệ thông tin	CNPM	CNPM-K27	27	\N	\N	\N	\N	0	\N	\N
23	26	21748020003K27	Công nghệ thông tin	CNPM	CNPM-K27	27	\N	\N	\N	\N	0	visual	medium
27	30	21748020007K27	Công nghệ thông tin	CNPM	CNPM-K27	27	\N	\N	\N	\N	0	\N	\N
28	31	21748020008K27	Công nghệ thông tin	CNPM	CNPM-K27	27	\N	\N	\N	\N	0	\N	\N
\.


--
-- Data for Name: student_skill_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_skill_profiles (id, student_id, skill_id, confidence, attempts, correct, last_updated) FROM stdin;
3	26	programming_foundations	1	1	1	2026-03-08 12:20:25.515448+00
1	27	programming_foundations	0.91	30	24	2026-03-08 13:01:32.81614+00
4	30	programming_foundations	0.745	40	31	2026-03-09 03:50:24.873669+00
2	24	programming_foundations	0.872	64	51	2026-03-09 07:13:35.059192+00
\.


--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.submissions (id, assessment_id, student_id, content, file_url, answers_json, score, max_score, percentage, status, attempt_number, feedback, graded_by, submitted_at, graded_at, is_late) FROM stdin;
7	65	17	\N	\N	{}	0	10	0	submitted	1	\N	\N	2026-02-03 15:42:49.237209+00	\N	f
20	64	24	\N	\N	{"2201": "b", "2202": "c", "2203": "c", "2204": "b", "2205": "c", "2206": "c", "2207": "a", "2208": "a", "2209": "d", "2210": "b", "2211": "a", "2212": "a", "2213": "b", "2214": "b", "2215": "c", "2216": "d", "2217": "b", "2218": "b", "2219": "b", "2220": "b"}	9	10	90	submitted	1	\N	\N	2026-02-04 05:48:49.533999+00	\N	f
21	64	24	\N	\N	{"2201": "d", "2202": "a", "2203": "c", "2204": "c", "2205": "c", "2206": "c", "2207": "c", "2208": "d", "2209": "a", "2210": "a", "2211": "c", "2212": "b", "2213": "b", "2214": "c", "2215": "d", "2216": "d", "2217": "d", "2218": "c", "2219": "d", "2220": "c"}	3	10	30	submitted	1	\N	\N	2026-03-07 13:33:59.486635+00	\N	f
22	68	27	\N	\N	{"2271": "b", "2272": "b", "2273": "c", "2274": "b", "2275": "c", "2276": "b", "2277": "c", "2278": "c", "2279": "b", "2280": "b"}	10	10	100	submitted	1	\N	\N	2026-03-07 23:31:06.524666+00	\N	f
23	85	24	\N	\N	{"2431": "a", "2432": "a"}	2	2	100	submitted	1	\N	\N	2026-03-08 10:05:28.560858+00	\N	f
24	85	24	\N	\N	{"2431": "a", "2432": "a"}	2	2	100	submitted	1	\N	\N	2026-03-08 10:11:38.109395+00	\N	f
25	64	24	\N	\N	{"2201": "b", "2202": "c", "2203": "c", "2204": "c", "2205": "a", "2206": "c", "2207": "a", "2208": "a", "2209": "d", "2210": "c", "2211": "a", "2212": "b", "2213": "b", "2214": "a", "2215": "c", "2216": "d", "2217": "b", "2218": "b", "2219": "b", "2220": "a"}	6.5	10	65	submitted	1	\N	\N	2026-03-08 12:07:41.440508+00	\N	f
26	86	26	\N	\N	{"2437": "a"}	1	1	100	submitted	1	\N	\N	2026-03-08 12:20:25.515448+00	\N	f
27	64	27	\N	\N	{"2201": "b", "2202": "c", "2203": "c", "2204": "c", "2205": "a", "2206": "b", "2207": "a", "2208": "a", "2209": "d", "2210": "b", "2211": "c", "2212": "b", "2213": "b", "2214": "a", "2215": "c", "2216": "d", "2217": "b", "2218": "a", "2219": "b", "2220": "b"}	7	10	70	submitted	1	\N	\N	2026-03-08 13:01:32.81614+00	\N	f
28	64	30	\N	\N	{"2201": "b", "2202": "c", "2203": "c", "2204": "c", "2205": "c", "2206": "b", "2207": "a", "2208": "a", "2209": "d", "2210": "b", "2211": "c", "2212": "a", "2213": "b", "2214": "a", "2215": "c", "2217": "a", "2218": "b", "2219": "b", "2220": "b"}	7	10	70	submitted	1	\N	\N	2026-03-09 03:46:44.140253+00	\N	f
29	64	30	\N	\N	{"2201": "b", "2202": "c", "2203": "c", "2204": "c", "2205": "c", "2206": "c", "2207": "a", "2208": "a", "2209": "d", "2210": "b", "2211": "c", "2212": "b", "2213": "b", "2214": "a", "2215": "c", "2216": "d", "2217": "b", "2218": "b", "2219": "b", "2220": "b"}	8.5	10	85	submitted	1	\N	\N	2026-03-09 03:50:24.873669+00	\N	f
30	64	24	\N	\N	{"2201": "b", "2202": "c", "2203": "c", "2204": "c", "2205": "c", "2206": "c", "2207": "a", "2208": "a", "2209": "d", "2210": "b", "2211": "c", "2212": "b", "2213": "b", "2214": "a", "2215": "c", "2216": "d", "2217": "b", "2218": "b", "2219": "b", "2220": "b"}	8.5	10	85	submitted	1	\N	\N	2026-03-09 04:11:48.754294+00	\N	f
31	64	24	\N	\N	{"2201": "b", "2202": "c", "2203": "c", "2204": "c", "2205": "c", "2206": "c", "2207": "a", "2208": "a", "2209": "d", "2210": "b", "2211": "c", "2212": "a", "2213": "b", "2214": "a", "2215": "c", "2216": "d", "2217": "b", "2218": "b", "2219": "b", "2220": "b"}	8.5	10	85	submitted	1	\N	\N	2026-03-09 07:13:35.059192+00	\N	f
\.


--
-- Data for Name: teacher_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teacher_profiles (id, user_id, teacher_id, department, "position", specialization, phone, office_location, bio, years_of_experience, courses_taught) FROM stdin;
1	17	GV001	Khoa CNTT	Tiến Sĩ	\N	0123456789	\N	\N	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, hashed_password, full_name, role, is_active, is_verified, created_at, updated_at) FROM stdin;
17	giangvien1@vanlanguni.vn	$2b$12$MXSfcYpIIt2Gha7BAFQOi.IoG6MEUdKQ2udnLV7QvGcpIIKtJ7mtO	Lê Hồng Sơn	TEACHER	t	f	2026-01-22 23:06:20.093185+00	\N
18	admin	$2b$12$bRp6IoXPG1.7IN4FjgsNSuMCtqR5BNln51sZyMyYRVVfypTtbWpWG	Administrator	ADMIN	t	f	2026-02-01 10:35:33.789131+00	\N
24	tam.2174802010372@vanlanguni.vn	$2b$12$UfykQAEtQ24NvOywAEk.je50zC7vA.q.DBQXj1Tre.dStnYGVdotC	Phạm Thành Tâm	STUDENT	t	f	2026-02-04 05:46:56.293661+00	\N
26	tam.2@vanlanguni.vn	$2b$12$6i7FjUjEaclauuLPX9Fsf.F88jbBoqUvVeR/52tQDNKmL9FtEqGBi	Phạm Thành Tâm	STUDENT	t	f	2026-03-07 11:57:04.046142+00	\N
27	tam.21@vanlanguni.vn	$2b$12$hjUyIuebyZgn4sbUc1EARewoCCA2ympDfCGQRMpVpSOSXEKp1.yjq	Lê Hồng Sơn	STUDENT	t	f	2026-03-07 14:45:29.015896+00	\N
28	tam.2174@vanlanguni.vn	$2b$12$aABR4HXNOM7UC1HvJNmgSO8dxc6GB5yIAul8V39NaE7tEz8X3gBMi	Phạm Thành Tâm	STUDENT	t	f	2026-03-08 11:26:21.412265+00	\N
29	tam412@vanlanguni.vn	$2b$12$10lSfq/MaZuvD6HQ4RdkGe8udOkCjHzEqx4fOPjvZQdhmZhWeiDpy	Pham Tam	STUDENT	t	f	2026-03-08 11:48:43.545722+00	\N
30	myngoc@vanlanguni.vn	$2b$12$h.6FtmL2rPbEfLzmZlxDEu6vAdfmBYzXq0DxSE5WTqTjsOTBG3UAW	Lê Thị Mỹ Ngọc	STUDENT	t	f	2026-03-09 03:19:48.040688+00	\N
31	thao.2174802015029@vanlanguni.vn	$2b$12$s4t6GnLAsW5hGwIek3tnQ.AhAIKXeYRfgbuHUPCoa/lF5JYvkVx/a	Nguyễn Quốc Thảo	STUDENT	t	f	2026-03-09 04:16:08.244713+00	\N
25	tamkute@vanlanguni.vn	$2b$12$U/MrCW8SFRd5h3rCv.yJyuMQZ2/XrkSCW/3qjeUO/dvVrFFlWFX.O	Phạm Thành T âm	STUDENT	t	f	2026-03-07 08:09:54.132626+00	2026-03-09 04:29:09.178748+00
\.


--
-- Name: assessments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.assessments_id_seq', 86, true);


--
-- Name: courses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.courses_id_seq', 70, true);


--
-- Name: enrollments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.enrollments_id_seq', 143, true);


--
-- Name: essay_submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.essay_submissions_id_seq', 2, true);


--
-- Name: grade_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grade_history_id_seq', 1, false);


--
-- Name: learning_activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.learning_activities_id_seq', 1, false);


--
-- Name: lesson_comment_likes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lesson_comment_likes_id_seq', 10, true);


--
-- Name: lesson_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lesson_comments_id_seq', 11, true);


--
-- Name: lesson_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lesson_progress_id_seq', 104, true);


--
-- Name: lessons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lessons_id_seq', 192, true);


--
-- Name: login_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.login_history_id_seq', 1, false);


--
-- Name: materials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.materials_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, true);


--
-- Name: questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.questions_id_seq', 2437, true);


--
-- Name: quiz_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quiz_results_id_seq', 126, true);


--
-- Name: recommendations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recommendations_id_seq', 1, false);


--
-- Name: student_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_profiles_id_seq', 28, true);


--
-- Name: student_skill_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_skill_profiles_id_seq', 4, true);


--
-- Name: submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.submissions_id_seq', 31, true);


--
-- Name: teacher_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teacher_profiles_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 31, true);


--
-- Name: assessments assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_pkey PRIMARY KEY (id);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (id);


--
-- Name: essay_submissions essay_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.essay_submissions
    ADD CONSTRAINT essay_submissions_pkey PRIMARY KEY (id);


--
-- Name: grade_history grade_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_history
    ADD CONSTRAINT grade_history_pkey PRIMARY KEY (id);


--
-- Name: learning_activities learning_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.learning_activities
    ADD CONSTRAINT learning_activities_pkey PRIMARY KEY (id);


--
-- Name: lesson_comment_likes lesson_comment_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_comment_likes
    ADD CONSTRAINT lesson_comment_likes_pkey PRIMARY KEY (id);


--
-- Name: lesson_comments lesson_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_comments
    ADD CONSTRAINT lesson_comments_pkey PRIMARY KEY (id);


--
-- Name: lesson_progress lesson_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_progress
    ADD CONSTRAINT lesson_progress_pkey PRIMARY KEY (id);


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);


--
-- Name: login_history login_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_history
    ADD CONSTRAINT login_history_pkey PRIMARY KEY (id);


--
-- Name: materials materials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.materials
    ADD CONSTRAINT materials_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: quiz_results quiz_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_results
    ADD CONSTRAINT quiz_results_pkey PRIMARY KEY (id);


--
-- Name: recommendations recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: student_profiles student_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_profiles
    ADD CONSTRAINT student_profiles_pkey PRIMARY KEY (id);


--
-- Name: student_profiles student_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_profiles
    ADD CONSTRAINT student_profiles_user_id_key UNIQUE (user_id);


--
-- Name: student_skill_profiles student_skill_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_skill_profiles
    ADD CONSTRAINT student_skill_profiles_pkey PRIMARY KEY (id);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: teacher_profiles teacher_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_profiles
    ADD CONSTRAINT teacher_profiles_pkey PRIMARY KEY (id);


--
-- Name: teacher_profiles teacher_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_profiles
    ADD CONSTRAINT teacher_profiles_user_id_key UNIQUE (user_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_courses_course_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_courses_course_code ON public.courses USING btree (course_code);


--
-- Name: ix_courses_major; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_courses_major ON public.courses USING btree (major);


--
-- Name: ix_courses_specialization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_courses_specialization ON public.courses USING btree (specialization);


--
-- Name: ix_learning_activities_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_learning_activities_id ON public.learning_activities USING btree (id);


--
-- Name: ix_lesson_comments_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_lesson_comments_id ON public.lesson_comments USING btree (id);


--
-- Name: ix_lesson_comments_lesson_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_lesson_comments_lesson_id ON public.lesson_comments USING btree (lesson_id);


--
-- Name: ix_notifications_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notifications_id ON public.notifications USING btree (id);


--
-- Name: ix_notifications_recipient_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notifications_recipient_id ON public.notifications USING btree (recipient_id);


--
-- Name: ix_student_profiles_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_student_profiles_student_id ON public.student_profiles USING btree (student_id);


--
-- Name: ix_teacher_profiles_teacher_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_teacher_profiles_teacher_id ON public.teacher_profiles USING btree (teacher_id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: assessments assessments_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: courses courses_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- Name: enrollments enrollments_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: enrollments enrollments_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- Name: essay_submissions essay_submissions_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.essay_submissions
    ADD CONSTRAINT essay_submissions_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: essay_submissions essay_submissions_graded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.essay_submissions
    ADD CONSTRAINT essay_submissions_graded_by_fkey FOREIGN KEY (graded_by) REFERENCES public.users(id);


--
-- Name: essay_submissions essay_submissions_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.essay_submissions
    ADD CONSTRAINT essay_submissions_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;


--
-- Name: essay_submissions essay_submissions_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.essay_submissions
    ADD CONSTRAINT essay_submissions_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: grade_history grade_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_history
    ADD CONSTRAINT grade_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id);


--
-- Name: grade_history grade_history_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_history
    ADD CONSTRAINT grade_history_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: grade_history grade_history_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_history
    ADD CONSTRAINT grade_history_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id);


--
-- Name: grade_history grade_history_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_history
    ADD CONSTRAINT grade_history_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- Name: lesson_comment_likes lesson_comment_likes_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_comment_likes
    ADD CONSTRAINT lesson_comment_likes_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.lesson_comments(id) ON DELETE CASCADE;


--
-- Name: lesson_comment_likes lesson_comment_likes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_comment_likes
    ADD CONSTRAINT lesson_comment_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: lesson_comments lesson_comments_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_comments
    ADD CONSTRAINT lesson_comments_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;


--
-- Name: lesson_comments lesson_comments_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_comments
    ADD CONSTRAINT lesson_comments_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.lesson_comments(id) ON DELETE CASCADE;


--
-- Name: lesson_comments lesson_comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_comments
    ADD CONSTRAINT lesson_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: lesson_progress lesson_progress_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_progress
    ADD CONSTRAINT lesson_progress_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;


--
-- Name: lesson_progress lesson_progress_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_progress
    ADD CONSTRAINT lesson_progress_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- Name: lessons lessons_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: login_history login_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_history
    ADD CONSTRAINT login_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: materials materials_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.materials
    ADD CONSTRAINT materials_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: materials materials_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.materials
    ADD CONSTRAINT materials_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.lesson_comments(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: questions questions_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE CASCADE;


--
-- Name: quiz_results quiz_results_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_results
    ADD CONSTRAINT quiz_results_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;


--
-- Name: quiz_results quiz_results_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_results
    ADD CONSTRAINT quiz_results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: recommendations recommendations_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- Name: student_profiles student_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_profiles
    ADD CONSTRAINT student_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: student_skill_profiles student_skill_profiles_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_skill_profiles
    ADD CONSTRAINT student_skill_profiles_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: submissions submissions_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE CASCADE;


--
-- Name: submissions submissions_graded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_graded_by_fkey FOREIGN KEY (graded_by) REFERENCES public.users(id);


--
-- Name: submissions submissions_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- Name: teacher_profiles teacher_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_profiles
    ADD CONSTRAINT teacher_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict nu9VTYCJN2ay4qJ8hoyomIwumcakveapRW99x9akrbOQ3CnoptLBiDqxv1D0WEk


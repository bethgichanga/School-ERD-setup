-- ============================================================
--  SCHOOL ERD SETUP — SQL Schema
--  Author : Beth Gichanga
--  Project: School-ERD-setup
-- ============================================================

-- ────────────────────────────────────────
-- 1. DEPARTMENTS
-- ────────────────────────────────────────
CREATE TABLE departments (
    department_id   SERIAL          PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL UNIQUE,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- ────────────────────────────────────────
-- 2. TEACHERS
-- (defined before departments head FK to avoid circular dep)
-- ────────────────────────────────────────
CREATE TABLE teachers (
    teacher_id      SERIAL          PRIMARY KEY,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    email           VARCHAR(100)    NOT NULL UNIQUE,
    phone           VARCHAR(20),
    department_id   INT             REFERENCES departments(department_id) ON DELETE SET NULL,
    hire_date       DATE            NOT NULL,
    employment_type VARCHAR(20)     CHECK (employment_type IN ('full-time', 'part-time', 'contract')),
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- Add head_teacher_id to departments after teachers table exists
ALTER TABLE departments
    ADD COLUMN head_teacher_id INT REFERENCES teachers(teacher_id) ON DELETE SET NULL;

-- ────────────────────────────────────────
-- 3. SUPPORT STAFF
-- ────────────────────────────────────────
CREATE TABLE support_staff (
    staff_id        SERIAL          PRIMARY KEY,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    email           VARCHAR(100)    NOT NULL UNIQUE,
    phone           VARCHAR(20),
    role            VARCHAR(100)    NOT NULL,   -- e.g. 'Librarian', 'Counselor', 'IT Support'
    department_id   INT             REFERENCES departments(department_id) ON DELETE SET NULL,
    hire_date       DATE            NOT NULL,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- ────────────────────────────────────────
-- 4. SUBJECTS
-- ────────────────────────────────────────
CREATE TABLE subjects (
    subject_id      SERIAL          PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL UNIQUE,
    code            VARCHAR(10)     NOT NULL UNIQUE,  -- e.g. 'MATH101'
    department_id   INT             REFERENCES departments(department_id) ON DELETE SET NULL,
    credits         INT             DEFAULT 1,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- ────────────────────────────────────────
-- 5. CLASSES (Streams / Sections)
-- ────────────────────────────────────────
CREATE TABLE classes (
    class_id            SERIAL          PRIMARY KEY,
    grade               VARCHAR(10)     NOT NULL,   -- e.g. 'Form 1', 'Grade 6'
    section             VARCHAR(10)     NOT NULL,   -- e.g. 'A', 'B', 'North'
    homeroom_teacher_id INT             REFERENCES teachers(teacher_id) ON DELETE SET NULL,
    capacity            INT             DEFAULT 40,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (grade, section)
);

-- ────────────────────────────────────────
-- 6. GUARDIANS
-- ────────────────────────────────────────
CREATE TABLE guardians (
    guardian_id     SERIAL          PRIMARY KEY,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    relationship    VARCHAR(30)     NOT NULL,   -- e.g. 'Mother', 'Father', 'Uncle'
    phone           VARCHAR(20)     NOT NULL,
    email           VARCHAR(100),
    address         TEXT,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- ────────────────────────────────────────
-- 7. STUDENTS
-- ────────────────────────────────────────
CREATE TABLE students (
    student_id      SERIAL          PRIMARY KEY,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    date_of_birth   DATE            NOT NULL,
    gender          VARCHAR(10)     CHECK (gender IN ('Male', 'Female', 'Other')),
    admission_no    VARCHAR(20)     NOT NULL UNIQUE,
    class_id        INT             REFERENCES classes(class_id) ON DELETE SET NULL,
    guardian_id     INT             REFERENCES guardians(guardian_id) ON DELETE SET NULL,
    admission_date  DATE            NOT NULL,
    status          VARCHAR(20)     DEFAULT 'active' CHECK (status IN ('active', 'transferred', 'graduated', 'suspended')),
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- ────────────────────────────────────────
-- 8. ENROLLMENTS  (Student ↔ Class per year)
-- ────────────────────────────────────────
CREATE TABLE enrollments (
    enrollment_id   SERIAL          PRIMARY KEY,
    student_id      INT             NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    class_id        INT             NOT NULL REFERENCES classes(class_id) ON DELETE CASCADE,
    academic_year   VARCHAR(10)     NOT NULL,   -- e.g. '2024-2025'
    enrolled_on     DATE            DEFAULT CURRENT_DATE,
    UNIQUE (student_id, class_id, academic_year)
);

-- ────────────────────────────────────────
-- 9. TEACHER–SUBJECT–CLASS ASSIGNMENTS
-- ────────────────────────────────────────
CREATE TABLE assignments (
    assignment_id   SERIAL          PRIMARY KEY,
    teacher_id      INT             NOT NULL REFERENCES teachers(teacher_id) ON DELETE CASCADE,
    subject_id      INT             NOT NULL REFERENCES subjects(subject_id) ON DELETE CASCADE,
    class_id        INT             NOT NULL REFERENCES classes(class_id) ON DELETE CASCADE,
    academic_year   VARCHAR(10)     NOT NULL,
    UNIQUE (teacher_id, subject_id, class_id, academic_year)
);

-- ────────────────────────────────────────
-- 10. GRADES / RESULTS
-- ────────────────────────────────────────
CREATE TABLE grades (
    grade_id        SERIAL          PRIMARY KEY,
    student_id      INT             NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    subject_id      INT             NOT NULL REFERENCES subjects(subject_id) ON DELETE CASCADE,
    teacher_id      INT             NOT NULL REFERENCES teachers(teacher_id) ON DELETE CASCADE,
    academic_year   VARCHAR(10)     NOT NULL,
    term            VARCHAR(10)     NOT NULL CHECK (term IN ('Term 1', 'Term 2', 'Term 3')),
    score           NUMERIC(5,2)    CHECK (score BETWEEN 0 AND 100),
    grade_letter    VARCHAR(2),     -- e.g. 'A', 'B+'
    remarks         TEXT,
    recorded_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (student_id, subject_id, academic_year, term)
);

-- ────────────────────────────────────────
-- 11. ATTENDANCE
-- ────────────────────────────────────────
CREATE TABLE attendance (
    attendance_id   SERIAL          PRIMARY KEY,
    student_id      INT             NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    class_id        INT             NOT NULL REFERENCES classes(class_id) ON DELETE CASCADE,
    date            DATE            NOT NULL,
    status          VARCHAR(10)     NOT NULL CHECK (status IN ('present', 'absent', 'late', 'excused')),
    notes           TEXT,
    UNIQUE (student_id, date)
);

-- ────────────────────────────────────────
-- INDEXES for common lookups
-- ────────────────────────────────────────
CREATE INDEX idx_students_class       ON students(class_id);
CREATE INDEX idx_enrollments_student  ON enrollments(student_id);
CREATE INDEX idx_grades_student       ON grades(student_id);
CREATE INDEX idx_attendance_student   ON attendance(student_id);
CREATE INDEX idx_assignments_teacher  ON assignments(teacher_id);

-- Departments
CREATE TABLE departments (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Teachers
CREATE TABLE teachers (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE
);

-- Students
CREATE TABLE students (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gpa DECIMAL(3,2),
    department_id INT,
    
    CONSTRAINT students_gpa_check
        CHECK (gpa >= 0 AND gpa <= 4),
        
    CONSTRAINT students_department_fk
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
);

-- Courses
CREATE TABLE courses (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Enrollments
CREATE TABLE enrollments (
    id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    grade DECIMAL(5,2),

    CONSTRAINT enrollments_student_fk
        FOREIGN KEY (student_id)
        REFERENCES students(id),

    CONSTRAINT enrollments_course_fk
        FOREIGN KEY (course_id)
        REFERENCES courses(id)
);

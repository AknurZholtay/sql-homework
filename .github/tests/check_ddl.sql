-- Helper function for assertions
CREATE OR REPLACE FUNCTION assert(condition boolean, message text)
RETURNS void AS $$
BEGIN
    IF NOT condition THEN
        RAISE EXCEPTION 'TEST FAILED: %', message;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- =========================================
-- 1. Check required tables
-- =========================================

SELECT assert(
    to_regclass('public.departments') IS NOT NULL,
    'Table departments does not exist'
);

SELECT assert(
    to_regclass('public.teachers') IS NOT NULL,
    'Table teachers does not exist'
);

SELECT assert(
    to_regclass('public.students') IS NOT NULL,
    'Table students does not exist'
);

SELECT assert(
    to_regclass('public.courses') IS NOT NULL,
    'Table courses does not exist'
);

SELECT assert(
    to_regclass('public.enrollments') IS NOT NULL,
    'Table enrollments does not exist'
);


-- =========================================
-- 2. Check required columns
-- =========================================

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'students'
          AND column_name = 'gpa'
    ),
    'students.gpa column does not exist'
);

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'students'
          AND column_name = 'department_id'
    ),
    'students.department_id column does not exist'
);

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'enrollments'
          AND column_name = 'grade'
    ),
    'enrollments.grade column does not exist'
);


-- =========================================
-- 3. Check PRIMARY KEYS
-- =========================================

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = 'departments'
          AND constraint_type = 'PRIMARY KEY'
    ),
    'departments must have PRIMARY KEY'
);

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = 'students'
          AND constraint_type = 'PRIMARY KEY'
    ),
    'students must have PRIMARY KEY'
);


-- =========================================
-- 4. Check FOREIGN KEYS
-- =========================================

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = 'students'
          AND constraint_type = 'FOREIGN KEY'
    ),
    'students must have FOREIGN KEY'
);

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = 'enrollments'
          AND constraint_type = 'FOREIGN KEY'
    ),
    'enrollments must have FOREIGN KEY'
);


-- =========================================
-- 5. Check UNIQUE constraint
-- =========================================

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = 'teachers'
          AND constraint_type = 'UNIQUE'
    ),
    'teachers must have UNIQUE constraint'
);


-- =========================================
-- 6. Check GPA CHECK constraint
-- =========================================

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = 'students'
          AND constraint_type = 'CHECK'
    ),
    'students.gpa must have CHECK constraint'
);


-- =========================================
-- 7. Test valid INSERT
-- =========================================

INSERT INTO departments (id, name)
VALUES (9999, 'Test Department');


-- =========================================
-- 8. Test invalid GPA
-- GPA 9.99 must NOT be accepted
-- =========================================

DO $$
BEGIN
    BEGIN
        INSERT INTO students (
            id,
            name,
            gpa,
            department_id
        )
        VALUES (
            9999,
            'Test Student',
            9.99,
            9999
        );

        RAISE EXCEPTION
            'TEST FAILED: GPA CHECK constraint does not work';
            
    EXCEPTION
        WHEN check_violation THEN
            -- Expected result
            NULL;
    END;
END;
$$;


-- =========================================
-- All tests passed
-- =========================================

SELECT 'ALL TESTS PASSED!' AS result;

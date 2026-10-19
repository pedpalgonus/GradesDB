SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS teaching_loads;
DROP TABLE IF EXISTS subject_enrollments;
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS group_enrollments;
DROP TABLE IF EXISTS `groups`;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS degrees;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS professors;
DROP TABLE IF EXISTS people;
SET FOREIGN_KEY_CHECKS = 1;

-- Definición tabla people
CREATE TABLE people (
    person_id INT AUTO_INCREMENT,
    dni CHAR(9) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(150) NOT NULL,
    age TINYINT NOT NULL,
    email VARCHAR(255) NOT NULL,
    PRIMARY KEY (person_id),
    UNIQUE (dni),
    UNIQUE (email),
    CONSTRAINT chk_people_age CHECK (age >= 16)
);

CREATE TABLE professors (
    professor_id INT,
    category VARCHAR(30) NOT NULL,
    PRIMARY KEY (professor_id),
    FOREIGN KEY (professor_id) REFERENCES people(person_id) ON DELETE CASCADE,
    CONSTRAINT chk_professor_category CHECK (category IN ('Catedrático', 'Titular', 'AyudanteDoctor', 'Ayudante', 'ContratadoDoctor'))
);

CREATE TABLE students (
    student_id INT,
    access_method VARCHAR(20) NOT NULL,
    PRIMARY KEY (student_id),
    FOREIGN KEY (student_id) REFERENCES people(person_id) ON DELETE CASCADE
);

CREATE TABLE degrees (
    degree_id INT AUTO_INCREMENT,
    degree_name VARCHAR(80) NOT NULL,
    duration_years TINYINT NOT NULL,
    PRIMARY KEY (degree_id),
    UNIQUE (degree_name),
    CONSTRAINT chk_degree_duration CHECK (duration_years >= 3 AND duration_years <= 6)
);

CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT,
    degree_id INT NOT NULL,
    subject_name VARCHAR(120) NOT NULL,
    acronym VARCHAR(12) NOT NULL,
    credits TINYINT NOT NULL,
    course TINYINT NOT NULL,
    subject_type VARCHAR(30) NOT NULL,
    PRIMARY KEY (subject_id),
    FOREIGN KEY (degree_id) REFERENCES degrees(degree_id) ON DELETE CASCADE,
    UNIQUE (degree_id, subject_name),
    UNIQUE (degree_id, acronym),
    CONSTRAINT chk_subject_credits CHECK (credits > 0),
    CONSTRAINT chk_subject_course CHECK (course >= 1 AND course <= 6),
    CONSTRAINT chk_subject_type CHECK (subject_type IN ('Formación Básica', 'Obligatoria', 'Optativa', 'Trabajo Fin de Grado'))
);

CREATE TABLE `groups` (
    group_id INT AUTO_INCREMENT,
    subject_id INT NOT NULL,
    group_name VARCHAR(40) NOT NULL,
    activity VARCHAR(15) NOT NULL,
    academic_year YEAR NOT NULL,
    PRIMARY KEY (group_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE (subject_id, group_name, academic_year),
    CONSTRAINT chk_group_activity CHECK (activity IN ('Teoría', 'Laboratorio'))
);

CREATE TABLE subject_enrollments (
    student_id INT,
    subject_id INT,
    PRIMARY KEY (student_id, subject_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE
);

CREATE TABLE group_enrollments (
    student_id INT,
    group_id INT,
    PRIMARY KEY (student_id, group_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES `groups`(group_id) ON DELETE CASCADE
);

CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT,
    student_id INT NOT NULL,
    group_id INT NOT NULL,
    grade_value DECIMAL(4,2) NOT NULL,
    exam_call VARCHAR(20) NOT NULL,
    with_honors BOOLEAN NOT NULL DEFAULT 0,
    PRIMARY KEY (grade_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES `groups`(group_id) ON DELETE CASCADE,
    UNIQUE (student_id, group_id, exam_call),
    CONSTRAINT chk_grade_value CHECK (grade_value >= 0.0 AND grade_value <= 10.0),
    CONSTRAINT chk_exam_call CHECK (exam_call IN ('Primera', 'Segunda', 'Tercera')),
    CONSTRAINT chk_with_honors CHECK (with_honors = 0 OR (with_honors = 1 AND grade_value >= 9.0))
);

CREATE TABLE teaching_loads (
    professor_id INT,
    group_id INT,
    credits DECIMAL(4,1) NOT NULL,
    PRIMARY KEY (professor_id, group_id),
    FOREIGN KEY (professor_id) REFERENCES professors(professor_id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES `groups`(group_id) ON DELETE CASCADE,
    CONSTRAINT chk_teaching_credits CHECK (credits > 0.0)
);
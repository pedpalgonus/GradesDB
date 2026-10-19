DROP TABLE if EXISTS students;
DROP TABLE if EXISTS professors;
DROP TABLE if EXISTS people;

CREATE TABLE people (
	person_id INT AUTO_INCREMENT,
	dni CHAR(9) NOT NULL,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	age TINYINT NOT NULL,
	email VARCHAR(255) NOT NULL,
	PRIMARY KEY (person_id)
	CONSTRAINT rn12_people_age CHECK (age BETWEEN 16 AND 70),
   CONSTRAINT rn14_people_dni CHECK (dni REGEXP '^[0-9]{8}[A-Za-z]$'),
   CONSTRAINT rn_uq_people_dni UNIQUE (dni),
   CONSTRAINT rn_uq_people_email UNIQUE (email);
);


CREATE TABLE professors (
    professor_id INT,
    category VARCHAR(30) NOT NULL,
    PRIMARY KEY (professor_id),
    FOREIGN KEY (professor_id) REFERENCES people(person_id)
    CONSTRAINT ck_professors_category CHECK (
        category IN ('Ayudante','AyudanteDoctor','Titular','Catedrático')
);

CREATE TABLE students (
    student_id INT,
    access_method VARCHAR(20) NOT NULL,
    PRIMARY KEY (student_id),
    FOREIGN KEY (student_id) REFERENCES people(person_id)
    CONSTRAINT ck_students_access_method CHECK (
        access_method IN ('Selectividad','Ciclo','Mayor','Titulado','Extranjero')
);


CREATE TABLE students (
    student_id INT,
    access_method VARCHAR(20) NOT NULL,
    PRIMARY KEY (student_id),
    FOREIGN KEY (student_id) REFERENCES people(person_id)
);	

USE grades;

DELIMITER //

-- ==========================================
-- 1. EJEMPLOS BÁSICOS (Variables y Parámetros)
-- ==========================================

CREATE OR REPLACE PROCEDURE ejemplo_variables_locales()
BEGIN
    DECLARE v_contador INT DEFAULT 0;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_promedio DECIMAL(4,2);
    
    SET v_contador = 10;
    SELECT first_name INTO v_nombre FROM people WHERE person_id = 1;
    
    SELECT v_contador, v_nombre;
END //

CREATE OR REPLACE PROCEDURE ejemplo_in(
    IN p_student_id INT
)
BEGIN
    SELECT * FROM students WHERE student_id = p_student_id;
END //

CREATE OR REPLACE PROCEDURE ejemplo_out(
    IN p_student_id INT,
    OUT p_average DECIMAL(4,2)
)
BEGIN
    SELECT AVG(grade_value) INTO p_average
    FROM grades
    WHERE student_id = p_student_id;
END //

CREATE OR REPLACE PROCEDURE ejemplo_inout(
    INOUT p_contador INT
)
BEGIN
    SET p_contador = p_contador + 1;
END //

-- ==========================================
-- 2. PROCEDIMIENTOS DE NEGOCIO DE GRADESDB
-- ==========================================

-- Procedimiento: Calcular la media de un estudiante (usado en el bloque de variables de sesión)
CREATE OR REPLACE PROCEDURE p_student_average(
    IN p_student_id INT,
    OUT p_average DECIMAL(4,2)
)
BEGIN
    SELECT AVG(grade_value) INTO p_average
    FROM grades
    WHERE student_id = p_student_id;
END //

-- Procedimiento: Insertar un nuevo estudiante (en people y students dentro de una transacción)
CREATE OR REPLACE PROCEDURE p_insert_student(
    IN p_dni CHAR(9),
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(150),
    IN p_age TINYINT,
    IN p_email VARCHAR(255),
    IN p_access_method VARCHAR(20)
)
BEGIN
    DECLARE v_person_id INT;
    
    -- Si ocurre cualquier error SQL (ej. DNI inválido o duplicado), deshace todo
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    
    INSERT INTO people (dni, first_name, last_name, age, email)
    VALUES (p_dni, p_first_name, p_last_name, p_age, p_email);
    
    SET v_person_id = LAST_INSERT_ID();
    
    INSERT INTO students (student_id, access_method)
    VALUES (v_person_id, p_access_method);
    
    COMMIT;
END //

-- Procedimiento: Insertar un nuevo profesor (con transacción)
CREATE OR REPLACE PROCEDURE p_insert_professor(
    IN p_dni CHAR(9),
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(150),
    IN p_age TINYINT,
    IN p_email VARCHAR(255),
    IN p_category VARCHAR(30)
)
BEGIN
    DECLARE v_person_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    
    INSERT INTO people (dni, first_name, last_name, age, email)
    VALUES (p_dni, p_first_name, p_last_name, p_age, p_email);
    
    SET v_person_id = LAST_INSERT_ID();
    
    INSERT INTO professors (professor_id, category)
    VALUES (v_person_id, p_category);
    
    COMMIT;
END //

-- Procedimiento: Matricular a un alumno en una asignatura y en un grupo a la vez
CREATE OR REPLACE PROCEDURE p_enroll_student(
    IN p_student_id INT,
    IN p_group_id INT
)
BEGIN
    DECLARE v_subject_id INT;
    DECLARE v_exists INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Obtenemos la asignatura a la que pertenece el grupo
    SELECT subject_id INTO v_subject_id
    FROM `groups`
    WHERE group_id = p_group_id;

    -- Si aún no está matriculado en la asignatura, lo matriculamos
    SELECT COUNT(*) INTO v_exists
    FROM subject_enrollments
    WHERE student_id = p_student_id AND subject_id = v_subject_id;

    IF v_exists = 0 THEN
        INSERT INTO subject_enrollments (student_id, subject_id)
        VALUES (p_student_id, v_subject_id);
    END IF;

    -- Lo matriculamos en el grupo
    INSERT INTO group_enrollments (student_id, group_id)
    VALUES (p_student_id, p_group_id);

    COMMIT;
END //

-- Procedimiento: Borrar una asignatura y todas sus dependencias en cascada manual
CREATE OR REPLACE PROCEDURE p_delete_subject(
    IN p_subject_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    DELETE FROM grades 
    WHERE group_id IN (SELECT group_id FROM `groups` WHERE subject_id = p_subject_id);

    DELETE FROM group_enrollments 
    WHERE group_id IN (SELECT group_id FROM `groups` WHERE subject_id = p_subject_id);

    DELETE FROM teaching_loads 
    WHERE group_id IN (SELECT group_id FROM `groups` WHERE subject_id = p_subject_id);

    DELETE FROM subject_enrollments 
    WHERE subject_id = p_subject_id;

    -- Como groups tiene ON DELETE CASCADE con subjects, al borrar la asignatura se borran sus grupos
    DELETE FROM subjects 
    WHERE subject_id = p_subject_id;

    COMMIT;
END //

DELIMITER ;

-- ==========================================
-- 3. LLAMADAS DE PRUEBA (Para ejecutar sin errores)
-- ==========================================
SET @resultado = 100;
SELECT AVG(grade_value) INTO @promedio_general FROM grades;
CALL p_student_average(6, @promedio_estudiante);
SELECT @promedio_general, @promedio_estudiante;
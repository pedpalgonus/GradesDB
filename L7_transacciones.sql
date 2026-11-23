-- ===== 1. AUTOCOMMIT y START TRANSACTION =====

CALL p_populate();

SET AUTOCOMMIT = 1;
START TRANSACTION;

INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
VALUES (6, 1, 4.5, 'Extraordinaria', 0);
INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
VALUES (7, 1, 7.5, 'Extraordinaria', 0);

SELECT @@in_transaction;
COMMIT;

SELECT * FROM grades
WHERE student_id IN (6, 7) AND exam_call = 'Extraordinaria';

-- ===== 2. Bloque anónimo =====
CALL p_populate();

DELIMITER //
BEGIN NOT ATOMIC
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
    VALUES (6, 1, 4.5, 'Extraordinaria', 0);
    INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
    VALUES (7, 1, 7.5, 'Extraordinaria', 0);
    INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
    VALUES (8, 1, -7.5, 'Extraordinaria', 0);

    COMMIT;
END //
DELIMITER ;
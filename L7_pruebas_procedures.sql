CALL p_populate();
CALL p_insert_degree_subject('Grado en Ciberseguridad', 4, 'Redes Neuronales', 'FP', 6, 3, 'Obligatoria');


SELECT * FROM degrees WHERE degree_name = 'Grado en Ciberseguridad';
SELECT * FROM subjects WHERE subject_name = 'Redes Neuronales';



CALL p_populate();
CALL p_insert_degree_subject_transactional('Grado en Ciberseguridad', 4, 'Redes Neuronales', 'FP', 6, 3, 'Obligatoria');


CALL p_populate();
CALL p_insert_degree_subject_transactional(
    'Grado en Inteligencia Artificial', 4,
    'Aprendizaje Automático', 'AA', 6, 3, 'Obligatoria');

SELECT * FROM degrees WHERE degree_name = 'Grado en Inteligencia Artificial';
SELECT * FROM subjects WHERE acronym = 'AA';
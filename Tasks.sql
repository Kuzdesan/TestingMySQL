--TASK1
SELECT name_student, date_attempt, result 
FROM student LEFT JOIN attempt USING(student_id) 
INNER JOIN subject USING(subject_id) 
WHERE name_subject = 'Основы баз данных' ORDER BY result DESC;

--TASK2
SELECT name_subject, 
COUNT(attempt_id) AS "Количество", 
ROUND((SUM(result)/COUNT(attempt_id)), 2) AS "Среднее" 
FROM subject LEFT JOIN attempt USING (subject_id) GROUP BY name_subject;

--TASK3
SELECT 
name_student, name_subject, DATEDIFF(MAX(date_attempt),
 MIN(date_attempt)) AS "Интервал" F
 ROM student INNER JOIN attempt USING(student_id) 
 INNER JOIN subject USING(subject_id) 
 GROUP BY name_student, name_subject 
 HAVING Интервал>0 
 ORDER BY Интервал;
 
--TASK4
SELECT name_question, name_answer, IF(is_correct, 'Верно', 'Неверно') AS 'Результат'
FROM attempt AS att INNER JOIN student AS st USING(student_id)
INNER JOIN subject AS sub USING (subject_id)
INNER JOIN testing AS tst USING (attempt_id)
INNER JOIN question AS q USING (question_id)
INNER JOIN answer AS an USING (answer_id)
WHERE st.name_student='Семенов Иван' 
AND sub.name_subject ='Основы SQL' 
AND att.date_attempt ='2020-05-17';

--TASK5
SELECT name_student, name_subject, date_attempt, ROUND((SUM(is_correct)/3)*100, 2) AS "Результат" FROM
attempt AS att INNER JOIN student AS st USING(student_id)
INNER JOIN subject AS sub USING (subject_id)
INNER JOIN testing AS tst USING (attempt_id)
INNER JOIN question AS q USING (question_id)
INNER JOIN answer AS an USING (answer_id) 
GROUP BY name_student, name_subject, date_attempt
ORDER BY name_student, date_attempt DESC;

--TASK6
SELECT 
    name_subject, 
    CONCAT(SUBSTRING(name_question, 1, 30), '...') AS "Вопрос",
    COUNT(attempt_id) AS "Всего_ответов",
    ROUND((SUM(is_correct)/COUNT(*))*100,2) AS "Успешность"
FROM
    attempt AS att INNER JOIN student AS st USING(student_id)
    INNER JOIN subject AS sub USING (subject_id)
    INNER JOIN testing AS tst USING (attempt_id)
    INNER JOIN question AS q USING (question_id)
    INNER JOIN answer AS an USING (answer_id) 
GROUP BY name_subject, Вопрос 
ORDER BY name_subject, Успешность DESC, Вопрос;

--TASK7
SELECT name_subject, question_id, 
CONCAT(SUBSTRING(name_question, 1, 30), '...') AS 'question', 
CONCAT(SUBSTRING(name_answer, 1, 20), '...') AS 'answer' 
FROM subject INNER JOIN question USING (subject_id) 
INNER JOIN answer USING(question_id) 
WHERE is_correct=1 ORDER BY name_subject, question_id;

--TASK8
INSERT INTO testing(attempt_id, question_id) 
    SELECT  attempt_id, question_id 
    FROM attempt INNER JOIN question USING(subject_id) INNER JOIN 
    (SELECT question_id 
                  FROM student INNER JOIN attempt USING (student_id)
                  INNER JOIN question USING(subject_id)
             WHERE student_id = 
                  (SELECT student_id FROM attempt ORDER BY student_id DESC LIMIT 1)
             ORDER BY RAND() LIMIT 3) as query USING(question_id) 
        WHERE attempt_id = 
            (SELECT attempt_id FROM attempt ORDER BY attempt_id DESC LIMIT 1);
			
--TASK9
UPDATE attempt SET result = 
    (SELECT ROUND((SUM(IF(is_correct IS NOT NULL, is_correct, 0))/COUNT(answer_id))*100, 0) AS 'res'
     FROM answer LEFT JOIN testing USING(answer_id)
     WHERE attempt_id=8)
WHERE attempt_id =8;
SELECT* FROM attempt WHERE attempt_id=8;

--TASK10
WITH tb1(name_subject, name_question, Всего_ответов, Успешность) AS (
    SELECT 
    name_subject, 
    name_question,
    COUNT(attempt_id) AS "Всего_ответов",
    ROUND((SUM(is_correct)/COUNT(*))*100,2) AS "Успешность"
FROM
    attempt AS att INNER JOIN student AS st USING(student_id)
    INNER JOIN subject AS sub USING (subject_id)
    INNER JOIN testing AS tst USING (attempt_id)
    INNER JOIN question AS q USING (question_id)
    INNER JOIN answer AS an USING (answer_id) 
GROUP BY name_subject, name_question 
ORDER BY name_subject, Успешность DESC, name_question
)
SELECT* FROM (
    SELECT name_subject, name_question, IF(Успешность, 'самый легкий', NULL) AS "Сложность"  FROM tb1 WHERE Успешность = (SELECT MAX(Успешность) FROM tb1)
UNION
SELECT name_subject, name_question, IF(Успешность IS NOT NULL, 'самый сложный', NULL) AS "Сложность"  FROM tb1 WHERE Успешность = (SELECT MIN(Успешность) FROM tb1)
) AS qqq;

--TASK11
INSERT INTO 
    attempt(student_id, subject_id, date_attempt) 
    SELECT student_id, subject_id, NOW() 
    FROM attempt WHERE 
    (student_id, subject_id) IN (
        SELECT student_id, subject_id 
        FROM attempt 
        GROUP BY student_id, subject_id 
        HAVING COUNT(attempt_id)<3 AND MAX(result)<70
    );
SELECT* FROM attempt;

SELECT
  responses.*
FROM
  responses
JOIN
  answer_choices as a1
ON
  a1.id = responses.answer_id
JOIN
  questions as q1
ON
  q1.id = a1.question_id
JOIN
  answer_choices as a2
ON
  a2.question_id = q1.id
JOIN
  responses as r1
ON
  r1.answer_id = a2.id

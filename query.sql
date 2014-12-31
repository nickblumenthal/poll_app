select polls.*, count(questions.id), count(responses.id) 
from polls
join
questions on polls.id = questions.poll_id
left outer join
answer_choices on answer_choices.question_id = questions.id
left outer join
responses on responses.answer_id = answer_choices.id
--  where responses.user_id = 2
group by polls.id;

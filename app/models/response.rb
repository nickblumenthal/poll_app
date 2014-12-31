# == Schema Information
#
# Table name: responses
#
#  id         :integer          not null, primary key
#  answer_id  :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Response < ActiveRecord::Base
  validates :answer_id, presence: true
  validates :user_id, presence: true
  validate :respondent_has_not_already_answered_question
  #validate :author_should_not_answer_own_question
  validate :does_not_respond_to_own_poll
  belongs_to(
    :answer_choice,
    class_name: 'AnswerChoice',
    primary_key: :id,
    foreign_key: :answer_id,
  )

  belongs_to(
    :respondent,
    class_name: 'User',
    primary_key: :id,
    foreign_key: :user_id
  )

  has_one(
    :question,
    through: :answer_choice,
    source: :question
  )

  def sibling_responses
    if id.nil?
      question.responses
    else
      question.responses.where(
        'responses.id <> ?',
        self.id
      )
    end
  end

  def sibling_responses_crazy
    response_id = self.id.nil? ? -10 : self.id

    Response.find_by_sql([<<-SQL, response_id])
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
    WHERE r1.id <> ?
    SQL
  end

  def respondent_has_not_already_answered_question
    if sibling_responses.where('responses.user_id = ?', user_id).exists?
      errors['duplicate_response'] = 'Respondent already answered question'
    end
  end

  def author_should_not_answer_own_question
    if question.poll.author_id == user_id
      errors['authored_question'] = 'Author can not answer on question'
    end
  end

  def does_not_respond_to_own_poll
    author_num = Poll.joins( questions: {answer_choices: :responses})
    .where('questions.id = ?', question.id)
    .first.author_id
    if user_id == author_num
      errors['authored_question'] = 'Author can not answer on question'
    end
  end

end

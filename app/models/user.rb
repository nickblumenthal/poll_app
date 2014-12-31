# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  user_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  validates :user_name, presence: true

  has_many(
    :authored_polls,
    class_name: 'Poll',
    primary_key: :id,
    foreign_key: :author_id,
    dependent: :destroy
  )

  has_many(
    :responses,
    class_name: 'Response',
    primary_key: :id,
    foreign_key: :user_id,
    dependent: :destroy
  )

  def completed_polls
    Poll.find_by_sql([<<-SQL, self.id])
      select
        polls.*, count(distinct questions.id) as question_count, count(resp_by_user.answer_id ) as answers
      from
        polls
      join
        questions on polls.id = questions.poll_id
      left outer join
        answer_choices on answer_choices.question_id = questions.id
      left outer join
      (
        select answer_id from responses where user_id = ?
      ) as resp_by_user
      on
        resp_by_user.answer_id = answer_choices.id
      group by
        polls.id
      having
        count(distinct questions.id) = count(resp_by_user.answer_id)
    SQL
  end

  def completed_polls2
    Poll.find_by_sql([<<-SQL, self.id])
      select
        polls.*, count(distinct questions.id), count(resp_by_user.answer_id)
      from
        polls
      join
        questions on polls.id = questions.poll_id
      left outer join
        answer_choices on answer_choices.question_id = questions.id
      left outer join
        responses resp_by_user
      on
        resp_by_user.answer_id = answer_choices.id
      where
        resp_by_user.user_id = ? OR resp_by_user.user_id is null
      group by
        polls.id
      having
        count(distinct questions.id) = count(resp_by_user.answer_id)
    SQL
  end


  def completed_polls_ar
    Poll
      .select('polls.*, count(distinct questions.id), count(responses.answer_id)')
      .joins(:questions)
      .joins('LEFT OUTER JOIN answer_choices on answer_choices.question_id = questions.id')
      .joins('LEFT OUTER JOIN responses on responses.answer_id = answer_choices.id' )
      .where('responses.user_id = ? OR responses.user_id IS NULL', self.id)
      .group('polls.id')
      .having('count(distinct questions.id) = count(responses.answer_id)')
  end
end

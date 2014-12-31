# == Schema Information
#
# Table name: questions
#
#  id         :integer          not null, primary key
#  text       :string
#  poll_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Question < ActiveRecord::Base
  validates :poll_id, presence: true
  validates :text, presence: true

  has_many(
    :answer_choices,
    class_name: 'AnswerChoice',
    primary_key: :id,
    foreign_key: :question_id,
    dependent: :destroy
  )

  belongs_to(
    :poll,
    class_name: 'Poll',
    primary_key: :id,
    foreign_key: :poll_id
   )

   has_many(
    :responses,
    through: :answer_choices,
    source: :responses,
    dependent: :destroy
   )

   def results
    choices  = answer_choices.includes(:responses)
    result = Hash.new { |h, k| h[k] = 0 }
    choices.each do |choice|
      result[choice.text] = choice.responses.length
    end
    result
   end

   def results_active_record
      answer_choices.select('answer_choices.*, count(responses.id) as resp_count')
        .joins('LEFT OUTER JOIN responses ON answer_choices.id = responses.answer_id')
        .group('answer_choices.id')
        .map{ |res| [res.text, res.resp_count] }
   end
end

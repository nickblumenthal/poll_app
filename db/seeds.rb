# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
u1 = User.where(user_name: 'Fred').first_or_create!
u2 = User.where(user_name: 'Bob').first_or_create!

p1 = Poll.where(title: 'Fav Food', author_id: u1.id).first_or_create!

q1 = Question.where(text: 'What is your fav food?', poll_id: p1.id).first_or_create!

ac1 = AnswerChoice.where(text: 'Pizza', question_id: q1.id).first_or_create!
ac2 = AnswerChoice.where(text: 'Tofu', question_id: q1.id).first_or_create!

r1 = Response.where(answer_id: ac1.id, user_id: u1.id).first_or_create
r2 = Response.where(answer_id: ac2.id, user_id: u2.id).first_or_create

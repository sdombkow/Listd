# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'SETTING UP DEFAULT USER LOGIN'
user = User.create! :name => 'Listd Admin', :email => 'admin@listdnow.com', :password => 'adminpw', :password_confirmation => 'adminpw'
puts 'New user created: ' << user.name
user.admin = true
user.save
user2 = User.create! :name => 'First partner', :email => 'partner@listdnow.com', :password => 'partnerpw', :password_confirmation => 'partnerpw'
puts 'New user created: ' << user2.name
user2.partner = true
user2.save
user3 = User.create! :name => 'First User', :email => 'user@listdnow.com', :password => 'userpw', :password_confirmation => 'userpw'
puts 'New user created: ' << user3.name

# spec/factories/contacts.rb

require "faker"

FactoryGirl.define do
  factory :user do |u|
    u.name { Faker::Name.first_name }
    u.phone { Faker::PhoneNumber.cell_phone }
  end
end

# spec/models/contact.rb
require 'rails_helper'

describe User do
  	it "has a valid factory" do
  	  	FactoryGirl.create(:user).should be_valid
 	end

  	it "is invalid without a name" do
  		#Build instantiates new model but doesn't save it
  		FactoryGirl.build(:user, name: nil).should_not be_valid
	end


	it "is invalid without a phone" do
		FactoryGirl.build(:user, phone: nil).should_not be_valid
	end

end
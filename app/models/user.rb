class User < ActiveRecord::Base

	validates_presence_of :name, :phone
	belongs_to :guest

	has_many :p_following, :class_name => 'Follows', :foreign_key => 'username'
  	has_many :p_followedby, :class_name => 'Follows', :foreign_key => 'follower'

end

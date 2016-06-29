class User < ActiveRecord::Base

	has_many :p_following, :class_name => 'Follows', :foreign_key => 'username'
  	has_many :p_followedby, :class_name => 'Follows', :foreign_key => 'follower'

end

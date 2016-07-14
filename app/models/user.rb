class User < ActiveRecord::Base

	belongs_to :guest
	validates_presence_of :name, :phone


end

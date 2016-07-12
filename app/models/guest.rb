class Guest < ActiveRecord::Base

	# A guest is a visitor to Phone Scout
	# A user is a person using Twitter
	has_many :users

	def self.find_or_create_from_auth_hash(auth_hash)
		guest = where(provider: auth_hash.provider, uid: auth_hash.uid).first_or_create
		guest.update(
			guest_name: auth_hash.info.name,
			token: auth_hash.credentials.token,
			secret: auth_hash.credentials.secret
			)
		guest
	end


end

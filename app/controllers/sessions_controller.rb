class SessionsController < ApplicationController

	def create 
		@guest = Guest.find_or_create_from_auth_hash(auth_hash)
		session[:guest_id] = @guest.id
		redirect_to root_path
	end

	def destroy
		session[:guest_id] = nil
		redirect_to root_path
	end

	protected

	def auth_hash
		request.env['omniauth.auth']
	end



end

class RegistrationsController < ApplicationController
	skip_before_action :authorize, only: [:create]
	layout 'login'

	def create
		@registration = Form::Registration.new(set_params)
		if(@registration.valid?)
			puts "validation goes through"
			Group.register(@registration)
			flash.now.alert = "Registered successfully, Please login..."
			redirect_to root_path
		else
			puts "Validation fails"
			render 'sessions/new'
		end
	end

	private

 	def set_params
      params.require(:form_registration).permit(:groupname, :email, :password, :confirm_password, :username, :start_date, :firstname, :lastname)
    end
end
class SessionsController < ApplicationController
	skip_before_action :authenticate, only: [:new, :create]
	layout 'login'

	def new
		@registration = Form::Registration.new
	end

  	def create
	  user = User.authenticate(params[:username], params[:password])
	  if user
	    session[:user_id] = user.id
	    redirect_to root_url
	  else
	  	@registration = Form::Registration.new
	    flash.now.alert = "Invalid email or password"
	    render "new"
	  end
	end

	def destroy
	  session[:user_id] = nil
	  redirect_to new_session_url, :notice => "Logged out!"
	end
end

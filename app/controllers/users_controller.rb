class UsersController < ApplicationController
	#include Authorization
	before_action do
		current_user
		set_tab_name('members')	
	end

	def index
		@users = Group.get_users_by_group_id(current_user.loggedin_group.id)
	end

	def new
		@user = Form::User.new
	end

	def create
		Authorization.authorize(current_user.id, current_user.loggedin_group.id, 0)
		@user = Form::User.new(set_params)
		if(@user.valid?)
			puts "Validation goes through"
			User.create_user(@user, current_user.loggedin_group)
			redirect_to users_path
		else
			puts "Validatio fails"
			render 'new'
		end
	end

	def edit
		set_user
	end

	def update
		@user = Form::User.new(set_params)
		@user.id = set_user_id
		if(@user.valid?)
			puts "**************************"
			User.update_user(@user)
			redirect_to users_path
		else
			render 'edit'
		end
	end

	def destroy
		db_user = User.find(set_user_id)
		db_user.destroy
		redirect_to users_path
	end

	private

	def set_user
		db_user = User.find(params[:id])
		@user = Form::User.new
		@user.id = db_user.id
		@user.firstname = db_user.firstname
		@user.lastname = db_user.lastname
		@user.email = db_user.email
		@user.username = db_user.username

		@user
	end

	def set_user_id
		params[:id]
	end

 	def set_params
      	params.require(:form_user).permit(:email, :password, :confirm_password, :username, :firstname, :lastname)
    end
end
class User < ActiveRecord::Base
    self.table_name = "grpexp.users"

  	has_many :user_groups, :class_name => UserGroup, :foreign_key => 'user_id', :dependent => :destroy
  	has_many :groups, :through => :user_groups

  	attr_accessor :password

    before_save :encrypt_password

  	def self.authenticate(username, password)
      	user = find_by_username(username)
      	if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
            user
  		  else
  	 		    nil
  		  end
  	end

  	def encrypt_password
      	if password.present?
        		self.password_salt = BCrypt::Engine.generate_salt
        		self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
      	end
    end

    def loggedin_group
        self.groups.first
    end

    def self.create_user(param_user, group)
        user = User.new
        user.username = param_user.username
        user.firstname = param_user.firstname
        user.lastname = param_user.lastname
        user.email = param_user.email
        user.password = param_user.password
        user.save

        user_group = UserGroup.new
        user_group.is_admin = false
        user_group.user_id = user.id
        user_group.group_id = group.id
        user_group.save
    end

    def self.update_user(param_user)
        user = User.find(param_user.id)
        user.firstname = param_user.firstname
        user.lastname = param_user.lastname
        user.username = param_user.username
        user.email = param_user.email
        user.save
    end

    def full_name
        self.firstname + " " + self.lastname
    end

    def admin?(group_id)
        group = UserGroup.where(:user_id => self.id, :group_id => group_id).first

        group.is_admin
    end
end
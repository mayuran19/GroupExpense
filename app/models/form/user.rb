class Form::User
	include ActiveModel::Validations
	include ActiveModel::Conversion
  	extend ActiveModel::Naming

  	def initialize(attributes = {})
    	self.attributes = attributes
	end

	def attributes=(attributes)
		@id = attributes[:id]
		@username = attributes[:username]
		@email = attributes[:email]
		@firstname = attributes[:firstname]
		@lastname = attributes[:lastname]
		@password = attributes[:password]
		@confirm_password = attributes[:confirm_password]		
	end

	def persisted?
		false
	end

	attr_accessor :id
	attr_accessor :username
	attr_accessor :email
	attr_accessor :firstname
	attr_accessor :lastname
	attr_accessor :groupname
	attr_accessor :password
	attr_accessor :confirm_password

	validates :username, presence: true
	validates :firstname, presence: true
	validates :lastname, presence: true
	validates :email, presence: true
	validates :password, presence: true, if: :is_new?
	validates :confirm_password, presence: true, if: :is_new?

	validate :unique_username
	validate :equal_password_and_confirmation

	def unique_username
		if @id.nil?
			if User.where(username: @username).count > 0
				errors.add(:username, "Username already taken")
			end
		else
			if User.where("username = ? and id <> ?", @username, @id).count > 0
				errors.add(:username, "Username already taken")
			end
		end
	end

	def equal_password_and_confirmation
		if password != confirm_password
			errors.add(:password, "Password and confirm password must match")
		end
	end

	def is_new?
		id.nil?
	end
end
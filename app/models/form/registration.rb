class Form::Registration
	include ActiveModel::Validations
	include ActiveModel::Conversion
  	extend ActiveModel::Naming

	def initialize(attributes = {})
    	self.attributes = attributes
	end

	def attributes=(attributes)
		@username = attributes[:username]
		@email = attributes[:email]
		@firstname = attributes[:firstname]
		@lastname = attributes[:lastname]
		@groupname = attributes[:groupname]
		@password = attributes[:password]
		@confirm_password = attributes[:confirm_password]
		if(attributes['start_date(1i)'] != nil && attributes['start_date(2i)'] != nil && attributes['start_date(3i)'] != nil)
			@start_date= Date.civil(attributes['start_date(1i)'].to_i, attributes['start_date(2i)'].to_i, attributes['start_date(3i)'].to_i)
		else
			@start_date = Date.today
		end
	end
  
	def persisted?
		false
	end

	attr_accessor :username
	attr_accessor :email
	attr_accessor :firstname
	attr_accessor :lastname
	attr_accessor :groupname
	attr_accessor :password
	attr_accessor :confirm_password
	attr_accessor :start_date

	validates :username, presence: true
	validates :firstname, presence: true
	validates :lastname, presence: true
	validates :email, presence: true
	validates :groupname, presence: true
	validates :password, presence: true
	validates :confirm_password, presence: true
	validates :start_date, presence: true

	validate :unique_username
	validate :unique_groupname
	validate :equal_password_and_confirmation

	def unique_username
		if user = ::User.where(username: username).count > 0
			errors.add(:username, "Username already taken")
		end
	end

	def unique_groupname
		if group = ::Group.where(groupname: groupname).count > 0
			errors.add(:username, "Group name already taken")
		end
	end

	def equal_password_and_confirmation
		if password != confirm_password
			errors.add(:password, "Password and confirm password must match")
		end
	end
end
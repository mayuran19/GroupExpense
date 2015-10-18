class Form::ExpenseFactor
	include ActiveModel::Validations
	include ActiveModel::Conversion
  	extend ActiveModel::Naming

  	def initialize(attributes = {})
    	self.attributes = attributes
	end

	def attributes=(attributes)
		map = Hash.new
		attributes.each do |k, v| 
			map[k] = v
		end
		@expense_per_users = map
	end

	def persisted?
		false
	end

	attr_accessor :expense_per_users
	attr_accessor :expense

	validate :valid_amount

	def valid_amount
		self.expense_per_users.each do |k, v|
			if v.to_i == 0
				errors.add(:expense_per_users, "Please enter a valid number")
			end
		end
	end
end
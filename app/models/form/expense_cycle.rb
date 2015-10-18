class Form::ExpenseCycle
	include ActiveModel::Validations
	include ActiveModel::Conversion
  	extend ActiveModel::Naming

  	def initialize(attributes = {})
    	self.attributes = attributes
	end

	def attributes=(attributes)
		
	end

	def persisted?
		false
	end

	attr_accessor :id
	attr_accessor :to_date
	attr_accessor :from_date
	attr_accessor :group_id

	validate :validate_to_date

	def validate_to_date
		current_expense_cycle = ExpenseCycle.get_current_expense_cycle(group_id)
		if(current_expense_cycle.from_date >= to_date)
			errors.add(:to_date, "To date cannot be less than from date")
		end
	end
end
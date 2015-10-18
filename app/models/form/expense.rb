class Form::Expense
	include ActiveModel::Validations
	include ActiveModel::Conversion
  	extend ActiveModel::Naming

  	def initialize(attributes = {})
    	self.attributes = attributes
	end

	def attributes=(attributes)
		@id = attributes[:id]
		@group_id = attributes[:group_id]
		@user_id = attributes[:user_id]
		@fixed_expense_id = attributes[:fixed_expense_id]
		@expense_description = attributes[:expense_description]
		@amount = attributes[:amount]
		if attributes[:expense_date]
			@expense_date = Date.parse(attributes["expense_date"].values.join("-"))
		else
			@expense_date = Date.today
		end
		@expense_cycle_id = attributes[:expense_cycle_id]
		@user_ids = attributes[:user_ids]
	end

	def persisted?
		false
	end

	attr_accessor :id
	attr_accessor :group_id
	attr_accessor :user_id
	attr_accessor :fixed_expense_id
	attr_accessor :expense_description
	attr_accessor :amount
	attr_accessor :expense_date
	attr_accessor :expense_cycle_id
	attr_accessor :user_ids

	validates :expense_description, presence: true
	validates :amount, numericality: true
end
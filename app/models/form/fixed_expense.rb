class Form::FixedExpense
	include ActiveModel::Validations
	include ActiveModel::Conversion
  	extend ActiveModel::Naming

  	def initialize(attributes = {})
    	self.attributes = attributes
	end

	def attributes=(attributes)
		@id = attributes[:id]
		@name = attributes[:name]
		@is_mandatory = attributes[:is_mandatory]
		@default_amount = attributes[:default_amount]
		@default_user_id = attributes[:default_user_id]	
	end

	def persisted?
		false
	end

	attr_accessor :id
	attr_accessor :name
	attr_accessor :is_mandatory
	attr_accessor :default_amount
	attr_accessor :default_user_id

	validates :name, presence: true
	validates :default_user_id, presence: true
end
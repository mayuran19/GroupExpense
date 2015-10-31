class FixedExpense < ActiveRecord::Base
	self.table_name = "grpexp.fixed_expenses"

	belongs_to :default_payee, :class_name => User, :foreign_key => 'default_user_id'

	def self.fixed_expenses_by_group_id(group_id)
  		FixedExpense.where(:group_id => group_id)
  	end

  	def self.fixed_expenses_not_paid_for_current_cycle(group_id)
  		FixedExpense.where("group_id = ? and id not in(select fixed_expense_id from grpexp.expenses where group_id = ? and expense_cycle_id = (select cast(setting_value as int) from grpexp.group_settings where setting_name = 'CURRENT_ACCOUNT_CYCLE' and group_id = ?) and fixed_expense_id is not null)", group_id, group_id, group_id)
  	end

  	def self.new_fixed_expense(fixed_expense_form, group_id)
  		fixed_expense = FixedExpense.new
  		fixed_expense.name = fixed_expense_form.name
  		fixed_expense.group_id = group_id
  		fixed_expense.is_mandatory = fixed_expense_form.is_mandatory
  		fixed_expense.default_amount = fixed_expense_form.default_amount
  		fixed_expense.default_user_id = fixed_expense_form.default_user_id
  		fixed_expense.save
  	end

  	def self.update_fixed_expense(fixed_expense_form, group_id)
  		fixed_expense = FixedExpense.find(fixed_expense_form.id)
  		fixed_expense.name = fixed_expense_form.name
  		fixed_expense.group_id = group_id
  		fixed_expense.is_mandatory = fixed_expense_form.is_mandatory
  		fixed_expense.default_amount = fixed_expense_form.default_amount
  		fixed_expense.default_user_id = fixed_expense_form.default_user_id
  		fixed_expense.save
  	end

  	def self.delete_fixed_expense(fixed_expense_id)
  		fixed_expense = FixedExpense.find(fixed_expense_id)
  		fixed_expense.destroy
  	end

  	def self.get_fixed_expense_form_by_fixed_expense_id(fixed_expense_id)
  		fixed_expense = FixedExpense.find(fixed_expense_id)
  		fixed_expense_form = Form::FixedExpense.new
  		fixed_expense_form.id = fixed_expense.id
  		fixed_expense_form.name = fixed_expense.name
  		fixed_expense_form.is_mandatory = fixed_expense.is_mandatory
  		fixed_expense_form.default_amount = fixed_expense.default_amount
  		fixed_expense_form.default_user_id = fixed_expense.default_user_id

  		fixed_expense_form
  	end

  	def self.get_expense_form_by_fixed_expense_id(fixed_expense_id)
  		expense_form = Form::Expense.new
  		fixed_expense = FixedExpense.find(fixed_expense_id)
  		expense_form.user_id = fixed_expense.default_user_id
  		expense_form.fixed_expense_id = fixed_expense.id
  		expense_form.expense_description = fixed_expense.name
  		expense_form.amount = fixed_expense.default_amount

  		expense_form
  	end
end
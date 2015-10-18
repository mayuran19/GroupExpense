class ExpensesPerUserController < ApplicationController
	before_action do
		current_user
		set_tab_name('expenses')	
	end

	def index
		@current_expense_cycle = ExpenseCycle.get_current_expense_cycle(current_user.loggedin_group.id)
    	@expense = Expense.find(set_expense_id)
	end

	def edit
		@expense = Expense.find(set_expense_id)
		@expense_per_user = ExpensesPerUser.find(set_id)
	end

	def update
		
	end

	private

	def set_expense_id
		params[:expense_id]
	end

	def set_id
		params[:id]
	end
end
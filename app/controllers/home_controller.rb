class HomeController < ApplicationController
	before_action do
		current_user
		set_tab_name('home')	
	end

	def index
		@current_expense_cycle = ExpenseCycle.get_current_expense_cycle(current_user.loggedin_group.id)
    	@fixed_expenses = FixedExpense.fixed_expenses_not_paid_for_current_cycle(current_user.loggedin_group.id)
    	@expenses = Expense.get_expenses_for_current_cycle(current_user.loggedin_group.id, @current_expense_cycle.id)
	end
end
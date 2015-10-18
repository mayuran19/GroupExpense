class ExpensesSummaryController < ApplicationController
	before_action do
		current_user
		set_tab_name('expenses')	
	end

	def index
		@account_cycle = ExpenseCycle.get_last_expense_cycle(current_user.loggedin_group.id)
	    @total_summary = ExpensesSummary.get_total_for_cycle(current_user.loggedin_group.id, @account_cycle.id)
	    @spendings = ExpensesSummary.get_users_spendings(current_user.loggedin_group.id, @account_cycle.id)
	    @expenses = ExpensesSummary.get_users_expenses(current_user.loggedin_group.id, @account_cycle.id)
	    @receivers = ExpensesSummary.get_receivers(current_user.loggedin_group.id, @account_cycle.id)
	    @payers = ExpensesSummary.get_payers(current_user.loggedin_group.id, @account_cycle.id)
	end
end
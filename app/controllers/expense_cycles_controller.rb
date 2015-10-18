class ExpenseCyclesController < ApplicationController
	before_action do
		current_user
		set_tab_name('expenses')	
	end

	def index
		@current_expense_cycle = ExpenseCycle.get_current_expense_cycle(current_user.loggedin_group.id)
		@expense_cycles = ExpenseCycle.get_all_by_group_id(current_user.loggedin_group.id)
	end

	def show
		@account_cycle = ExpenseCycle.find_by_id(set_id)
	    @total_summary = ExpensesSummary.get_total_for_cycle(current_user.loggedin_group.id, @account_cycle.id)
	    @spendings = ExpensesSummary.get_users_spendings(current_user.loggedin_group.id, @account_cycle.id)
	    @expenses = ExpensesSummary.get_users_expenses(current_user.loggedin_group.id, @account_cycle.id)
	    @receivers = ExpensesSummary.get_receivers(current_user.loggedin_group.id, @account_cycle.id)
	    @payers = ExpensesSummary.get_payers(current_user.loggedin_group.id, @account_cycle.id)
	end

	def edit
		@expense_cycle = ExpenseCycle.find_by_id(set_id)
		@expense_cycle_form = ExpenseCycle.get_expense_cycle_form_by_expense_cycle_id(@expense_cycle.id)
	end

	def update
		@expense_cycle_form = get_expense_cycle_form
		#group_id has to be set before the validation is called
		@expense_cycle_form.group_id = current_user.loggedin_group.id
		if @expense_cycle_form.valid?
			#update
			ExpenseCycle.update_from_expense_cycle_form(get_expense_cycle_form)
			redirect_to expense_cycles_path
		else
			render 'edit'
		end
	end

	private

	def set_id
		id = params[:id]
	end

	def get_expense_cycle_form
		expense_cycle = ExpenseCycle.find_by_id(set_id)

		expense_cycle_form = Form::ExpenseCycle.new
		expense_cycle_form.id = params[:id]
		expense_cycle_form.to_date = Date.civil(params[:form_expense_cycle]['to_date(1i)'].to_i, params[:form_expense_cycle]['to_date(2i)'].to_i, params[:form_expense_cycle]['to_date(3i)'].to_i)
		expense_cycle_form.from_date = expense_cycle.from_date
		expense_cycle_form
	end
end
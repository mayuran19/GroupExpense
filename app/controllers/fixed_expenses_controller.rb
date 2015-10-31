class FixedExpensesController < ApplicationController
	before_action do
		current_user
		set_tab_name('expenses')	
	end

	def index
		@fixed_expenses = FixedExpense.fixed_expenses_by_group_id(current_user.loggedin_group.id)
	end

	def edit
		@fixed_expense_form = FixedExpense.get_fixed_expense_form_by_fixed_expense_id(set_id)
		@users = Group.get_users_by_group_id(current_user.loggedin_group.id)
	end

	def update
		fixed_expense_id = set_id
		@fixed_expense_form = Form::FixedExpense.new(set_params)
		@fixed_expense_form.id = fixed_expense_id
		if(@fixed_expense_form.valid?)
			puts "Validation goes through"
			FixedExpense.update_fixed_expense(@fixed_expense_form, current_user.loggedin_group.id)
			redirect_to fixed_expenses_path
		else
			@users = Group.get_users_by_group_id(current_user.loggedin_group.id)
			puts "Validatio fails"
			render 'edit_fixed_expense'
		end
	end

	def destroy
		FixedExpense.delete_fixed_expense(set_id)
		redirect_to fixed_expenses_path
	end

	def new
		@fixed_expense_form = Form::FixedExpense.new
		@users = Group.get_users_by_group_id(current_user.loggedin_group.id)
	end

	def create
		@fixed_expense_form = Form::FixedExpense.new(set_params)
		if(@fixed_expense_form.valid?)
			puts "Validation goes through"
			FixedExpense.new_fixed_expense(@fixed_expense_form, current_user.loggedin_group.id)
			redirect_to fixed_expenses_path
		else
			@users = Group.get_users_by_group_id(current_user.loggedin_group.id)
			puts "Validatio fails"
			render 'new'
		end
	end

	def new_expense
		@users = Group.get_users_by_group_id(current_user.loggedin_group.id)
		@expense_form = FixedExpense.get_expense_form_by_fixed_expense_id(set_id)
	end

	def create_expense
		expense_form = Form::Expense.new(set_expense_params)
		Expense.create_expense(expense_form, current_user.loggedin_group.id, set_id)

		redirect_to root_path
	end

	private 

	def set_params
      	params.require(:form_fixed_expense).permit(:name, :default_amount, :default_user_id, :is_mandatory)
    end

    def set_expense_params
    	params.require(:form_expense).permit(:user_id, :expense_description, :amount, :expense_date, :user_ids => []).tap do |whitelisted|
    		whitelisted[:division_factor] = params[:form_expense][:division_factor]
    	end
    end

    def set_id
    	params[:id]
    end
end
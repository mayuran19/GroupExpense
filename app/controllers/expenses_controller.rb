class ExpensesController < ApplicationController
	before_action do
		current_user
		set_tab_name('expenses')	
	end

	def index

	end

	def new
		@users = Group.get_users_by_group_id(current_user.loggedin_group.id)
		@expense_form = Form::Expense.new
		@expense_form.user_id = current_user.id
	end

	def create
		@expense_form = Form::Expense.new(set_expense_params)
		if @expense_form.valid?
			Expense.create_expense(@expense_form, current_user.loggedin_group.id, set_id)
			redirect_to root_path
		else
			@users = Group.get_users_by_group_id(current_user.loggedin_group.id)
			render 'new'
		end
	end

	def destroy
		expense = Expense.find(set_id)
		expense.destroy

		redirect_to root_path
	end

	def edit_division_factor
    	@current_account_cycle = ExpenseCycle.get_current_expense_cycle(current_user.loggedin_group.id)
    	@expense = Expense.find(set_id)
    	map = Hash.new
    	@expense.expenses_per_user.each do |expense_per_user|
    		map[expense_per_user.id.to_s] = expense_per_user.division_factor_per_user
    	end
    	@expense_factor = Form::ExpenseFactor.new(map)
    	@expense_factor.expense = @expense
  	end

  	def update_division_factor
  		@expense = Expense.find(set_id)
  		@expense_factor = Form::ExpenseFactor.new(set_expense_per_users)
    	@expense_factor.expense = @expense
    	map = @expense_factor.expense_per_users
    	map.each do |k, v|
			puts "k:#{k} v:#{v}"
		end
    	if(@expense_factor.valid?)
    		map = @expense_factor.expense_per_users
		    total_factor = 0
		    map.each do |k, v|
				puts "k:#{k} v:#{v}"
				total_factor = total_factor + v.to_i
		    end
		    puts total_factor
		    puts @expense.amount
		    @expense.expenses_per_user.each do |per_user|
				per_user.amount = (@expense.amount / total_factor) * map[per_user.id.to_s].to_i
				puts per_user.amount
				per_user.division_factor = total_factor
				per_user.division_factor_per_user = map[per_user.id.to_s]
				per_user.save
		    end

	  		redirect_to root_path
	  	else
	  		@current_account_cycle = ExpenseCycle.get_current_expense_cycle(current_user.loggedin_group.id)
	  		render 'edit_division_factor'
    	end
  	end

	private 

	def set_params
      	params.require(:form_fixed_expense).permit(:name, :default_amount, :default_user_id, :is_mandatory)
    end

    def set_id
    	params[:id]
    end

    def set_expense_per_users
    	puts "******************************************8"
    	puts params[:expense_per_users]
    	puts params[:expense_per_users].class
    	puts "******************************************8"
    	params[:expense_per_users]
    end

    def get_user_factor_map
		map = Hash.new
		ids = params[:expenses_per_user_ids]
		ids.each do |id|
			map[id] = params["expense_per_users_id" + id]
		end

		map
    end

    def set_expense_params
    	puts params[:form_expense][:division_factor]
    	params[:form_expense][:division_factor].each do |k,v|
    		puts "#{k} #{v}"
    	end
    	puts "*******************************88"
    	params.require(:form_expense).permit(:user_id, :expense_description, :amount, :expense_date, :user_ids => []).tap do |whitelisted|
    		whitelisted[:division_factor] = params[:form_expense][:division_factor] 
    	end
    end
end
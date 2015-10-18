class Expense < ActiveRecord::Base
    self.table_name = "grpexp.expenses"

    has_many :expenses_per_user, :class_name => ExpensesPerUser, :foreign_key => 'expense_id', :dependent => :destroy
    has_many :users, :through => :expenses_per_user

    belongs_to :user

    def self.get_expenses_for_current_cycle(group_id, expense_cycle_id)
        Expense.where(:group_id => group_id, :expense_cycle_id => expense_cycle_id).order("fixed_expense_id nulls last, expense_date asc")
  	end

  	def self.create_expense(expense_form, group_id, fixed_expense_id)
    		expense = Expense.new
    		expense.group_id = group_id
    		expense.user_id = expense_form.user_id
    		expense.fixed_expense_id = fixed_expense_id
    		expense.expense_description = expense_form.expense_description
    		expense.amount = expense_form.amount
    		expense.expense_date = expense_form.expense_date
    		expense.expense_cycle_id = ExpenseCycle.get_current_expense_cycle(group_id).id
    		expense.save

  		  user_ids_without_empty = expense_form.user_ids.reject{|c| c.empty?}
    		user_ids_without_empty.each do |user_id|
      			expenses_per_user = ExpensesPerUser.new
      			expenses_per_user.expense_id = expense.id
      			expenses_per_user.user_id = user_id
      			expenses_per_user.group_id = group_id
      			expenses_per_user.amount = expense.amount / user_ids_without_empty.size
            expenses_per_user.division_factor = user_ids_without_empty.size
            expenses_per_user.division_factor_per_user = 1
      			expenses_per_user.save
      	end
  	end

    def self.get_expense_form_by_expense_id(expense_id)
        expense = Expense.find(expense_id)
        expense_form = Form::Expense.new
        expense_form.user_id = expense.user_id
        expense_form.expense_description = expense.expense_description
        expense_form.amount = expense.amount
        expense_form.expense_date = expense.expense_date
    end

    def self.is_all_fixed_expenses_updated?(group_id, expense_cycle_id)
        all_fixed_expenses_updated = true

        fixed_templates = FixedExpense.fixed_expenses_by_group_id(group_id)

        fixed_template_ids = Array.new
        fixed_template_map = {}

        fixed_templates.each do |fixed_template|
          fixed_template_ids.push(fixed_template.id)
          fixed_template_map[fixed_template.id] = fixed_template
        end

        expenses = Expense.where("group_id = ? and expense_cycle_id = ? and fixed_expense_id in(?)", group_id, expense_cycle_id, fixed_template_ids)

        expenses.each do |expense|
          fixed_template_map.delete(expense.fixed_expense_id)
        end

        if fixed_template_map.size != 0
          fixed_template_map.each do |k, v|
            puts "#{v.name} is not updated for group_id: #{group_id} and account_cycle: #{expense_cycle_id}"
          end
          all_fixed_expenses_updated = false
        end

        all_fixed_expenses_updated
    end

    def self.total_spending_by_users(group_id, expense_cycle_id)
        spending_by_tenants = Expense.find_by_sql(["select t2.id as user_id ,COALESCE(t1.amount,0) as amount from(
                          select user_id, round(sum(amount),2) amount from grpexp.expenses
                          where group_id = ? and expense_cycle_id = ?
                          group by user_id) t1
                          full outer join
                          (select id, 0 as amount from grpexp.users) t2 on t1.user_id = t2.id",group_id,expense_cycle_id])

        spending_by_tenants
    end
end
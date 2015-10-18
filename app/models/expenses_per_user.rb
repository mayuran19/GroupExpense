class ExpensesPerUser < ActiveRecord::Base
	self.table_name = "grpexp.expenses_per_user"

	belongs_to :user
  	belongs_to :expense

  	def self.find_total_expense(group_id, expense_cycle_id)
  		total = ExpensesPerUser.find_by_sql(["select round(sum(amount),4) as total_expense from grpexp.expenses_per_user where expense_id in(select id from grpexp.expenses where group_id = ? and expense_cycle_id = ?)", group_id, expense_cycle_id])
  		#puts total.first[:total_expense]
  		total.first[:total_expense]
  	end

  	def self.find_total_expense_per_user(group_id, expense_cycle_id)
  		total_per_tenants = ExpensesPerUser.find_by_sql(["select user_id,round(sum(amount),4) as amount from grpexp.expenses_per_user
															where expense_id in(select id from grpexp.expenses where group_id = ? and expense_cycle_id = ?)
															group by user_id", group_id, expense_cycle_id])

  		total_per_tenants
  end
end
class GroupExpenseMailer < ApplicationMailer
	def send_expense_detail(group_id, expense_cycle_id, user_id)
		@account_cycle = ExpenseCycle.find_by_id(expense_cycle_id)
	    @total_summary = ExpensesSummary.get_total_for_cycle(group_id, @account_cycle.id)
	    @spendings = ExpensesSummary.get_users_spendings(group_id, @account_cycle.id)
	    @expenses = ExpensesSummary.get_users_expenses(group_id, @account_cycle.id)
	    @receivers = ExpensesSummary.get_receivers(group_id, @account_cycle.id)
	    @payers = ExpensesSummary.get_payers(group_id, @account_cycle.id)

	    @user = User.find_by_id(user_id)
	    @group = Group.find_by_id(group_id)
	    attachments['HouseAccount.xlsx'] = File.read("/tmp/Expenses_" + expense_cycle_id.to_s + ".xlsx")
	    mail(to: @user.email, subject: @group.groupname)
	end
end
class ExpensesSummary < ActiveRecord::Base
	self.table_name = "grpexp.expenses_summary"

	belongs_to :group, :class_name => Group, :foreign_key => 'group_id'
	belongs_to :payer, :class_name => User, :foreign_key => 'payer_user_id'
	belongs_to :receiver, :class_name => User, :foreign_key => 'receiver_user_id'
	belongs_to :expense_cycle, :class_name => ExpenseCycle, :foreign_key => 'expense_cycle_id'
	belongs_to :expense_summary_item, :class_name => ExpensesSummaryItem, :foreign_key => 'expense_summary_item_id'

	#"1";"TOTAL_PER_EXPENSE_CYCLE"
	#"2";"TOTAL_PER_EXPENSE_CYCLE_PER_USER"
	#"3";"TOTAL_SPENDING_PER_EXPENSE_CYCLE_PER_USER"
	#"4";"TO_BE_PAID_TO"
	#"5";"TO_BE_RECEIVED_FROM"


	def self.delete_all_by_group_id_and_expense_cycle_id(group_id, expense_cycle_id)
		ExpensesSummary.where(:expense_cycle_id => expense_cycle_id, :group_id => group_id).delete_all
	end

	def self.calculate_total(group_id, expense_cycle_id)
		total_amount = ExpensesPerUser.find_total_expense(group_id, expense_cycle_id)
		puts "Total expense for group_id: #{group_id} and account_cycle: #{expense_cycle_id} is #{total_amount}"
		total_summary = ExpensesSummary.new
		total_summary.group_id = group_id
		total_summary.expense_cycle_id = expense_cycle_id
		total_summary.expense_summary_item_id = 1
		total_summary.amount = total_amount
		total_summary.save
	end

	def self.calculate_total_per_user(group_id, expense_cycle_id)
		total_per_tenants = ExpensesPerUser.find_total_expense_per_user(group_id, expense_cycle_id)
		total_per_tenants.each do |tenant_total|
			tenant_id = tenant_total[:user_id]
			total = tenant_total[:amount]

			total_summary = ExpensesSummary.new
			total_summary.group_id = group_id
			total_summary.expense_cycle_id = expense_cycle_id
			total_summary.expense_summary_item_id = 2
			total_summary.amount = total
			total_summary.payer_user_id = tenant_id
			total_summary.save
		end
	end

	def self.calculate_total_spending_by_user(group_id, expense_cycle_id)
		total_spendings = Expense.total_spending_by_users(group_id, expense_cycle_id)
		total_spendings.each do |total_spendings|
			tenant_id = total_spendings[:user_id]
			total = total_spendings[:amount]

			total_summary = ExpensesSummary.new
			total_summary.group_id = group_id
			total_summary.expense_cycle_id = expense_cycle_id
			total_summary.expense_summary_item_id = 3
			total_summary.amount = total
			total_summary.payer_user_id = tenant_id
			total_summary.save
		end
	end

	def self.get_users_to_receive_money(group_id, expense_cycle_id)
		sql = "select total_per_tenant.group_id as group_id,total_per_tenant.expense_cycle_id as expense_cycle_id,total_per_tenant.payer_user_id as tenant_id,@ (total_per_tenant.amount - spending_by_tenant.amount) as amount from (
				select * from grpexp.expenses_summary where expense_summary_item_id = '2' and group_id = ? and expense_cycle_id = ?
				) total_per_tenant
				inner join
				(
				select * from grpexp.expenses_summary where expense_summary_item_id = '3' and group_id = ? and expense_cycle_id = ?
				) spending_by_tenant on total_per_tenant.group_id = spending_by_tenant.group_id
				and total_per_tenant.expense_cycle_id = spending_by_tenant.expense_cycle_id
				and total_per_tenant.payer_user_id = spending_by_tenant.payer_user_id
				where (total_per_tenant.amount - spending_by_tenant.amount) < 0 order by (total_per_tenant.amount - spending_by_tenant.amount) asc"
		receivers = ExpensesSummary.find_by_sql([sql, group_id, expense_cycle_id, group_id, expense_cycle_id])
	end

	def self.get_users_to_pay_money(group_id, expense_cycle_id)
		sql = "select total_per_tenant.group_id as group_id,total_per_tenant.expense_cycle_id as expense_cycle_id,total_per_tenant.payer_user_id as tenant_id,total_per_tenant.amount - spending_by_tenant.amount as amount from (
				select * from grpexp.expenses_summary where expense_summary_item_id = '2' and group_id = ? and expense_cycle_id = ?
				) total_per_tenant
				inner join
				(
				select * from grpexp.expenses_summary where expense_summary_item_id = '3' and group_id = ? and expense_cycle_id = ?
				) spending_by_tenant on total_per_tenant.group_id = spending_by_tenant.group_id
				and total_per_tenant.expense_cycle_id = spending_by_tenant.expense_cycle_id
				and total_per_tenant.payer_user_id = spending_by_tenant.payer_user_id
				where (total_per_tenant.amount - spending_by_tenant.amount) > 0 order by (total_per_tenant.amount - spending_by_tenant.amount) desc"

		payers = ExpensesSummary.find_by_sql([sql, group_id, expense_cycle_id, group_id, expense_cycle_id])
	end

	def self.get_users_with_zero_balance(group_id, expense_cycle_id)
		sql = "select total_per_tenant.group_id as group_id,total_per_tenant.expense_cycle_id as expense_cycle_id,total_per_tenant.payer_user_id as tenant_id,total_per_tenant.amount - spending_by_tenant.amount as amount from (
				select * from grpexp.expenses_summary where expense_summary_item_id = '2' and group_id = ? and expense_cycle_id = ?
				) total_per_tenant
				inner join
				(
				select * from grpexp.expenses_summary where expense_summary_item_id = '3' and group_id = ? and expense_cycle_id = ?
				) spending_by_tenant on total_per_tenant.group_id = spending_by_tenant.group_id
				and total_per_tenant.expense_cycle_id = spending_by_tenant.expense_cycle_id
				and total_per_tenant.payer_user_id = spending_by_tenant.payer_user_id
				where (total_per_tenant.amount - spending_by_tenant.amount) = 0"

		tenants_zero_balance = ExpensesSummary.find_by_sql([sql, group_id, expense_cycle_id, group_id, expense_cycle_id])
	end

	def self.calculate_users_settlement(group_id, expense_cycle_id)
		receivers = self.get_users_to_receive_money(group_id, expense_cycle_id)
		puts "Receivers"
		puts receivers
		puts "Receivers"
		payers = self.get_users_to_pay_money(group_id, expense_cycle_id)
		puts "Payers"
		puts payers
		puts "Payers"
		tenants_zero_balance = self.get_users_with_zero_balance(group_id, expense_cycle_id)
		puts tenants_zero_balance

		
		

		while(payers.size != 0 || receivers.size != 0)
			puts "**********"
			puts receivers.size
			puts payers.size
			puts "**********"
			receiver = receivers.pop
			amount_to_receive = receiver[:amount]

			payer = payers.pop
			amout_to_pay = payer[:amount]

			puts "amount_to_receive:#{amount_to_receive}"
			puts "amount_to_pay:#{amout_to_pay}"

			if(amount_to_receive.round(2) == amout_to_pay.round(2))
				puts "Settle the receiver and payer"
				self.settle_payer(group_id, expense_cycle_id, amount_to_receive, payer[:tenant_id], receiver[:tenant_id])
				self.settle_receiver(group_id, expense_cycle_id, amount_to_receive, receiver[:tenant_id], payer[:tenant_id])
			elsif (amount_to_receive - amout_to_pay > 0)
				puts "Settle the payer"
				amount_to_receive = amount_to_receive - amout_to_pay
				receiver[:amount] = amount_to_receive
				self.settle_payer(group_id, expense_cycle_id, amout_to_pay, payer[:tenant_id], receiver[:tenant_id])
				self.settle_receiver(group_id, expense_cycle_id, amout_to_pay, receiver[:tenant_id], payer[:tenant_id])
				receivers.push(receiver)
			else
				puts "Settle the receiver"
				amout_to_pay = amout_to_pay - amount_to_receive
				payer[:amount] = amout_to_pay
				self.settle_payer(group_id, expense_cycle_id, amount_to_receive, payer[:tenant_id], receiver[:tenant_id])
				self.settle_receiver(group_id, expense_cycle_id, amount_to_receive, receiver[:tenant_id], payer[:tenant_id])
				payers.push(payer)
			end
		end
	end

	def self.settle_payer(group_id, expense_cycle_id, amount, tenant_id, to_tenant_id)
		payer_settlement = ExpensesSummary.new
		payer_settlement.group_id = group_id
		payer_settlement.expense_cycle_id = expense_cycle_id
		payer_settlement.expense_summary_item_id = 4
		payer_settlement.amount = amount
		payer_settlement.payer_user_id = tenant_id
		payer_settlement.receiver_user_id = to_tenant_id
		payer_settlement.save
	end

	def self.settle_receiver(group_id, expense_cycle_id, amount, tenant_id, to_tenant_id)
		payer_settlement = ExpensesSummary.new
		payer_settlement.group_id = group_id
		payer_settlement.expense_cycle_id = expense_cycle_id
		payer_settlement.expense_summary_item_id = 5
		payer_settlement.amount = amount
		payer_settlement.payer_user_id = tenant_id
		payer_settlement.receiver_user_id = to_tenant_id
		payer_settlement.save
	end

	def self.get_total_for_cycle(group_id, expense_cycle_id)
		total_summary = ExpensesSummary.where(:group_id => group_id, :expense_cycle_id => expense_cycle_id, :expense_summary_item_id => '1').first

		total_summary
	end

	def self.get_users_spendings(group_id, expense_cycle_id)
		spendings = ExpensesSummary.where(:group_id => group_id, :expense_cycle_id => expense_cycle_id, :expense_summary_item_id => '3')

		spendings
	end

	def self.get_users_expenses(group_id, expense_cycle_id)
		expenses = ExpensesSummary.where(:group_id => group_id, :expense_cycle_id => expense_cycle_id, :expense_summary_item_id => '2')

		expenses
	end

	def self.get_receivers(group_id, expense_cycle_id)
		receivers = ExpensesSummary.where(:group_id => group_id, :expense_cycle_id => expense_cycle_id, :expense_summary_item_id => '5')

		receivers
	end

	def self.get_payers(group_id, expense_cycle_id)
		payers = ExpensesSummary.where(:group_id => group_id, :expense_cycle_id => expense_cycle_id, :expense_summary_item_id => '4')

		payers
	end
end
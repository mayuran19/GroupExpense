require 'rake'

desc "Runs everyday to close the account for each house"
task :calculate_house_expense, [:processing_date, :group_id] => :environment do |t, args|
  puts "processing_date: #{args[:processing_date]}"
  puts "group_id: #{args[:group_id]}"

  processing_date = Date.strptime(args[:processing_date], '%Y%m%d')
  group_id = args[:group_id]

  account_cycle = ExpenseCycle.get_current_expense_cycle(group_id)

  puts "Account close date: #{account_cycle.to_date}"
  if(processing_date == account_cycle.to_date)
  	#Validate all fixed expenses are updated
  	if(Expense.is_all_fixed_expenses_updated?(group_id, account_cycle.id))
  		puts "All fixed exepenses update for the account_cycle: #{account_cycle.id}"
  		puts "delete all the entries from HouseAccountSummary"
      ExpensesSummary.delete_all_by_group_id_and_expense_cycle_id(group_id, account_cycle.id)

  		#Total for account cycle
  		ExpensesSummary.calculate_total(group_id, account_cycle.id)

  		#Total per tenant
  		ExpensesSummary.calculate_total_per_user(group_id, account_cycle.id)

  		#Total spending by tenant per cycle
  		ExpensesSummary.calculate_total_spending_by_user(group_id, account_cycle.id)

  		#Tenants settlement
  		ExpensesSummary.calculate_users_settlement(group_id, account_cycle.id)

  		#Move the house_account_cycle to next month
  		ExpenseCycle.move_to_next_expense_cycle(group_id)
  	end
  end
end
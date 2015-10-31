require 'rake'
require 'axlsx'

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

  Rake::Task['generate_excel'].invoke(group_id, account_cycle.id.to_s)
end

task :test, [:test_id] => :environment do |t, args|
  puts "#{args[:test_id]}"
  Rake::Task['generate_excel'].invoke("14", "9")
end

task :generate_excel, [:group_id, :expense_cycle_id] => :environment do |t, args|
  expense_cycle_id = args[:expense_cycle_id]
  group_id = args[:group_id]

  puts "Expense cycle id: #{expense_cycle_id}"
  puts "Group id: #{group_id}"

  expense_cycle = ExpenseCycle.find_by_id(expense_cycle_id)
  group = Group.find(group_id)

  Axlsx::Package.new do |p|
    p.workbook do |wb|
      wb.add_worksheet(:name => "#{expense_cycle.from_date} to #{expense_cycle.to_date}") do |sheet|
        currency = sheet.styles.add_style(:format_code=>"#,##0.00",
                              :border=>Axlsx::STYLE_THIN_BORDER)
        currency_blue = sheet.styles.add_style(:format_code=>"#,##0.00",
                              :border=>Axlsx::STYLE_THIN_BORDER,
                              :bg_color => "FF3BB9FF")
        date_time = sheet.styles.add_style(:num_fmt => Axlsx::NUM_FMT_YYYYMMDD,
                               :border=>Axlsx::STYLE_THIN_BORDER)
        background_color_blue = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER,
                                                  :bg_color => "FF3BB9FF")
        background_color_gray = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER,
                                                  :bg_color => "FF808080")

        #Summary details
        total_summary = ExpensesSummary.get_total_for_cycle(group_id, expense_cycle_id)
        spendings = ExpensesSummary.get_users_spendings(group_id, expense_cycle_id)
        expenses_summary = ExpensesSummary.get_users_expenses(group_id, expense_cycle_id)
        receivers = ExpensesSummary.get_receivers(group_id, expense_cycle_id)

        #Header for summary
        sheet.add_row ["Expense summary for #{expense_cycle.from_date} to #{expense_cycle.to_date}"]
        sheet.add_row []

        #Spending by each user
        spendings.each do |spending|
          spending_array = Array.new
          spending_style_array = Array.new

          spending_array.push("Amount spent by " + spending.payer.full_name)
          spending_style_array.push(Axlsx::STYLE_THIN_BORDER)

          spending_array.push(spending.amount)
          spending_style_array.push(currency)

          spending_array.push("")
          spending_style_array.push(Axlsx::STYLE_THIN_BORDER)

          sheet.add_row spending_array, :style => spending_style_array
        end

        #Total spending
        total_spending_array = Array.new
        total_spending_style_array = Array.new

        total_spending_array.push("Total spending")
        total_spending_style_array.push(Axlsx::STYLE_THIN_BORDER)

        total_spending_array.push("")
        total_spending_style_array.push(Axlsx::STYLE_THIN_BORDER)

        total_spending_array.push(total_summary.amount)
        total_spending_style_array.push(currency)

        sheet.add_row total_spending_array, :style => total_spending_style_array
        sheet.add_row []

        #Total expense for user
        expenses_summary.each do |expense_of_user|
          expense_of_user_array = Array.new
          expense_of_user_style_array = Array.new

          expense_of_user_array.push("Total expense for " + expense_of_user.payer.full_name)
          expense_of_user_style_array.push(Axlsx::STYLE_THIN_BORDER)

          expense_of_user_array.push(expense_of_user.amount)
          expense_of_user_style_array.push(currency)

          sheet.add_row expense_of_user_array, :style => expense_of_user_style_array
        end
        sheet.add_row []

        #Receivers of money
        receivers.each do |receiver|
          receiver_array = Array.new
          receiver_style_array = Array.new

          receiver_array.push("Amount to be paid by " + receiver.receiver.full_name + " to " + receiver.payer.full_name)
          receiver_style_array.push(background_color_blue)

          receiver_array.push(receiver.amount)
          receiver_style_array.push(currency_blue)

          sheet.add_row receiver_array, :style => receiver_style_array
        end

        sheet.add_row []

        #Detail expenses
        header_array = Array.new
        header_style_array = Array.new

        header_array.push("Date")
        header_style_array.push(background_color_gray)

        header_array.push("")
        header_style_array.push(background_color_gray)

        users = Group.get_users_by_group_id(group_id)
        user_column_map = Hash.new
        column_index = 2
        users.each do |user|
          header_array.push(user.firstname)
          header_style_array.push(background_color_gray)

          user_column_map[column_index] = user.id
          column_index = column_index + 1
        end
        sheet.add_row ["Expense details"]
        sheet.add_row header_array, :style => header_style_array

        expenses = Expense.find_by_group_id_and_expense_cycle(group_id, expense_cycle_id)
        expenses.each do |expense|
          expense_array = Array.new
          expense_style_array = Array.new

          expense_array.push(expense.expense_date)
          expense_style_array.push(date_time)

          expense_array.push(expense.expense_description)
          expense_style_array.push(Axlsx::STYLE_THIN_BORDER)

          tmp_column_index = 2
          (column_index - 2).times do |t|
            if(expense.user_id == user_column_map[tmp_column_index])
              expense_array.push(expense.amount)
              expense_style_array.push(currency)
            else
              expense_array.push("")
              expense_style_array.push(Axlsx::STYLE_THIN_BORDER)
            end

            tmp_column_index = tmp_column_index + 1
          end

          sheet.add_row expense_array, :style => expense_style_array

          expense_per_user = ExpensesPerUser.find_all_by_expense_id(expense.id)
          expense_per_head_array = Array.new
          expense_per_head_style_array = Array.new

          expense_per_head_array.push("")
          expense_per_head_style_array.push(nil)

          expense_per_head_array.push("Expense per user")
          expense_per_head_style_array.push(Axlsx::STYLE_THIN_BORDER)

          tmp_column_index = 2
          (column_index - 2).times do |t|
            has_per_user_expense = false
            expense_per_user.each do |user_expense|
              if(user_expense.user_id == user_column_map[tmp_column_index])
                expense_per_head_array.push(user_expense.amount)
                expense_per_head_style_array.push(currency)
                has_per_user_expense = true
                break
              end
            end
            if !has_per_user_expense
              expense_per_head_array.push(0)
              expense_per_head_style_array.push(currency)
            end

            tmp_column_index = tmp_column_index + 1
          end

          sheet.add_row expense_per_head_array, :style => expense_per_head_style_array
          sheet.add_row []
        end
      end
    end

    p.serialize(Rails.root.to_s + "/files/Expenses_" + expense_cycle_id + ".xlsx")
  end
end
class ExpenseCycle < ActiveRecord::Base
	self.table_name = "grpexp.expense_cycles"

	def self.get_current_expense_cycle(group_id)
		current_account_cycle = ExpenseCycle.where("id = (select cast(setting_value as int) from grpexp.group_settings where setting_name = 'CURRENT_ACCOUNT_CYCLE') and group_id = ?", group_id).first
	end

	def self.get_last_expense_cycle(group_id)
		last_cycle = ExpenseCycle.where(["id =(select max(expense_cycle_id) from grpexp.expenses_summary where group_id = ?)",group_id]).first
	end

	def self.move_to_next_expense_cycle(group_id)
		current_cycle = self.get_current_expense_cycle(group_id)

		#Move to next month
		new_house_account_cycle = ExpenseCycle.new
		new_house_account_cycle.group_id = group_id
		new_house_account_cycle.from_date = current_cycle.to_date
		new_house_account_cycle.to_date = current_cycle.to_date + 1.months
		new_house_account_cycle.save

		#Update the house_settings table with new house_account_cycle_id
		house_setting = GroupSetting.get_current_expense_cycle_setting(group_id)
		house_setting.setting_value = new_house_account_cycle.id.to_s
		house_setting.save
	end

	def self.get_all_by_group_id(group_id)
		expense_cycles = ExpenseCycle.where(:group_id => group_id)

		expense_cycles
	end

	def self.find_by_id(expense_cycle_id)
		expense_cycle = ExpenseCycle.find(expense_cycle_id)
	end

	def self.get_expense_cycle_form_by_expense_cycle_id(expense_cycle_id)
		expense_cycle = ExpenseCycle.find_by_id(expense_cycle_id)
		expense_cycle_form = Form::ExpenseCycle.new
		expense_cycle_form.id = expense_cycle.id
		expense_cycle_form.from_date = expense_cycle.from_date
		expense_cycle_form.to_date = expense_cycle.to_date

		expense_cycle_form
	end

	def self.update_from_expense_cycle_form(expense_cycle_form)
		expense_cycle = ExpenseCycle.find_by_id(expense_cycle_form.id)
		expense_cycle.to_date = expense_cycle_form.to_date
		expense_cycle.save
	end
end
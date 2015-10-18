class GroupSetting < ActiveRecord::Base
	self.table_name = "grpexp.group_settings"

	def self.update_current_cycle(group_id, expense_cycle_id)
		group_settings = GroupSetting.where(:setting_type => 'ACCOUNT_CYCLE', :setting_name => 'CURRENT_ACCOUNT_CYCLE', :group_id => group_id)
		if(group_settings.size > 0)
			#Update to the current cycle
			group_settings.first.setting_value = expense_cycle_id.to_s
			group_settings.first.save
		else
			#Insert
			group_setting = GroupSetting.new
			group_setting.setting_type = "ACCOUNT_CYCLE"
			group_setting.setting_name = "CURRENT_ACCOUNT_CYCLE"
			group_setting.setting_value = expense_cycle_id.to_s
			group_setting.group_id = group_id
			group_setting.save
		end
	end

	def self.get_current_expense_cycle_setting(group_id)
		house_setting = GroupSetting.where(:group_id => group_id, :setting_type => 'ACCOUNT_CYCLE', :setting_name => 'CURRENT_ACCOUNT_CYCLE').first

		house_setting
	end
end
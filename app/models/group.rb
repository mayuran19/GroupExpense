class Group < ActiveRecord::Base
	self.table_name = "grpexp.groups"

	has_many :user_groups, :class_name => UserGroup, :foreign_key => 'group_id', :dependent => :destroy
	has_many :users, :through => :user_groups

	def self.register(registration)
		group = Group.new
		group.groupname = registration.groupname
		group.save

		user = User.new
		user.username = registration.username
    	user.email = registration.email
    	user.firstname = registration.firstname
    	user.lastname = registration.lastname
    	user.password = registration.password
    	user.save

    	user_group = UserGroup.new
    	user_group.is_admin = true
        user_group.user_id = user.id
        user_group.group_id = group.id
        user_group.save

    	expense_cycle = ExpenseCycle.new
    	expense_cycle.group_id = group.id
    	expense_cycle.from_date = (registration.start_date + (25 - registration.start_date.day).days) - 1.months
    	expense_cycle.to_date = expense_cycle.from_date + 1.months
        expense_cycle.save

    	GroupSetting.update_current_cycle(group.id, expense_cycle.id)
	end

    def self.get_users_by_group_id(group_id)
        User.joins(:groups).where('grpexp.user_groups.group_id = ?', group_id)
    end
end
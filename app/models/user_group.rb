class UserGroup < ActiveRecord::Base
	self.table_name = "grpexp.user_groups"

	belongs_to :user
	belongs_to :group
end
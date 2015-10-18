module Authorization
	def Authorization.authorize(user_id, group_id, function_id)
		group = UserGroup.where(:user_id => user_id, :group_id => group_id).first
		puts "UserID:#{group.user_id}, GroupID:#{group.group_id}, IsAdmin:#{group.is_admin}"
		if !group.is_admin
			raise GrpExp::Exception::AuthorizationError.new("You don't have permission for this operation")
		end
	end

	def Authorization.is_authorized(user_id, group_id, function_id)
		user_group = UserGroup.where(:user_id => user_id, :group_id => group_id).first
		if user_group.is_admin
			true
		else
			false
		end
	end
end
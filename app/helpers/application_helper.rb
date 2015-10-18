module ApplicationHelper
	def is_authorized(user_id, group_id)
		Authorization.is_authorized(user_id, group_id, 0)
	end

	def authorized_link_to(user_id, group_id, *args, &block)
		if(Authorization.is_authorized(user_id, group_id, 0))
			link_to(*args, &block)
		else
			""
		end
	end
end

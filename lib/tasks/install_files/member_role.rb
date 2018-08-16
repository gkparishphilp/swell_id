class MemberRole < ApplicationRole

	def authorize( target, options = {} )
		raise ActionController::MethodNotAllowed.new('Not Allowed') unless options[:controller].present? && not( options[:controller] < ApplicationAdminController )
		true
	end

end

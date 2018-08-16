class MemberRole < ApplicationRole

	def authorize( target, options = {} )
		raise ActionController::MethodNotAllowed.new('Not Allowed') if options[:controller].blank? || options[:controller] < ApplicationAdminController
		true
	end

end

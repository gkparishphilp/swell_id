class GuestRole < ApplicationRole

	def authorize( target, options = {} )
		raise ActionController::MethodNotAllowed.new('Not Allowed')
	end

end

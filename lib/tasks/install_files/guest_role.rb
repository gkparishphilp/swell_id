class GuestRole < ApplicationRole

	def authorize( target, options = {} )
		not_allowed!
	end

end

class AdminRole < ApplicationRole

	def authorize( target, options = {} )
		true
	end

end

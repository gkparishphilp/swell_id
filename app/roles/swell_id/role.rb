module SwellId
	class Role
		attr_accessor :current_user

		def initialize( options = {} )
			@current_user = options[:current_user]
		end

		def authorize( target, options = {} )
			raise Exception.new('Not implemented')
		end

		protected
			def not_allowed!( options = {} )
				raise ActionController::MethodNotAllowed.new( options[:message] || 'Not Allowed' )
			end

	end
end

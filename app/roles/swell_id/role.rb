module SwellId
	class Role

		def authorize( target, options = {} )
			raise Exception.new('Not implemented')
		end

		protected
			def not_allowed!( options = {} )
				raise ActionController::MethodNotAllowed.new( options[:message] || 'Not Allowed' )
			end

	end
end

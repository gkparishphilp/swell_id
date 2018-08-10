module SwellId
	module Concerns

		module PermissionConcern
			extend ActiveSupport::Concern
			included do		

			end


			####################################################
			# Class Methods

			module ClassMethods

			end


			####################################################
			# Instance Methods
			protected

				def authorize( target, opts={} )
					# todo
					opts[:action] ||= self.action_name
					opts[:controller] ||= self.controller_name
					# ToDO

				end



		end

	end
end
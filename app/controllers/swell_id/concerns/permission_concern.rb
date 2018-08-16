module SwellId
	module Concerns

		module PermissionConcern
			extend ActiveSupport::Concern
			included do
				helper_method :authorized?
			end


			####################################################
			# Class Methods

			module ClassMethods

			end


			####################################################
			# Instance Methods
			protected

				def authorized?( target, opts={} )
					begin
						return authorize( target, opts )
					rescue ActionController::MethodNotAllowed => e
						return false
					end
				end

				def authorize( target, opts={} )

					opts[:action] ||= self.action_name
					opts[:controller] ||= "#{self.controller_path}_controller".camelcase.constantize

					if current_user.present?
						@current_user_role ||= "#{current_user.role}_role".camelcase.constantize.new
					else
						@current_user_role ||= GuestRole.new
					end

					@current_user_role.authorize( target, opts )

				end



		end

	end
end

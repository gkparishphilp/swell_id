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
					opts[:controller] ||= self.class
					# ToDO

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

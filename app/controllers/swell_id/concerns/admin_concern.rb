module SwellId
	module Concerns

		module AdminConcern
			extend ActiveSupport::Concern
			included do		
				before_action :authenticate_user!, :authorize_admin
				layout 'admin'
			end


			####################################################
			# Class Methods

			module ClassMethods

			end


			####################################################
			# Instance Methods
			protected
				def log_action_event
					# do not log admin events
				end

				def authorize_admin
					unless( current_user.present? && ( current_user.admin? || current_user.contributor? ) )
						redirect_to '/'
						return false
					end
				end

		end

	end
end
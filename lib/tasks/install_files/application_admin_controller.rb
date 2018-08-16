class ApplicationAdminController < ApplicationController

	include SwellId::Concerns::PermissionConcern

	layout 'admin'

	before_action :authenticate_user!, :require_role



	protected

		def require_role
			unless( current_user.present? && ( User.roles[current_user.role] > 1 ) )
				redirect_to '/'
				return false
			end
		end





end

class ContributorRole < ApplicationRole

	def authorize( target, options = {} )
		not_allowed! unless options[:controller].present? && not( options[:controller] < ApplicationAdminController )
		true
	end

end

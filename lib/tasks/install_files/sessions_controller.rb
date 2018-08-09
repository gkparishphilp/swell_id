class SessionsController < Devise::SessionsController
	

	def create
		self.resource = warden.authenticate!( auth_options )
		
		sign_in( resource_name, resource )
		
		redirect_to after_sign_in_path_for( resource )

	end

	def new
		super
	end

end
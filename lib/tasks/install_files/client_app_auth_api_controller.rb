
class ClientAppAuthApiController < ApplicationController


	def new
		auth_params = params.permit(:client_id,:permissions)
		client = ClientApp.find_by( client_id: auth_params[:client_id] )
	end

	def create
		auth_params = params.permit(:email,:password,:client_id,:redirect_uri,:permissions)
		client = ClientApp.find_by( client_id: auth_params[:client_id] )
		user = User.find_by( email: auth_params[:email], password: auth_params[:password] )

		if user.present? && client.present? && client.authorized_redirect_uris.include?( auth_params[:redirect_uri] )
			token = client.encode( { uid: user.id, role: user.role, perms: auth_params[:permissions] } )

			url = Addressable::URI.parse( auth_params[:redirect_uri] )
			url.query_values['token'] = token

			redirect_to url.to_s
		else

		end
	end

	def show
		auth_params = params.permit(:client_id,:token)
		client = ClientApp.find_by( client_id: auth_params[:client_id] )
		payload = client.decode( auth_params[:client_id] )
		payload = nil if payload.present? && payload[:exp].to_i > Time.now.to_i

		if payload.present?
			user = User.find payload[:uid]

			res = {
				status: 200,
				message: 'ok',
				name: user.name,
				email: user.email,
				client_id: client.client_id,
				role: user.role,
				expires: payload[:exp],
				permissions: payload[:perms],
			}
		else
			res = {
				status: 400,
				message: 'Unauthorized',
			}
		end


	end


end

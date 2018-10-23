module SwellId
	module Concerns

		module ApplicationControllerConcern
			extend ActiveSupport::Concern

			included do
				helper SwellId::ApplicationHelper
			end


			####################################################
			# Class Methods

			module ClassMethods

			end


			####################################################
			# Instance Methods


			protected

				def client_ip
					request.headers['CF-Connecting-IP'] || request.remote_ip
				end

				def client_ip_country
					request.headers['CF-IPCountry']
				end

				def register_then

					if params[:register_then].present?

						user_params = params.require(:register_then).permit( :email, :full_name, :username )

						user = User.where( email: user_params[:email] ).first
						user ||= User.new( user_params.merge(ip: request.ip) )

						if user.encrypted_password.present?
							# this email is already registered for this site
							set_flash "#{user.email} is already registered. Try <a href='/forgot'>Forgot Password</a>.", :error
							redirect_back( fallback_location: '/register' )
							return false
						end

						user.password = params[:register_then].require(:password)

						if user.save
							sign_in( :user, user )
						else
							set_flash "Could not register user.", :error, user
							redirect_back( fallback_location: '/register' )
							return false
						end

						log_event( { name: 'register', content: 'registered.' } )

					end

				end

		end
	end
end

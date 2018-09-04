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

		end
	end
end

require 'jwt'
# gem 'jwt'

class ClientApp < ApplicationRecord
	include SwellId::Concerns::ClientAppConcern
	before_save :set_client_id

	enum status: { 'trash' => -50, 'revoked' =>- 20, 'active' => 1  }

	# name
	# status
	# domain
	# authorized_javascript_uris[]
	# authorized_redirect_uris[]
	# client_id # e.g. 453291191205-hs5uj0unhrendbt0e5ohf9dq52nonst7.apps.googleusercontent.com
	# client_secret
	# created_at

	def generate_client_id
		"#{created_at.to_i}-#{SecureRandom.uuid.gsub(/\-/,'')}.apps.#{domain}"
	end


	def encode(payload, exp = 24.hours.from_now)
		payload[:exp] = exp.to_i
		JWT.encode(payload, client_secret1)
	end

	def decode(token)
		body = JWT.decode(token, client_secret1)[0]
		HashWithIndifferentAccess.new body
	rescue
		nil
	end

	def set_client_id
		client_id ||= generate_client_id()
	end
end

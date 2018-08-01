module SwellId
	module Concerns

		module UserConcern
			extend ActiveSupport::Concern

			included do
				#has_many	:oauth_credentials, dependent: :destroy, class_name: SwellMedia::OauthCredential.name
				validates :email, presence: true
			end


			####################################################
			# Class Methods

			module ClassMethods

				def get_last
					"screw you"
				end

			end


			####################################################
			# Insrtance Methods
			def say_hi
				"Hello there!"
			end

		end

	end
end
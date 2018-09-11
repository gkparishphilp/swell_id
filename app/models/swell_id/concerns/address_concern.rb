module SwellId
	module Concerns

		module AddressConcern
			extend ActiveSupport::Concern

			included do
				before_save :set_hash_code
				acts_as_taggable_array_on :tags
			end


			####################################################
			# Class Methods

			module ClassMethods



			end


			####################################################
			# Instance Methods

			def calculate_hash_code
				self.class.calculate_hash_code( self )
			end

			def self.calculate_hash_code( geo_address )
				parts = [
					geo_address.street,
					geo_address.street2,
					geo_address.zip,
					geo_address.city,
					geo_address.state_abbrev,
					geo_address.geo_country.abbrev,
				]
				parts.collect{|part| (part || '').downcase.gsub(/[^A-Za-z0-9]/,'') }.join(';')
			end

			def full_name
				"#{self.first_name} #{self.last_name}".strip
			end

			def self.with_same_user
				self.where( user: self.user )
			end

			def state_name
				[ self.state, self.geo_state.try(:name) ].select{|str| not( str.blank? ) }.first
			end

			def state_abbrev
				[ self.state, self.geo_state.try(:abbrev) ].select{|str| not( str.blank? ) }.first
			end

			def to_html
				addr = "#{self.full_name}<br>#{self.street}"
				addr = addr + "<br>#{self.street2}" if self.street2.present?
				addr = addr + "<br>#{self.city}, #{self.state_abbrev} #{self.zip}"
				addr = addr + "<br>#{self.geo_country.try(:name)}"
				return addr
			end

			def self.with_same_hash_code
				self.where( hash_code: calculate_hash_code )
			end


			protected

				def set_hash_code
					hash_code = calculate_hash_code
				end



		end

	end
end

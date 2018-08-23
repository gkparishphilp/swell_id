module SwellId
	module Concerns

		module AddressConcern
			extend ActiveSupport::Concern

			included do		
				
				acts_as_taggable_array_on :tags
			end


			####################################################
			# Class Methods

			module ClassMethods



			end


			####################################################
			# Instance Methods

			def full_name
				"#{self.first_name} #{self.last_name}".strip
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


			protected

				def hash!
					str = "#{self.street}#{self.street2}#{self.city}#{self.state_abbrev}#{self.zip}"
					str = str.gsub( /\W/, '' ).downcase
					self.update( hash_code: str )
				end

		end

	end
end
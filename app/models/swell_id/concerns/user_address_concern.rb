module SwellId
	module Concerns

		module UserAddressConcern
			extend ActiveSupport::Concern

			included do
				belongs_to	:geo_address
				belongs_to 	:user

				before_save :canonical_geo_address!

				delegate :geo_state, to: :geo_address, allow_nil: true, prefix: false
				delegate :geo_state=, to: :geo_address, prefix: false
				delegate :geo_state_id, to: :geo_address, allow_nil: true, prefix: false
				delegate :geo_state_id=, to: :geo_address, prefix: false
				delegate :geo_country, to: :geo_address, allow_nil: true, prefix: false
				delegate :geo_country=, to: :geo_address, prefix: false
				delegate :geo_country_id, to: :geo_address, allow_nil: true, prefix: false
				delegate :geo_country_id=, to: :geo_address, prefix: false
				delegate :street, to: :geo_address, allow_nil: true, prefix: false
				delegate :street=, to: :geo_address, prefix: false
				delegate :street2, to: :geo_address, allow_nil: true, prefix: false
				delegate :street2=, to: :geo_address, prefix: false
				delegate :city, to: :geo_address, allow_nil: true, prefix: false
				delegate :city=, to: :geo_address, prefix: false
				delegate :state, to: :geo_address, allow_nil: true, prefix: false
				delegate :state=, to: :geo_address, prefix: false
				delegate :state_abbrev, to: :geo_address, allow_nil: true, prefix: false
				delegate :state_abbrev=, to: :geo_address, prefix: false
				delegate :zip, to: :geo_address, allow_nil: true, prefix: false
				delegate :zip=, to: :geo_address, prefix: false

				accepts_nested_attributes_for :geo_address
			end


			####################################################
			# Class Methods

			module ClassMethods

				def canonical
					UserAddress.unscoped.where( id: self.joins(:geo_address).group('geo_addresses.hash_code',:user_id,"lower(user_addresses.first_name)","lower(user_addresses.last_name)","lower(user_addresses.phone)").select("MIN(user_addresses.id)") )
				end

				def canonical_find_or_new_with_cannonical_geo_address( attributes )
					user_address = self.new_with_cannonical_geo_address( attributes )
					user_address = user_address.canonical_find_or_self
					user_address
				end

				def canonical_find_or_create_with_cannonical_geo_address( attributes )
					user_address = self.new_with_cannonical_geo_address( attributes )
					user_address = user_address.canonical_find_or_self
					user_address.save
					user_address
				end

				def create_with_cannonical_geo_address( attributes )
					user_address = self.new_with_cannonical_geo_address( attributes )
					user_address.save
					user_address
				end

				def new_with_geo_address( attributes )
					user_address = UserAddress.new( geo_address: GeoAddress.new )
					user_address.attributes = attributes
					user_address
				end

				def new_with_cannonical_geo_address( attributes )
					user_address = UserAddress.new( geo_address: GeoAddress.new )
					user_address.attributes = attributes
					user_address.canonical_geo_address!
					user_address
				end

			end


			####################################################
			# Instance Methods

			def canonical_find
				user_address = nil

				canonical_geo_address = self.geo_address.canonical_find

				if canonical_geo_address.present? && self.user.present?
					user_address = UserAddress.unscoped.where(
						geo_address:		canonical_geo_address,
						user:						self.user,
						first_name:			self.first_name,
						last_name:			self.last_name,
						phone:					self.phone,
						address_type:		self.address_type,
					).first
				end

				user_address
			end

			def canonical_find_or_self
				canonical_find || self
			end

			def canonical_geo_address!
				self.geo_address = self.geo_address.canonical_find || self.geo_address
			end

			def full_name
				"#{self.first_name} #{self.last_name}".strip
			end

			def to_html
				addr = "#{self.full_name}<br>#{self.street}"
				addr = addr + "<br>#{self.street2}" if self.street2.present?
				addr = addr + "<br>#{self.city}, #{self.state_abbrev} #{self.zip}"
				addr = addr + "<br>#{self.geo_country.try(:name)}"
				return addr
			end

			def to_s
				"#{street}#{street2.present? ? ", #{street2}" : ""}, #{city}, #{state_abbrev}, #{zip}, #{country_abbrev}"
			end

		end

	end
end


class GeoAddress < ApplicationRecord

	include SwellId::Concerns::AddressConcern

	enum status: { 'active' => 1, 'trash' => -50 }

	belongs_to	:geo_state, required: false
	belongs_to	:geo_country
	belongs_to 	:user, required: false

	validates	:first_name, presence: true, allow_blank: false
	validates	:last_name, presence: true, allow_blank: false
	validates	:street, presence: true, allow_blank: false
	validates	:city, presence: true, allow_blank: false
	validates	:zip, presence: true, allow_blank: false


end

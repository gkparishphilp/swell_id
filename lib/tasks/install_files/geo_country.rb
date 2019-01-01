class GeoCountry < ApplicationRecord
	include GeoCountrySearchable if (GeoCountrySearchable rescue nil)

	has_many :geo_states

end

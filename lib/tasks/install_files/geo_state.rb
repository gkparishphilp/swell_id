class GeoState < ApplicationRecord
	include GeoStateSearchable if (GeoStateSearchable rescue nil)

	belongs_to :geo_country

end

module GeoAddressSearchable
	extend ActiveSupport::Concern

	included do
		include Searchable

		settings index: { number_of_shards: 1 } do
			mappings dynamic: 'false' do
				indexes :id, type: 'integer'
				indexes :created_at, type: 'date'
				indexes :first_name, analyzer: 'english', index_options: 'offsets'
				indexes :last_name, analyzer: 'english', index_options: 'offsets'
				indexes :zip, analyzer: 'english', index_options: 'offsets'
				indexes :phone, analyzer: 'english', index_options: 'offsets'
				indexes :street, analyzer: 'english', index_options: 'offsets'
				indexes :street2, analyzer: 'english', index_options: 'offsets'
				indexes :state_name, analyzer: 'english', index_options: 'offsets'
				indexes :state_abbrev, analyzer: 'english', index_options: 'offsets'
				indexes :country_name, analyzer: 'english', index_options: 'offsets'
				indexes :country_abbrev, analyzer: 'english', index_options: 'offsets'
			end
		end
	end

	module ClassMethods
		# def class_method_name ... end
	end

	# Instance Methods
	# def instance_method_name ... end
	def country_abbrev
		geo_country.abbrev
	end

	def country_name
		geo_country.name
	end

	def full_text
		[
			self.first_name,
			self.last_name,
			self.zip,
			self.phone,
			self.street,
			self.street2,
			self.state_name,
			self.state_abbrev,
			self.country_name,
			self.country_abbrev,
		].join("\n")
	end

end

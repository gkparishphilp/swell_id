module UserSearchable
	extend ActiveSupport::Concern

	included do
		include Searchable

		settings index: { number_of_shards: 1 } do
			mappings dynamic: 'false' do
				indexes :id, type: 'integer'
				indexes :created_at, type: 'date'
				indexes :username, analyzer: 'english', index_options: 'offsets'
				indexes :email, analyzer: 'english', index_options: 'offsets'
				indexes :full_name, analyzer: 'english', index_options: 'offsets'
				indexes :first_name, analyzer: 'english', index_options: 'offsets'
				indexes :last_name, analyzer: 'english', index_options: 'offsets'
				indexes :description, analyzer: 'english', index_options: 'offsets'
				indexes :bio, analyzer: 'english', index_options: 'offsets'
				indexes :full_text, analyzer: 'english', index_options: 'offsets'
				indexes :published?, type: 'boolean'
			end
		end
	end

	module ClassMethods
		# def class_method_name ... end
	end

	# Instance Methods
	# def instance_method_name ... end
	def as_indexed_json(options={})
		as_json().merge( 'full_text' => full_text )
	end

	def full_text
		[
			self.username,
			self.full_name,
			self.last_name,
			self.email,
		].append( self.geo_addresses.collect(&:full_text) ).join("\n")
	end

end

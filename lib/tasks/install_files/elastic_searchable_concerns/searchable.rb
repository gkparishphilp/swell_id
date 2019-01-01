module Searchable
	extend ActiveSupport::Concern

	class SearchableResult
		attr_accessor :result

		def initialize( result )
			self.result = result
		end

		def count
			result.count
		end

		def current_page
			result.current_page
		end

		def method_missing(name, *args, &block)
			records.method(name).call(*args)
		end

		def page( p )
			SearchableResult.new( result.page( p ) )
		end

		def per(p)
			SearchableResult.new( result.per( p ) )
		end

		def next_page
			result.next_page
		end

		def records
			return @records unless @records.nil?
			@records = self.result.records.to_a
			self.result.each do |row|
				record = @records.find { |r| r.__elasticsearch__.index_name.to_s == row._index.to_s && r.id.to_s == row.id.to_s }
				record.searchable_score = row._score
				record.searchable_highlight = row.highlight if row.respond_to?(:highlight)
				record.searchable_meta = row
			end

			@records
		end

		def total_count
			result.total_count
		end

		def total_pages
			result.total_pages
		end

	end

	included do

		include Elasticsearch::Model
		include Elasticsearch::Model::Callbacks
		include Elasticsearch::Model::Indexing

		after_create :elastic_search_create
		after_update :elastic_search_update

		attr_accessor :searchable_score
		attr_accessor :searchable_highlight
		attr_accessor :searchable_meta
	end

	def self.search( term, options=nil )
		options ||= [Bazaar::Product, Bazaar::SubscriptionPlan,User]
		SearchableResult.new( Elasticsearch::Model.search( term, options ) )
	end

	module ClassMethods
		def search( term, options = nil )
			if options.nil?
				result = self.__elasticsearch__.search term
			else
				result = self.__elasticsearch__.search term, options
			end
			SearchableResult.new( result )
		end

		def drop_create_index!( args = { import: true } )
			self.__elasticsearch__.client.indices.delete index: self.index_name rescue nil
			self.__elasticsearch__.client.indices.create \
			  index: self.index_name,
			  body: { settings: self.settings.to_hash, mappings: self.mappings.to_hash }
			self.import if args[:import]
		end
	end


	def elastic_search_create
		self.__elasticsearch__.index_document
	end

	def elastic_search_update
		self.__elasticsearch__.index_document rescue self.__elasticsearch__.update_document
	end

end

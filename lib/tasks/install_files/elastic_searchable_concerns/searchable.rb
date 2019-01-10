# Install instructions:
# 1) Add the following gems to your Gemfile:
# => gem 'kaminari' # if you are using will_paginate or kaminari include it before elastic search
# => gem 'bonsai-elasticsearch-rails', '~> 6'
# => gem 'elasticsearch-model', github: 'elastic/elasticsearch-rails', branch: '6.x'
# => gem 'elasticsearch-rails', github: 'elastic/elasticsearch-rails', branch: '6.x'
# 2) Install or create Searchable Concerns in app/models/concerns to have them be applied to engine models
# 3) Update the seachable classes method to include all classes you have included searchable concerns in.

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

		def each(&block)
			records.each( &block )
		end

		def limit_value
			result.limit_value
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
				record = @records.find { |r| r.class.base_class.__elasticsearch__.index_name.to_s == row._index.to_s && r.id.to_s == row.id.to_s }
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

	def self.public_simple_search( term, options = {} )
		options[:in] ||= [Pulitzer::Media,BazaarMedia]
		options[:class_boosts] ||= { BazaarMedia.name => 100 }
		options[:where] ||= {}
		options[:where][:public] = true

		simple_search( term, options )
	end

	def self.search( query, options = {} )
		options[:in] = searchable_classes if options[:in] == :all
		puts JSON.pretty_generate( { query: query, options: options } ) if Rails.env.development?
		SearchableResult.new( Elasticsearch::Model.search( query, options[:in] ) )
	end

	def self.simple_search( term, options = {} )
		filters = []
		(options.delete(:where) || {}).each do |key,value|
			filters << { term: { key => value }, }
		end

		indices_boost = {}
		(options.delete(:class_boosts) || {}).each do |class_name,boost|
			indices_boost[class_name.constantize.index_name] = boost
		end

		query = {
			query: {
				bool: {
					must: {
						simple_query_string: { query: term },
					},
				},
			},
		}

		query[:indices_boost] = indices_boost if indices_boost.present?
		query[:query][:bool][:filter] = filters if filters.present?

		search( query, options )
	end

	def self.searchable_classes
		[] # [Bazaar::Discount,Bazaar::Order,Bazaar::Product,Bazaar::SubscriptionPlan,Bazaar::Subscription,Pulitzer::Media,Scuttlebutt::DiscussionTopic,BazaarMedia,GeoAddress,User]
	end

	module ClassMethods

		def public_simple_search( term, options = {} )
			options[:in] = [self]
			Searchable.public_simple_search( term, options )
		end

		def search( query, options = {} )
			options[:in] = [self]
			Searchable.search( query, options )
		end

		def simple_search( term, options = {} )
			options[:in] = [self]
			Searchable.simple_search( term, options )
		end

		def drop_create_index!( args = { import: true } )
			self.__elasticsearch__.client.indices.delete index: self.index_name rescue nil
			self.__elasticsearch__.client.indices.create \
			  index: self.index_name,
			  body: { settings: self.settings.to_hash, mappings: self.mappings.to_hash }
			self.import if args[:import]
		end
	end


	def as_json(options = nil)
		super(options).merge( 'public' => false )
	end

	def elastic_search_create
		self.__elasticsearch__.index_document
	end

	def elastic_search_update
		self.__elasticsearch__.index_document rescue self.__elasticsearch__.update_document
	end

end

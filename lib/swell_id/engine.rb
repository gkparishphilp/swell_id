
# required gems from gemspec
require 'acts-as-taggable-array-on'
require 'devise'
require 'friendly_id'

module SwellId
	
	class << self

		# engine configuration settings accessors

		mattr_accessor :default_user_status

		# settings defaults

		self.default_user_status = 'pending'

	end

	# this function maps the vars from your app into the engine
     def self.configure( &block )
        yield self
     end


	class Engine < ::Rails::Engine
		isolate_namespace SwellId
	end
end

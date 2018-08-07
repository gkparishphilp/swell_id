module SwellId
	module Concerns

		module IdentifierConcern
			extend ActiveSupport::Concern

			included do		
				belongs_to :parent_obj, polymorphic: true
			end


			####################################################
			# Class Methods

			module ClassMethods


			end


			####################################################
			# Instance Methods

		

		end

	end
end
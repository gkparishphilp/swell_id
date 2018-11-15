module SwellId
	module Concerns

		module MultiIdentifierConcern
			extend ActiveSupport::Concern

			included do
				has_many :identifers, as: :parent_obj
			end

			####################################################
			# Class Methods

			module ClassMethods

				def find_by_identifier( identifier, args = {} )
					self.joins(:identifiers).merge(Identifier.where( args.merge( identifier: identifier ) ))
				end

			end


			####################################################
			# Instance Methods



		end

	end
end

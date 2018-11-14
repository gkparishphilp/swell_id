module SwellId
	module Concerns

		module IdentifierConcern
			extend ActiveSupport::Concern

			included do
				belongs_to :parent_obj, polymorphic: true, required: false

				validates :identifier, presence: true
				validates :provider, presence: true
				validates :label, presence: true
				validates_uniqueness_of :identifier, scope: [:provider,:label]
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

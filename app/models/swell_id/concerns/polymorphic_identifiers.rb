module SwellId
	module Concerns

		module PolymorphicIdentifiers
			extend ActiveSupport::Concern

			included do

			end


			####################################################
			# Class Methods

			module ClassMethods

				def find_by_polymorphic_id( polymorphic_id )

					value_type, value_id = self.parse_polymorphic_id( polymorphic_id )

					value_type.constantize.find_by( id: value_id )

				end

				def build_polymorphic_id( model )
					return nil if model.nil?
					"#{model.class.base_class.name.underscore}/#{model.id}"
				end

				def parse_polymorphic_id( value )

					unless value.nil?
						value_parts = value.split('/')
						value_id = value_parts.pop
						value_type = value_parts.join('/').camelize

						item_type	= value_type
						item_id		= value_id
					end

					[ item_type, item_id ]
				end

				def belongs_to(name, scope = nil, **options)
					if (scope.is_a?( Hash ) && scope[:polymorphic]) || (options.is_a?( Hash ) && options[:polymorphic])

						define_method "#{name}_polymorphic_id" do
							self.class.build_polymorphic_id( self.try(name) )
						end

						define_method "#{name}_polymorphic_id=" do |value|
							value_type, value_id = self.class.parse_polymorphic_id( value )

							self.try( "#{name}_type=", value_type )
							self.try( "#{name}_id=", value_id )
						end


						if options.present?
							super( name, scope, &options )
						else
							super( name, scope )
						end
					elsif options.present?
						super( name, scope, &options )
					else
						super( name, scope )
					end
				end

			end

			def polymorphic_id
				self.class.build_polymorphic_id( self )
			end


		end
	end
end

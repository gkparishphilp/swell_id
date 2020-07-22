module SwellId

	class IdentifierAdminController < ApplicationAdminController

		before_action :get_model, except: [:index, :new, :create]

		def create

			identifier = Identifier.new( identifier_params )

			authorize( identifier )

			if identifier.save
				set_flash "Identifier added"
				if params[:redirect_to]
					redirect_to params[:redirect_to]
				else
					redirect_to edit_identifier_admin_path( identifier )
				end
			else
				set_flash "Could not add identifier.", :error, identifier

				if params[:redirect_to]
					redirect_to params[:redirect_to]
				else
					redirect_back fallback_location: '/admin'
				end
				return false
			end
		end


		def destroy
			authorize( @identifier, action: :admin_destroy )
			@identifier.destroy
			set_flash "#{@identifier} deleted"
			redirect_to '/identifier_admin'
		end


		def edit
			authorize( @identifier )
		end


		def index

			authorize( Identifier )

			sort_by = params[:sort_by] || 'created_at'
			sort_dir = params[:sort_dir] || 'desc'

			@identifiers = Identifier.order( "#{sort_by} #{sort_dir}" )


			( params[:filters] || [] ).each do |key, value|

				@identifiers = @identifiers.where( key => value ) unless value.blank?

			end

			if params[:q].present?
				@identifiers = @identifiers.where( "provider ilike :q OR label ilike :q OR identifier ilike :q", q: "%#{params[:q]}%" )
			end

			@identifiers = @identifiers.page( params[:page] )

		end

		def new
			@identifier = Identifier.new( identifier_params )

			authorize( @identifier )
		end

		def update
			@identifier.attributes = identifier_params

			authorize( @identifier )

			if @identifier.save
				set_flash "#{@identifier} updated"
			else
				set_flash "Could not save", :danger, @identifier
			end
			redirect_back( fallback_location: '/admin' )
		end



		private
			def get_model
				@identifier = Identifier.find( params[:id] )
			end

			def identifier_params
				params.require( :identifier ).permit( :parent_obj_type, :parent_obj_id, :provider, :label, :identifier )
			end

	end

end

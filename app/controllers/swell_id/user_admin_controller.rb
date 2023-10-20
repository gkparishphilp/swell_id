module SwellId

	class UserAdminController < ApplicationAdminController

		def create

			email = params[:user][:email]

			user_attributes = { email: email, username: params[:user][:username].try(:parameterize), ip: request.ip }

			if User.where( email: email ).first.present?
				# this email is already registered for this site
				set_flash "#{email} is already registered.", :error
				redirect_to :back
				return false
			end

			# pw = PasswordGeneratorService.new.generate()
			pw = "P#{SecureRandom.hex(4)}"

			user = User.new( user_attributes )
			user.password = pw
			user.password_confirmation = pw

			authorize( user )

			if user.save
				set_flash "User added"
	        	redirect_to edit_user_admin_path( user, pw: pw )
			else
				set_flash "Could not add user.", :error, user
				redirect_to :back
				return false
			end
		end


		def destroy
			@user = User.friendly.find( params[:id] )

			authorize( @user, :admin_destroy )
			@user.destroy
			set_flash "#{@user} deleted"
			redirect_to '/user_admin'
		end


		def edit
			@user = User.friendly.find( params[:id] )

			authorize( @user )

			# @user_events = SwellMedia::UserEvent.where( guest_session_id: SwellMedia::GuestSession.where( user_id: @user.id ).pluck( :id ) ).order( created_at: :asc ).page(params[:page]).per(50)

		end


		def index

			authorize( User )

			sort_by = params[:sort_by] || 'created_at'
			sort_dir = params[:sort_dir] || 'desc'

			@users = User.order( Arel.sql("#{sort_by} #{sort_dir}") )


			( params[:filters] || [] ).each do |key, value|

				@users = @users.where( key => value ) unless value.blank?

			end

			if params[:q].present?
				@users = @users.where( "name like :q OR first_name like :q OR last_name like :q OR email like :q", q: "%#{params[:q]}%" )
			end

			@users = @users.page( params[:page] )

		end

		def update
			@user = User.friendly.find( params[:id] )

			@user.attributes = user_params

			authorize( @user )

			if @user.save
				set_flash "#{@user} updated"
			else
				set_flash "Could not save", :danger, @user
			end
			redirect_back( fallback_location: '/admin' )
		end




		private
			def user_params
				params.require( :user ).permit( :username, :first_name, :last_name, :email, :short_bio, :bio, :shipping_name, :street, :street2, :city, :state, :zip, :phone, :role, :status, :tags_csv, :avatar_attachment )
			end

	end

end

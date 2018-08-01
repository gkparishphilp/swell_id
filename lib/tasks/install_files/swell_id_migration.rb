class SwellIdMigration < ActiveRecord::Migration[5.1]

	def change

		enable_extension 'hstore'
		enable_extension 'uuid-ossp'


		create_table :emails, force: true do |t|
			t.references 		:user_id
			t.string			:address
			t.integer 			:status, default: 0
			t.string			:first_name
			t.string			:last_name
			t.hstore			:properties, default: {}
			t.timestamps
		end
		add_index :emails, [:address, :status]
		add_index :emails, :status
		add_index :emails, :address, unique: true


		create_table :friendly_id_slugs do |t|
			t.string   :slug, 				null: false
			t.integer  :sluggable_id, 		null: false
			t.string   :sluggable_type,		limit: 50
			t.string   :scope
			t.datetime :created_at
		end
		add_index :friendly_id_slugs, :sluggable_id
		add_index :friendly_id_slugs, [:slug, :sluggable_type]
		add_index :friendly_id_slugs, [:slug, :sluggable_type, :scope], unique: true
		add_index :friendly_id_slugs, :sluggable_type


		create_table :oauth_credentials do |t|
			t.references	:user
			t.string		:name
			t.string		:provider
			t.string		:uid
			t.string		:token
			t.string		:refresh_token
			t.string		:secret
			t.datetime		:expires_at
			t.integer		:status,		default: 1
			t.timestamps
		end
		add_index :oauth_credentials, :provider
		add_index :oauth_credentials, :uid
		add_index :oauth_credentials, :token
		add_index :oauth_credentials, :secret


		create_table :users do |t|
			t.string		:name
			## Database authenticatable
			t.string		:email,					null: false, default: ""
			t.string		:encrypted_password,	null: false, default: ""

			t.string 		:slug
			t.string 		:first_name
			t.string 		:last_name
			t.string 		:avatar
			t.string		:cover_image
			t.datetime 		:dob
			t.string		:gender
			t.string		:location
			t.string		:address1
			t.string		:address2
			t.string		:city
			t.string		:state
			t.string		:zip
			t.string		:phone
			t.integer		:status,				default: 1
			t.integer		:role,					default: 1
			t.integer		:level,					default: 1

			t.string 		:website_url
			t.text 			:bio
			t.string		:short_bio
			t.text 			:sig
			t.string		:ip
			t.float			:latitude
			t.float 		:longitude
			t.string		:timezone, default: 'Pacific Time (US & Canada)'

			## Recoverable
			t.string		:reset_password_token
			t.datetime		:reset_password_sent_at

			t.string		:password_hint
			t.string		:password_hint_response

			## Rememberable
			t.datetime		:remember_created_at

			## Trackable
			t.integer		:sign_in_count, :default => 0
			t.datetime		:current_sign_in_at
			t.datetime		:last_sign_in_at
			t.string		:current_sign_in_ip
			t.string		:last_sign_in_ip

			## Confirmable
			t.string		:confirmation_token
			t.datetime		:confirmed_at
			t.datetime		:confirmation_sent_at
			t.string		:unconfirmed_email # Only if using reconfirmable

			## Lockable
			t.integer		:failed_attempts, 		default: 0 # Only if lock strategy is :failed_attempts
			t.string		:unlock_token # Only if unlock strategy is :email or :both
			t.datetime		:locked_at

			## Token authenticatable
			t.string		:authentication_token

			t.string 		:tags, array: true, default: '{}'
			t.hstore		:properties, default: {}
			t.hstore		:settings

			t.timestamps
		end
		add_index :users, :name
		add_index :users, :slug, 					unique: true
		add_index :users, :email,					unique: true
		add_index :users, :reset_password_token,	unique: true
		add_index :users, :confirmation_token,		unique: true
		add_index :users, :unlock_token,			unique: true
		add_index :users, :authentication_token,	unique: true

	end
end

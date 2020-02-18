# desc "Explaining what the task does"
namespace :swell_id do
	task :install do
		puts "Installing Swell ID. Who goes there?"

		files = {
					'user.rb' => 'app/models',
					'geo_address.rb' => 'app/models',
					'geo_state.rb' => 'app/models',
					'geo_country.rb' => 'app/models',
					'user_address.rb' => 'app/models',
					'sessions_controller.rb' => 'app/controllers',
					'application_admin_controller.rb' => 'app/controllers',
					'swell_id.rb' => 'config/initializers',
					'routes.rb' => 'config',
					'devise.rb' => 'config/initializers',
					'application_role.rb' => 'app/roles',
					'admin_role.rb' => 'app/roles',
					'contributor_role.rb' => 'app/roles',
					'guest_role.rb' => 'app/roles',
					'member_role.rb' => 'app/roles',
					'application_service.rb' => 'app/services',
					'database.yml' => 'config'
		}


		FileUtils::mkdir_p( File.join( Rails.root, 'app/roles' ) )
		FileUtils::mkdir_p( File.join( Rails.root, 'app/services' ) )

		files.each do |filename, path|
			puts "installing: #{path}/#{filename}"

			source = File.join( Gem.loaded_specs["swell_id"].full_gem_path, "lib/tasks/install_files", filename )
    		if path == :root
    			target = File.join( Rails.root, filename )
    		else
    			target = File.join( Rails.root, path, filename )
    		end
    		FileUtils.cp_r source, target
		end

		dir = FileUtils::mkdir_p( File.join( Rails.root, 'app/views/devise/sessions/' ) )
		source = File.join( Gem.loaded_specs["swell_id"].full_gem_path, "lib/tasks/install_files", 'sessions_new.html.haml' )
		target = File.join( Rails.root, 'app/views/devise/sessions/', 'new.html.haml' )
		FileUtils.cp_r source, target

		# migrations

		FileUtils::mkdir_p( File.join( Rails.root, 'db/migrate/' ) )


		migrations = [
			'swell_id_migration.rb',
		]

		prefix = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i

		migrations.each do |filename|

			puts "installing: db/migrate/#{prefix}_#{filename}"

			source = File.join( Gem.loaded_specs["swell_id"].full_gem_path, "lib/tasks/install_files", filename )

    		target = File.join( Rails.root, 'db/migrate', "#{prefix}_#{filename}" )

    		FileUtils.cp_r source, target
    		prefix += 1
		end

	end

end

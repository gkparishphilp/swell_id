module SwellId
	module Concerns

		module UserConcern
			extend ActiveSupport::Concern

			included do

				acts_as_taggable_array_on :tags

				devise 		:database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :authentication_keys => [:login]

				include FriendlyId
				friendly_id :slugger, use: :slugged

				attr_accessor	:login

			end


			####################################################
			# Class Methods

			module ClassMethods




			end


			####################################################
			# Instance Methods

			def avatar_tag( opts={} )
				tag = "<img src="
				tag += "'" + self.avatar + "' "
				for key, value in opts do
					tag += key.to_s + "='" + value.to_s + "' "
				end
				tag += "/>"
				return tag.html_safe

			end


			def email=(value)
				# super( SwellMedia::Email.email_sanitize( value ) )
				super( value.try(:downcase) )
			end

			def full_name
				if self.first_name.present? || self.last_name.present?
					"#{self.first_name} #{self.last_name}"
				else
					self.username
				end
			end

			def full_name=( name )
				unless name.nil?
					name_array = name.split( / / )
					self.first_name = name_array.shift
					self.last_name = name_array.join( ' ' )
				end
			end

			def slugger
				return self.username if self.username.present?
				return self.full_name unless self.full_name.blank?
				return self.email.split( /@/ ).first
			end

			def tags_csv
				self.tags.join(',')
			end

			def tags_csv=(tags_csv)
				self.tags = tags_csv.split( /,\s*/ )
			end


			def to_local_tz( t )
				return nil if t.nil?
				zone = self.timezone || 'America/Los_Angeles'
				t.in_time_zone( zone )
			end

			def to_s( args={} )
				if args[:username]
					str = self.username.try(:strip)
					str = 'Guest' if str.blank?
					return str
				else
					str = "#{self.first_name} #{self.last_name}".strip
					str = self.username.try(:strip) if str.blank?
					str = 'Guest' if str.blank?
					return str
				end
			end

			def registered?
				self.encrypted_password.present? # || self.oauth_credentials.present?    TODO if implementing oauth
			end

		end

	end
end

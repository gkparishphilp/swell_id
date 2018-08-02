module SwellId
	module Concerns

		module UserConcern
			extend ActiveSupport::Concern

			included do				
				include FriendlyId
				friendly_id :slugger, use: :slugged
				
				acts_as_taggable_array_on :tags

				attr_accessor	:login

			end


			####################################################
			# Class Methods

			module ClassMethods

				def find_for_database_authentication(warden_conditions)
					conditions = warden_conditions.dup
					if login = conditions.delete(:login)
						where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
					elsif conditions.has_key?(:username) || conditions.has_key?(:email)
						where(conditions.to_h).first
					end
				end

				def find_first_by_auth_conditions( warden_conditions )
					conditions = warden_conditions.dup
					if login = conditions.delete( :login )
						where( conditions ).where( ["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }] ).first
					else
						where( conditions ).first
					end
				end


			end


			####################################################
			# Instance Methods

			def avatar_tag( opts={} )
				tag = "<img src="
				tag += "'" + self.avatar_url( opts ) + "' "
				for key, value in opts do
					tag += key.to_s + "='" + value.to_s + "' "
				end
				tag += "/>"
				return tag.html_safe

			end

			def avatar_url( opts={} )
				# abstracts avatar path (uses gravatar if no avatar)
				# call as avatar_url( use_gravatar: true ) to over-ride avatar and force gravatar
				opts[:default] ||= 'identicon'
				protocol = ( opts.present? && opts.delete( :protocol ) ) || SwellMedia.default_protocol

				if opts[:use_gravatar] || self.avatar.blank?
					return "#{protocol}://gravatar.com/avatar/" + Digest::MD5.hexdigest( self.email ) + "?d=#{opts[:default]}"
				else
					return self.avatar.gsub(/^(https|http)\:/, "#{protocol}:")
				end
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

			def tags_csv
				self.tags.join(',')
			end

			def tags_csv=(tags_csv)
				self.tags = tags_csv.split( /,\s*/ )
			end


			def to_local_tz( t )
				return nil if t.nil?
				zone - self.timezone || 'America/Los_Angeles'
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
class User < ApplicationRecord

	include SwellId::Concerns::UserConcern

	enum status: { 'trash' => -50, 'revoked' =>- 20, 'active' => 1  }
	enum role: { 'member' => 1, 'contributor' => 20, 'admin' => 30 }

	devise 		:database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :authentication_keys => [:login]

	before_save		:set_avatar

	has_one_attached :avatar_attachment

	### VALIDATIONS	---------------------------------------------
	validates_uniqueness_of		:username, case_sensitive: false, allow_blank: true, if: Proc.new{ |u| u.username_changed? && u.registered? }
	validates_presence_of 		:email
	validates_uniqueness_of		:email, case_sensitive: false, if: :email_changed?
	validates_format_of			:email, with: Devise.email_regexp, if: :email_changed?

	validates_confirmation_of	:password, if: [ :encrypted_password_changed?, :registered? ]
	validates_length_of			:password, within: Devise.password_length, allow_blank: true, if: Proc.new{ |u| u.encrypted_password_changed? && u.registered? }


	def self.find_for_database_authentication(warden_conditions)
		conditions = warden_conditions.dup
		if login = conditions.delete(:login)
			where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
		elsif conditions.has_key?(:username) || conditions.has_key?(:email)
			where(conditions.to_h).first
		end
	end

	protected

		def set_avatar
			if self.avatar_attachment.attached?
				self.avatar = self.avatar_attachment.service_url
			else
				self.avatar = "https://gravatar.com/avatar/" + Digest::MD5.hexdigest( self.email ) + "?d=retro&s=200"
			end

		end

end

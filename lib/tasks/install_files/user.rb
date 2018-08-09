class User < ApplicationRecord

	include SwellId::Concerns::UserConcern

	enum status: { 'trash' => -50, 'revoked' =>- 20, 'active' => 1  }
	enum role: { 'member' => 1, 'contributor' => 20, 'admin' => 30 }


	### VALIDATIONS	---------------------------------------------
	validates_uniqueness_of		:username, case_sensitive: false, allow_blank: true, if: Proc.new{ |u| u.username_changed? && u.registered? }
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

	

	def avatar_asset_file=( file )
		return false unless file.present?
		asset = Pulitzer::ImageAsset.new(use: 'avatar', asset_type: 'image', status: 'active', parent_obj: self)
		asset.uploader = file
		asset.save
		self.avatar = asset.try(:url)
	end

	def avatar_asset_url=( url )
		return false unless url.present?
		asset = Pulitzer::ImageAsset.initialize_from_url(url, use: 'avatar', asset_type: 'image', status: 'active', parent_obj: self)
		asset.save unless asset.nil?
		puts "avatar_asset_url= asset: #{asset}"
		self.avatar = asset.try(:url) || url
	end
end
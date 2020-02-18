
class UserAddress < ApplicationRecord

	belongs_to	:geo_address
	belongs_to 	:user

end

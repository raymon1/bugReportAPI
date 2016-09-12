class Bug < ApplicationRecord
	has_one :state, dependent: :destroy
	accepts_nested_attributes_for :state, allow_destroy: true

	auto_increment :number, scope: :application_token, force: true, lock: true
	
	STATUSES = {
		0 => "New",
		1 => "In-progress",
		2 => "Closed"
	} 

	PRIORITY = {
		0 => "Minor",
		1 => "Major",
		2 => "Critical"
	}

	
end

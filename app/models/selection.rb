class Selection < ApplicationRecord
	belongs_to :event
	has_many :odds
end

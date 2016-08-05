require 'update_live'
require 'update_pre'
require 'pinnacle'

class ApplicationRecord < ActiveRecord::Base
  extend UpdateLive
  extend UpdatePre
  extend Pinnacle
  self.abstract_class = true
end

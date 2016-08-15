require 'update_live'
require 'update_pre'
require 'pinnacle'
require 'genius'

class ApplicationRecord < ActiveRecord::Base
  extend UpdateLive
  extend UpdatePre
  extend Pinnacle
  extend Genius
  self.abstract_class = true
end

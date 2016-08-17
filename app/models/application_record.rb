require 'update_live'
require 'update_pre'
require 'pinnacle'
require 'genius'
require 'token'

class ApplicationRecord < ActiveRecord::Base
  extend UpdateLive
  extend UpdatePre
  extend Pinnacle
  extend Genius
  extend Token
  self.abstract_class = true
end

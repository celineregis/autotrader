require 'update_live'
require 'update_pre'
require 'pinnacle'
require 'genius'
require 'token'
require 'optimizer'

class ApplicationRecord < ActiveRecord::Base
  extend UpdateLive
  extend UpdatePre
  extend Pinnacle
  extend Genius
  extend Token
  extend Optimizer
  self.abstract_class = true
end

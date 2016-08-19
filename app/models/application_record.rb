require 'update_live'
require 'update_pre'
require 'pinnacle'
require 'token'
require 'bookmaker'
require 'optimizer'

class ApplicationRecord < ActiveRecord::Base
  extend UpdateLive
  extend UpdatePre
  extend Pinnacle
  extend Bookmaker
  extend Token
  extend Optimizer
  self.abstract_class = true
end

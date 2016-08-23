require 'live_operations'
require 'pinnacle'
require 'token'
require 'bookmaker'
require 'optimizer'

class ApplicationRecord < ActiveRecord::Base
  extend LiveOperations
  extend Pinnacle
  extend Bookmaker
  extend Token
  extend Optimizer
  self.abstract_class = true
end

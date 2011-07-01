module Togo

  MODELS = []

  def self.models
    MODELS
  end

end

begin
  require 'extlib'
rescue
  require 'active_support'
end
require 'togo/model'
require 'togo/support'

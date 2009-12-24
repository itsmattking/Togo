module Togo

  MODELS = []

  def self.models
    MODELS
  end

end

require 'togo/model'

class String
  def uncamelize
    self.gsub(/([a-z])([A-Z])/,"\\1 \\2")
  end
end

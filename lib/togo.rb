module Togo

  MODELS = []

  def self.models
    MODELS
  end

end

%w{model dispatch}.each{|l| require File.join('togo',l,l)}

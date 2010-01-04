module Togo

  MODELS = []

  def self.models
    MODELS
  end

end

%w{model dispatch admin}.each{|l| require File.join('togo',l,l)}

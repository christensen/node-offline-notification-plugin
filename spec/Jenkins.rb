require 'EnvironmentVariablesNodeProperty'
module Jenkins
  def self.getInstance
    self
  end
  def self.getGlobalNodeProperties
    return [EnvironmentVariablesNodeProperty.new]
  end
end
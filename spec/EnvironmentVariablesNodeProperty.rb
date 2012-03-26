class EnvironmentVariablesNodeProperty
  def initialize hashMap
    @instEnvVarsHashmap = hashMap
    self
  end
  def getEnvVars()
    self
  end
  def get string
    @instEnvVarsHashmap[string]
  end
end
require 'node'
class NativeComputer
  def getOfflineCause
    "OfflineCause"
  end
  
  def getName
    "foo"
  end
end

class NativeConfiguredComputer < NativeComputer
  def getNode
    return ConfiguredNode.new
  end
end

class NativeNotConfiguredComputer < NativeComputer
  def getNode
    return NotConfiguredNode.new
  end
end

class NativeConfiguredComputerOfflineCauseNull < NativeComputer
  def getNode
    return ConfiguredNode.new
  end
  
  def getOfflineCause
    return nil
  end
end
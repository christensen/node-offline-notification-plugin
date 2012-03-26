require 'nativecomputer'

class Computer
  def initialize name
    @name = name
  end

  def to_s
    @name
  end
end

class ConfiguredComputer < Computer
  def native
    return NativeConfiguredComputer.new
  end
end

class NotConfiguredComputer < Computer
  def native
    return NativeNotConfiguredComputer.new
  end
end

class ConfiguredComputerOfflineCauseNull < Computer
  def native
    return NativeConfiguredComputerOfflineCauseNull.new
  end
end

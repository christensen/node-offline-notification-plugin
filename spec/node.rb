require 'emailnodeproperty'
class Node
  def getNodeName
    "foo"
  end
end

class ConfiguredNode < Node
  def getNodeProperties
    [EmailNodeProperty.new]
  end
end

class NotConfiguredNode < Node
  def getNodeProperties
    []
  end
end
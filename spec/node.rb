require 'emailnodeproperty'

class String
  def getTarget()
    EmailNodeProperty.new
  end
end

class Node
  def getNodeName
    "foo"
  end
end

class ConfiguredNode < Node
  def getNodeProperties
    ["somethingWeDontWant", "proxy.hudson.slaves.NodeProperty", "somethingelse"]
  end
end

class NotConfiguredNode < Node
  def getNodeProperties
    []
  end
end

Jenkins::Plugin::Specification.new do |plugin|
  plugin.name = "nodeofflinenotification"
  plugin.display_name = "Node Offline Notification Plugin"
  plugin.version = '1.0.1'
  plugin.description = 'Configure a node with email addresses to notify in case the node goes offline.'

  plugin.url = 'https://wiki.jenkins-ci.org/display/JENKINS/node-offline-notification-plugin'

  plugin.developed_by "christensen", "Jens Christensen 0xchristensen@gmail.com"

  #  :github => 'christensen/node-offline-notification-plugin'
  plugin.uses_repository :github => 'node-offline-notification-plugin'

  # This is a required dependency for every ruby plugin.
  plugin.depends_on 'ruby-runtime', '0.9'
end

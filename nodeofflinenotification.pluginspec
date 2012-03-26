
Jenkins::Plugin::Specification.new do |plugin|
  plugin.name = "nodeofflinenotification"
  plugin.display_name = "Node Offline Notification Plugin"
  plugin.version = '1.0'
  plugin.description = 'Configure a node with email addresses to notify in case the node goes offline.'

  # You should create a wiki-page for your plugin when you publish it, see
  # https://wiki.jenkins-ci.org/display/JENKINS/Hosting+Plugins#HostingPlugins-AddingaWikipage
  # This line makes sure it's listed in your POM.
  plugin.url = 'https://wiki.jenkins-ci.org/display/JENKINS/My+Plugin'

  # The first argument is your user name for jenkins-ci.org.
  plugin.developed_by "christensen", "Jens Christensen 0xchristensen@gmail.com"

  #  :github => 'christensen/node-offline-notification-plugin'
  plugin.uses_repository :github => 'node-offline-emailer-plugin'

  # This is a required dependency for every ruby plugin.
  plugin.depends_on 'ruby-runtime', '0.9'
end

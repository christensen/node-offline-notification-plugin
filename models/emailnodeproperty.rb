# 
# Save an email property for every node
#
class EmailNodeProperty < Jenkins::Slaves::NodeProperty
  display_name "Node Offline Email Notification"
 
  attr_accessor :email
 
  def initialize(attrs = {})
    @email = attrs['email']
  end
end

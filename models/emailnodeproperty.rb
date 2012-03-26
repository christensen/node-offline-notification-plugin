# 
# Save an email property for every node
#
class EmailNodeProperty < Jenkins::Slaves::NodeProperty
  display_name "Email notification"
 
  attr_accessor :email
 
  def initialize(attrs = {})
    @email = attrs['email']
  end
end

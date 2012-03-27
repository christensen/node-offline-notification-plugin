require 'environmentvariablesnodeproperty'
module Jenkins
  module Plugin
    class Proxy
      def getTarget
          EmailNodeProperty.new
      end
    end
  end
end

class EmailNodeProperty < Jenkins::Plugin::Proxy
  attr_accessor :email

  def initialize(attrs = {})
    @email = attrs['email']
  end

  def self.setAddressField addresses
    @@emails = addresses
  end
  
  def email
    @@emails
  end
end
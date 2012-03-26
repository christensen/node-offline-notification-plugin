$LOAD_PATH.push(File.dirname(__FILE__) + "/../models/src")

def import(path)
end

module Jenkins
  module Slaves
    module ComputerListener
      def online(computer, listener)
        puts computer
      end
      def offline(computer)
        puts computer
      end
    end
  end
end

require 'environmentvariablesnodeproperty'

module Java_Wrapper
  def getSmtpValues
    ["smtpServer", "smtpPort", "adminAddress"]
  end
  def getEnvVariableArray(envVar)
    for nodeProp in Jenkins.getInstance().getGlobalNodeProperties()
      if nodeProp.is_a? EnvironmentVariablesNodeProperty
        emailString = nodeProp.getEnvVars().get(envVar)
        return emailString.nil? ? nil : emailString.split(' ')
      end
    end
  end
  class Mailer
    smtpServer = ""
    smtpPort = ""
    adminAddress = ""
    def self.descriptor
      self
    end
    def self.getSmtpServer
      smtpServer
    end
    def self.getSmtpPort
      smtpPort
    end
    def self.getAdminAddress
      adminAddress
    end
    def self.setSmtpServer server
      smtpServer = server
    end
    def self.setSmtpPort port
      smtpPort = port
    end
    def self.setAdminAddress admin
      adminAddress = admin
    end
  end
  class Jenkins
    def self.getInstance
      self
    end
    def self.setEnvHash(envVarsHash)
      @instEnvVarsHashMap = envVarsHash      
    end
    def self.getGlobalNodeProperties
      return [EnvironmentVariablesNodeProperty.new(@instEnvVarsHashMap)]
    end
  end
end

include Jenkins::Slaves::ComputerListener
include Java_Wrapper

require 'emailcomputerlistener'
require 'computer'
require 'smtp'

describe EmailComputerListener do
  before :each do
    @ecl = EmailComputerListener.new
    Net::SMTP::restoreState
    Java_Wrapper::Jenkins::setEnvHash({})
  end

  it "should send an email if node is configured" do
    EmailNodeProperty.setAddressField "name@example.com"
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::emailSent?.should == true
  end

  it "should not send email if node is unconfigured" do
    EmailNodeProperty.setAddressField "name@example.com"
    @ecl.offline(NotConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::emailSent?.should == false
  end

  it "should have values for smtp, port, return address and to address" do
    EmailNodeProperty.setAddressField "name@example.com"
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::areValuesSet?.should == true
  end
  
  it "should not have the correct values if node is not configured" do
    @ecl.offline(NotConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::areValuesSet?.should == false
  end
  
  it "should send one email per email address in the node configurations" do
    EmailNodeProperty.setAddressField "name@example.com name2@example.com name3@example.com"
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::numberOfEmailsSent.should eq(3)
  end
  
  it "should only send one email if only one email is in the list" do
    EmailNodeProperty.setAddressField "name@example.com"
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::numberOfEmailsSent.should eq(1)
  end
  
  it "should not send any emails if it's the master going down (offlineCause == nil)" do
    EmailNodeProperty.setAddressField "name@example.com"
    @ecl.offline(ConfiguredComputerOfflineCauseNull.new("ThisIsASlave"))
    Net::SMTP::emailSent?.should == false
  end
  
  it "should send an online message if it went offline earlier" do
    EmailNodeProperty.setAddressField "name@example.com"
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    @ecl.online(ConfiguredComputer.new("ThisIsASlave"), "Does not matter")
    Net::SMTP::numberOfEmailsSent.should eq(2)
  end
  
  it "should expand a single environment variable" do
    EmailNodeProperty.setAddressField "$ENVVAR"
    hashMap = {"ENVVAR"=>"name@example.com"}
    Java_Wrapper::Jenkins::setEnvHash(hashMap)
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::expandedAddressField.should eq("name@example.com")
  end
  
  it "should return nil if environment variable does not exist" do
    EmailNodeProperty.setAddressField "$ENVVAR"
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::expandedAddressField.should eq nil
  end
  
  it "should expand a single environment variable with several emails in it" do
    EmailNodeProperty.setAddressField "$ENVVAR"
    hashMap = {"ENVVAR"=>"name1@example.com name2@example.com name3@example.com"}
    Java_Wrapper::Jenkins::setEnvHash(hashMap)
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::numberOfEmailsSent.should eq(3)
    array = ["name1@example.com", "name2@example.com" ,"name3@example.com"]
    Net::SMTP::expandedVariables(array).should eq("expanded correctly")
  end
  
  it "should expand several environment variables" do
    EmailNodeProperty.setAddressField "$ENVVAR1 %ENVVAR2% ${ENVVAR3}"
    hashMap = {"ENVVAR1"=>"name1@example.com", "ENVVAR2"=>"name2@example.com", "ENVVAR3"=>"name3@example.com"}
    Java_Wrapper::Jenkins::setEnvHash(hashMap)
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::numberOfEmailsSent.should eq(3)
    array = ["name1@example.com", "name2@example.com" ,"name3@example.com"]
    Net::SMTP::expandedVariables(array).should eq("expanded correctly")
  end
  
  it "should take a mix between environment variables and emails" do
    EmailNodeProperty.setAddressField "$ENVVAR1 name2@example.com ${ENVVAR2}"
    hashMap = {"ENVVAR1"=>"name1@example.com", "ENVVAR2"=>"name3@example.com"}
    Java_Wrapper::Jenkins::setEnvHash(hashMap)
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::numberOfEmailsSent.should eq(3)
    array = ["name1@example.com", "name2@example.com" ,"name3@example.com"]
    Net::SMTP::expandedVariables(array).should eq("expanded correctly")
  end
  
  it "should handle a non-existent environment variable in a string with several other entries" do
    EmailNodeProperty.setAddressField "$ENVVAR1 name2@example.com ${ENVVAR2}"
    hashMap = {"ENVVAR2"=>"name3@example.com"}
    Java_Wrapper::Jenkins::setEnvHash(hashMap)
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::numberOfEmailsSent.should eq(2)
    array = ["name2@example.com" ,"name3@example.com"]
    Net::SMTP::expandedVariables(array).should eq("expanded correctly")
  end
  
  it "should handle several environment variables with several emails in each" do
    EmailNodeProperty.setAddressField "$ENVVAR1 ${ENVVAR2}"
    hashMap = {"ENVVAR1"=>"name1@example.com name2@example.com", "ENVVAR2"=>"name3@example.com name4@example.com"}
    Java_Wrapper::Jenkins::setEnvHash(hashMap)
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Net::SMTP::numberOfEmailsSent.should eq(4)
    array = ["name1@example.com", "name2@example.com" ,"name3@example.com", "name4@example.com"]
    Net::SMTP::expandedVariables(array).should eq("expanded correctly")
  end
end

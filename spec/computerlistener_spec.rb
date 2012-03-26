$LOAD_PATH.push(File.dirname(__FILE__) + "/../models/src")

module Jenkins
  module Slaves
    module ComputerListener
    end
  end
end

require 'environmentvariablesnodeproperty'

module Java_Wrapper

  @@numberOfEmailsSent = 0
  @@arrayOfEmails = []
  @@mail = ""
  
  def getEnvVariableArray(envVar)
    for nodeProp in Jenkins.getInstance().getGlobalNodeProperties()
      if nodeProp.is_a? EnvironmentVariablesNodeProperty
        emailString = nodeProp.getEnvVars().get(envVar)
        return emailString.nil? ? nil : emailString.split(' ')
      end
    end
  end
  
  def sendEmail(mail, name, online)
    @@numberOfEmailsSent += 1
    @@arrayOfEmails.push(mail)
    @@mail = mail
  end
  
  def getNumberOfEmailsSent()
    return @@numberOfEmailsSent
  end
  
  def restoreState()
    @@numberOfEmailsSent = 0
    @@arrayOfEmails = []
    @@mail = ""
  end
  
  def expandedVariables array
    if @@arrayOfEmails == array
      return "expanded correctly"
    else
      return "something went wrong"
    end
  end
  
  def self.expandedAddressField
    if @@mail == ""
      return nil
    else
      return @@mail
    end
  end
  
  class Mailer
    def self.descriptor
      self
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

describe EmailComputerListener do
  before :each do
    @ecl = EmailComputerListener.new
    Java_Wrapper::restoreState()
    Java_Wrapper::Jenkins::setEnvHash({})
  end

  it "should send an email if node is configured" do
    EmailNodeProperty.setAddressField "name@example.com"
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Java_Wrapper::getNumberOfEmailsSent.should eq(1)
  end

  it "should not send email if node is unconfigured" do
    EmailNodeProperty.setAddressField "name@example.com"
    @ecl.offline(NotConfiguredComputer.new("ThisIsASlave"))
    Java_Wrapper::getNumberOfEmailsSent.should eq(0)
  end
  
  it "should send one email per email address in the node configurations" do
    EmailNodeProperty.setAddressField "name@example.com name2@example.com name3@example.com"
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Java_Wrapper::getNumberOfEmailsSent.should eq(3)
  end
  
  it "should only send one email if only one email is in the list" do
    EmailNodeProperty.setAddressField "name@example.com"
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Java_Wrapper::getNumberOfEmailsSent.should eq(1)
  end
  
  it "should not send any emails if it's the master going down (offlineCause == nil)" do
    EmailNodeProperty.setAddressField "name@example.com"
    @ecl.offline(ConfiguredComputerOfflineCauseNull.new("ThisIsASlave"))
    Java_Wrapper::getNumberOfEmailsSent.should eq(0)
  end
  
  it "should send an online message if it went offline earlier" do
    EmailNodeProperty.setAddressField "name@example.com"
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    @ecl.online(ConfiguredComputer.new("ThisIsASlave"), "Does not matter")
    Java_Wrapper::getNumberOfEmailsSent.should eq(2)
  end
  
  it "should expand a single environment variable" do
    EmailNodeProperty.setAddressField "$ENVVAR"
    hashMap = {"ENVVAR"=>"name@example.com"}
    Java_Wrapper::Jenkins::setEnvHash(hashMap)
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Java_Wrapper::expandedAddressField.should eq("name@example.com")
  end
  
  it "should return nil if environment variable does not exist" do
    EmailNodeProperty.setAddressField "$ENVVAR"
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Java_Wrapper::expandedAddressField.should eq nil
  end
  
  it "should expand a single environment variable with several emails in it" do
    EmailNodeProperty.setAddressField "$ENVVAR"
    hashMap = {"ENVVAR"=>"name1@example.com name2@example.com name3@example.com"}
    Java_Wrapper::Jenkins::setEnvHash(hashMap)
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Java_Wrapper::getNumberOfEmailsSent.should eq(3)
    array = ["name1@example.com", "name2@example.com" ,"name3@example.com"]
    Java_Wrapper::expandedVariables(array).should eq("expanded correctly")
  end
  
  it "should expand several environment variables" do
    EmailNodeProperty.setAddressField "$ENVVAR1 %ENVVAR2% ${ENVVAR3}"
    hashMap = {"ENVVAR1"=>"name1@example.com", "ENVVAR2"=>"name2@example.com", "ENVVAR3"=>"name3@example.com"}
    Java_Wrapper::Jenkins::setEnvHash(hashMap)
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Java_Wrapper::getNumberOfEmailsSent.should eq(3)
    array = ["name1@example.com", "name2@example.com" ,"name3@example.com"]
    Java_Wrapper::expandedVariables(array).should eq("expanded correctly")
  end
  
  it "should take a mix between environment variables and emails" do
    EmailNodeProperty.setAddressField "$ENVVAR1 name2@example.com ${ENVVAR2}"
    hashMap = {"ENVVAR1"=>"name1@example.com", "ENVVAR2"=>"name3@example.com"}
    Java_Wrapper::Jenkins::setEnvHash(hashMap)
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Java_Wrapper::getNumberOfEmailsSent.should eq(3)
    array = ["name1@example.com", "name2@example.com" ,"name3@example.com"]
    Java_Wrapper::expandedVariables(array).should eq("expanded correctly")
  end
  
  it "should handle a non-existent environment variable in a string with several other entries" do
    EmailNodeProperty.setAddressField "$ENVVAR1 name2@example.com ${ENVVAR2}"
    hashMap = {"ENVVAR2"=>"name3@example.com"}
    Java_Wrapper::Jenkins::setEnvHash(hashMap)
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Java_Wrapper::getNumberOfEmailsSent.should eq(2)
    array = ["name2@example.com" ,"name3@example.com"]
    Java_Wrapper::expandedVariables(array).should eq("expanded correctly")
  end
  
  it "should handle several environment variables with several emails in each" do
    EmailNodeProperty.setAddressField "$ENVVAR1 ${ENVVAR2}"
    hashMap = {"ENVVAR1"=>"name1@example.com name2@example.com", "ENVVAR2"=>"name3@example.com name4@example.com"}
    Java_Wrapper::Jenkins::setEnvHash(hashMap)
    @ecl.offline(ConfiguredComputer.new("ThisIsASlave"))
    Java_Wrapper::getNumberOfEmailsSent.should eq(4)
    array = ["name1@example.com", "name2@example.com", "name3@example.com", "name4@example.com"]
    Java_Wrapper::expandedVariables(array).should eq("expanded correctly")
  end
end

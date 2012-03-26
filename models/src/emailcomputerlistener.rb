class EmailComputerListener
  include Jenkins::Slaves::ComputerListener
  
  # Computers that previously went offline
  @@offlineComputers = []
  # Our Java_Wrapper so that tests can pass
  @@java_wrap = Java_Wrapper
  
  #
  # ONLINE!
  #
  def online(computer, listener)
    @name = computer.native.getName()
    
    if isComputerInOfflineList?()
      willNotifyResponsible(computer, true)
    end
  end
    
  #
  # OFFLINE!
  #
  # Send an email if the invoking computer
  # is a slave, else do nothing
  # standard method in ComputerListener
  #
  def offline(computer)
    cause = computer.native.getOfflineCause()
    @name = computer.native.getName()
    
     # Add computer to @@offlineComputers and notify responsible
     # UNLESS the master is restarted, wich will generate cause == nil
    unless cause.nil?
      addToList()
      willNotifyResponsible(computer, false)
    end
  end
  
  #
  # Check if the computer is in the offline list
  #
  private
  def isComputerInOfflineList?
    if @@offlineComputers.find_index(@name)
      return true
    else
      return false
    end
  end
  
  #
  # Notify everyone in the list
  # isOnline => true for online
  #          => false for offline
  #
  private
  def willNotifyResponsible(computer, onlineCalled)
    updateEmailAddresses(computer)
    unless @emailAddresses.nil?
      for emailAddress in @emailAddresses
        @@java_wrap::sendEmail(emailAddress, @name, onlineCalled)
      end
    end
  end
  
  #
  # Add current computer to @@offlineComputers unless it's already there
  #
  private
  def addToList
    unless @@offlineComputers.find_index(@name)
      @@offlineComputers.push(@name)
    end
  end
  
  #
  # Updates the email address array with addresses from computer
  # computer => the computer that lost connection
  #
  private
  def updateEmailAddresses computer
    emailNodeProp = getEmailNodeProperty(computer)
  
    if emailNodeProp.nil?
      return
    end

    @emailAddresses = []

    # Create an array with the email addresses
    localEmailArray = emailNodeProp.email.split(' ')
    
    #
    # Evaluate all environment variables.
    # If the email field in the configuration view is left empty,
    # then localEmailArray.length will be 0
    #
    for i in 0...localEmailArray.length
      # Is @emailAddresses[i] an environment variable?
      if localEmailArray[i].match('^[%$]')
        envContent = getEnvVariableArray(localEmailArray[i])
        if envContent.nil?
          puts "  Could not find environment variable #{localEmailArray[i]}"
        else
          # Add the addresses last in @emailAddresses
          @emailAddresses += envContent
        end
      else
        @emailAddresses += [localEmailArray[i]]
      end
    end
  end
  
  #
  # Fetch the EmailNodeProperty for computer
  # computer => the computer for which you want the Property
  # returns the EmailNodeProperty
  #
  private
  def getEmailNodeProperty(computer)
    nodeProps = computer.native.getNode().getNodeProperties()
    emailNodeProp = nodeProps.find {"EmailNodeProperty"}
    return emailNodeProp.nil? ? nil : emailNodeProp.getTarget
  end



  #
  # Evaluates the environment variable
  # envVar => the environment variable
  # returns all addresses in an array
  #   or nil if envVar doesn't exist
  #
  private
  def getEnvVariableArray(envVar)
    envVar.delete! "%${}"
    @@java_wrap::getEnvVariableArray(envVar)
  end
end
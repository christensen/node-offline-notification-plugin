class EmailComputerListener
  include Jenkins::Slaves::ComputerListener
  
  # Our Java_Wrapper so that tests can pass
  @@java_wrap = Java_Wrapper
  
  #
  # ONLINE!
  #
  def online(computer, listener)
    @name = computer.native.getName()
    
    if computer.to_s.match("Master")
      computersArray = @@java_wrap::getAllComputers()

      for c in computersArray
        if c.isOffline()
          @name = c.getName()
          startUpNotification(c)
        end
      end
    else
      notifyResponsibleOnline(computer)
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
    
     # UNLESS the master is restarted, which will generate cause == nil
    unless cause.nil?
      notifyResponsibleOffline(computer)
    end
  end

  #
  # Called when a node goes offline
  # parameters sent to notifyResponsible are:
  # computer object, online?, masterStart?
  #
  private
  def notifyResponsibleOffline (computer)
    notifyResponsible(computer, false, false)
  end

  #
  # Same as above, except called when computers come online
  #
  private
  def notifyResponsibleOnline(computer)
    notifyResponsible(computer, true, false)
  end
  
  #
  # Called when master is starting up
  # to give a special email message
  # notifying that the master restarted
  # and nodes might not be connecting again
  #
  private
  def startUpNotification(computer)
    notifyResponsible(computer, true, true)
  end
  
  #
  # Notify everyone in the list
  # isOnline => true for online
  #          => false for offline
  #
  private
  def notifyResponsible(computer, onlineCalled, masterStart)
    updateEmailAddresses(computer)
    unless @emailAddresses.nil?
      for emailAddress in @emailAddresses
        @@java_wrap::sendEmail(emailAddress, @name, onlineCalled, masterStart)
      end
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
    if computer.is_a? Jenkins::Plugin::OpaqueJavaObject
      nodeProps = computer.native.getNode().getNodeProperties()
    else
      nodeProps = computer.getNode().getNodeProperties()
    end

    for emailProp in nodeProps
      if emailProp.to_s.match("proxy.hudson.slaves.NodeProperty")
        return emailProp.getTarget()
      end
    end
    
    nil
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
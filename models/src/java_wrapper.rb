module Java_Wrapper
  import Java::jenkins::model::Jenkins
  import Java::hudson::slaves::EnvironmentVariablesNodeProperty
  import Java::hudson::tasks::Mailer
  import Java::javax::mail::internet::MimeMessage
  import Java::javax::mail::Session
  import Java::javax::mail::Transport
  import Java::javax::mail::internet::InternetAddress
  import Java::javax::mail::Message

  #
  # Searches for envVar among the system's environment variables
  # and splits this into an array.
  # returns the array
  #   or nil if envVar doesn't exist
  #
  def Java_Wrapper.getEnvVariableArray envVar
    for nodeProp in Jenkins.getInstance().getGlobalNodeProperties()
      if nodeProp.is_a? EnvironmentVariablesNodeProperty
        emailString = nodeProp.getEnvVars().get(envVar)
        return emailString.nil? ? nil : emailString.split(' ')
      end
    end
  end
  
  #
  # Using Jenkins built-in support for emailing
  #
  def Java_Wrapper.sendEmail(mail, name, online)
    newSession = Mailer.descriptor().createSession()
    begin
      msg = MimeMessage.new(newSession)

      if online
        msg.setSubject("Slave back online")
        msg.setText("The connection to the slave (#{name}) was restored.")
      else
        msg.setSubject("Slave Connection lost")
        msg.setText("The connection to the slave (#{name}) you are responsible for, has been lost.")
      end

      msg.setFrom(InternetAddress.new(Mailer.descriptor().getAdminAddress()))
      msg.setRecipient(Message::RecipientType::TO, InternetAddress.new(mail))
      Transport.send(msg)
    rescue Exception => e then
      puts "  #{e.to_s}"
    end
  end

  def Java_Wrapper.getAllComputers()
    computers = Jenkins.getInstance().getComputers()
    return computers
  end

end
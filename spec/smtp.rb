module Net
  class SMTP
    def initialize
    end

    def self.start(server, port)
      if server == ""
        raise
      end
      @@server = server
      @@emailSent = true
      @@numberOfEmailsSent += 1
      Net::SMTP.new
    end
    
    public
    def send_message(msgstr, admin, mail)
      @@msgstr = msgstr
      @@admin = admin
      @@mail = mail
      @@arrayOfEmails.push(mail)
    end

    def self.restoreState
      @@emailSent = false
      @@server = ""
      @@msgstr = ""
      @@admin = ""
      @@mail = nil
      @@numberOfEmailsSent = 0
      @@arrayOfEmails = []
    end

    def self.emailSent?
      @@emailSent
    end

    def self.numberOfEmailsSent
      @@numberOfEmailsSent
    end
    
    def self.areValuesSet?
      if @@server == "smtpServer" && @@msgstr.match("Slave") != nil && @@admin.match("adminAddress") != nil && @@mail == "name@example.com"
        return true 
      else
        return false
      end
    end
    
    def self.expandedVariables array
      if @@arrayOfEmails == array
        return "expanded correctly"
      else
        return "something went wrong"
      end
    end

    def self.expandedAddressField
      @@mail
    end
    
    def finish
    end
  end
end

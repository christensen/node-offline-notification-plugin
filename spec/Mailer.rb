class Mailer
  def self.descriptor
    self
  end
  def self.getSmtpServer
    "smtpServer"
  end
  def self.getSmtpPort
    25
  end
  def self.getAdminAddress
    "adminAddress"
  end
end
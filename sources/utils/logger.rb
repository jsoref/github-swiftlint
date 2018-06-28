class Logger
  def self.error(message)
    puts "[ERROR] #{message}"
  end
  
  def self.warn(message)
    puts "[WARNING] #{message}"
  end
  
  def self.info(message)
    puts "[INFO] #{message}"
  end
  
  def self.critical(error)
    puts "[CRITICAL] #{error}"
    puts "[CRITICAL] #{error.backtrace}"
  end
end

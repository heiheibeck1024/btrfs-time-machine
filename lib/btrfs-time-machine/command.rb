module Command
  require 'logging'
  require 'mixlib/shellout'

  def execute data
    log_fatal("Invalid data") unless data.is_a? Hash

    # set the defaults
    data[:cmd]              ||= nil
    data[:expect]           ||= 0
    data[:failure]          ||= {}
    data[:failure][:level]  ||= "info"
    data[:failure][:msg]    ||= ""
    data[:success]          ||= {}
    data[:success][:level]  ||= "info"
    data[:success][:msg]    ||= ""

    unless data.has_key(:cmd)
      @log.error "Command was not provided"
      return false
    end

    exitstatus = Mixlib::ShellOut.new(data[:cmd]).run_command.exitstatus.to_i
    
    if data[:expect] == exitstatus
      @log.info data[:success_message]
      return true
    else
      @log.error data[:failure_message]
      return false
    end
  end

  # TODO: sort out the logging
  def log data
    @log fatal
    data[:msg] 
  end

  def log_error msg
    @log fatal
  end

  def log_fatal msg
    @log fatal
    raise "A fatal error occurred. See the log for details."
    exit 1
  end

end

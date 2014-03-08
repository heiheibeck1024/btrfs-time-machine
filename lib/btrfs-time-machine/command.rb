module Command
  require 'mixlib/shellout'
  # TODO: get the log level from settings and apply it here.
  # TODO: do the locking to prevent simultaneous runs.

  def execute data
    LOG.fatal("Invalid data") unless data.is_a? Hash

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
end

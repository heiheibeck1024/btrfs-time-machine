module Command
  require 'mixlib/shellout'
  # TODO: get the log level from settings and apply it here.
  # TODO: do the locking to prevent simultaneous runs.

  private
  def execute data
    LOG.fatal("Invalid data") unless data.is_a? Hash
    LOG.fatal("Command was not provided") unless data.has_key?(:cmd)
    data[:cmd]              ||= nil
    data[:test_cmd]         ||= nil
    data[:expect]           ||= 0
    data[:failure]          ||= {}
    data[:failure][:level]  ||= "error"
    data[:failure][:msg]    ||= nil
    data[:success]          ||= {}
    data[:success][:level]  ||= "debug"
    data[:success][:msg]    ||= nil
    @data = data

    @exitstatus = Mixlib::ShellOut.new(data[:cmd]).run_command.exitstatus.to_i.zero?
    status
  end

  def status
    cmd = @data[:test_cmd]
    case cmd.class
      when NilClass
        succeeded = @exitstatus
      when TrueClass
        succeeded = true
      when FalseClass
        succeeded = false
      when Symbol
        succeeded = send(cmd.to_s) if public_methods.include?(cmd)
      when String
        succeeded ||= Mixlib::ShellOut.new(cmd).run_command.exitstatus.to_i.zero?
    end

    if @data[:success][:msg] && succeeded
      LOG.send(@data[:success][:level], @data[:success][:msg]) 
    end

    if @data[:failure][:msg] && !succeeded
      LOG.send(@data[:failure][:level], @data[:failure][:msg])
    end

    succeeded
  end

end

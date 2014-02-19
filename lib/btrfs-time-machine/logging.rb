module Logging
  @log = Logging.logger['btrfs-time-machine']
    @log.add_appenders(
      Logging.appenders.stdout,
      Logging.appenders.file(LOG_FILE)
    )
  @log.level = LOG_LEVEL.to_sym
end

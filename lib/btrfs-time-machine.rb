$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '/btrfs-time-machine')

require 'command'
require 'filesystem'
require 'logging'
require 'ptools'
require 'rsync'
require 'settings'

Logging.appenders.stdout(
  'stdout',
  :layout => Logging.layouts.pattern(
    :pattern => '%d\t%-5l\t%c\t%m\n'
  )
)

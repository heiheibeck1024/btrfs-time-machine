$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '/btrfs-time-machine')

require 'command'
require 'filesystem'
require 'logger'
require 'ptools'
require 'rsync'
require 'settings'

LOG = Logger.new(STDOUT)
LOG.level = Logger::WARN    # Default level is warn. Disregard anything lower.

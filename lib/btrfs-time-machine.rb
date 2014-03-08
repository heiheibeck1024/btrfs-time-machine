$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '/btrfs-time-machine')

require 'command'
require 'filesystem'
require 'fileutils'
require 'logger'
require 'ptools'
require 'rsync'
require 'settings'

unless defined? LOG
  LOG = Logger.new(STDOUT)
  LOG.level = Logger::DEBUG
end

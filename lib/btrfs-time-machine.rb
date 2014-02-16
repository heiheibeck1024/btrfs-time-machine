$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '/btrfs-time-machine')

require 'filesystem'
require 'rsync'
require 'settings'

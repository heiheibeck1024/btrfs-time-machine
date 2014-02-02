require 'rubygems'
require 'riot'

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib/btrfs-time-machine')

BTRFS_FILE_SYSTEM = File.join(File.dirname(__FILE__), "dev/btrfs")
MOUNT_POINT = File.join(File.dirname(__FILE__), "mnt")

require 'settings'
require 'btrfs'

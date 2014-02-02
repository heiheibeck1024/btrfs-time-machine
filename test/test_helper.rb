require 'rubygems'
require 'riot'

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib/btrfs-time-machine')

BTRFS_FS = File.join(File.dirname(__FILE__), "dev/btrfs")
EXT4_FS = File.join(File.dirname(__FILE__), "dev/ext4")
MOUNT_POINT = File.join(File.dirname(__FILE__), "mnt")

require 'filesystem'
require 'rsync'
require 'settings'

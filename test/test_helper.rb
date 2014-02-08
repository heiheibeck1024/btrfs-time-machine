require 'rubygems'
require 'riot'

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib/btrfs-time-machine')

BTRFS_FS = File.join(File.dirname(__FILE__), "dev/btrfs")
EXT4_FS = File.join(File.dirname(__FILE__), "dev/ext4")
MOUNT_POINT = File.join(File.dirname(__FILE__), "mnt")
DATA_SOURCE = "/tmp/tm-src"
DATA_DESTINATION = "/tmp/tm-dest"

require 'filesystem'
require 'rsync'
require 'settings'

def setup_source_data
  directories = %w[
    home/d
    tmp
    tmp2
  ]

  files = %w[
    /home/d/a
    /tmp2/a
    home/a
    home/b
    home/c
    tmp/a
  ]

  directories.each do |d|
    FileUtils::mkdir_p(File.join(DATA_SOURCE, "1", d))
  end

  files.each do |f|
    FileUtils::touch(File.join(DATA_SOURCE, "1", f))
  end
end

def destroy_source_data
  FileUtils::rm_rf "#{DATA_DESTINATION}/*"
  FileUtils::mkdir_p DATA_DESTINATION
  FileUtils::rm_rf File.join(DATA_SOURCE, "/1")
end

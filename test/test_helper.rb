require 'mixlib/shellout'
require 'riot'
require 'rubygems'

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib/btrfs-time-machine')

BTRFS_FS = "/tmp/test-tm/dev/btrfs"
EXT4_FS = "/tmp/test-tm/dev/ext4"
MOUNT_POINT = "/tmp/test-tm/mnt"
TEST_DATA = "/tmp/test-tm/src"

require 'filesystem'
require 'rsync'
require 'settings'

def setup_file_systems
  FileUtils.mkdir_p(MOUNT_POINT)

  [ BTRFS_FS, EXT4_FS ].each do |dev|
    FileUtils.mkdir_p(File.dirname(dev))
  end

  unless File.exist?(BTRFS_FS)
    Mixlib::ShellOut.new("dd if=/dev/zero of=#{BTRFS_FS} bs=1MB count=100").run_command
    Mixlib::ShellOut.new("mkfs.btrfs #{BTRFS_FS}").run_command
  end

  unless File.exist?(EXT4_FS)
    Mixlib::ShellOut.new("dd if=/dev/zero of=#{EXT4_FS} bs=1MB count=100").run_command
    Mixlib::ShellOut.new("mkfs.ext4 -F #{EXT4_FS}").run_command
  end
end

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

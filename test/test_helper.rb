require 'mixlib/shellout'
require 'riot'
require 'rubygems'
require 'yaml'
require 'logger'

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

LOG = Logger.new("/tmp/out")
LOG.level = Logger::DEBUG

require 'btrfs-time-machine'

BTRFS_FS = "/tmp/test-tm/dev/btrfs"
EXT4_FS = "/tmp/test-tm/dev/ext4"
MOUNT_POINT = "/tmp/test-tm/mnt"
TEST_DATA = "/tmp/test-tm/src"

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

def create_data
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
    FileUtils::mkdir_p(File.join(TEST_DATA, d))
  end

  files.each do |f|
    FileUtils::touch(File.join(TEST_DATA, f))
  end
end

def destroy_data
  FileUtils::rm_rf MOUNT_POINT
  FileUtils::rm_rf TEST_DATA
  FileUtils::mkdir_p MOUNT_POINT
  FileUtils::mkdir_p TEST_DATA
end

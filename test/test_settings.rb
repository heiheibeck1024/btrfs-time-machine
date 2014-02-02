require 'test_helper'

context "#TimeMachine::Settings" do
  setup {
    TimeMachine::Config.new({
      :config => "test/config/config1.yml",
      :sources => "test/config/sources1.yml"
    })
  }

  asserts_topic.kind_of TimeMachine::Settings
  asserts("to_hash") {topic.to_hash}.kind_of Hash

  settings = {
    "dest_device_uuid" => 'xxxx',
    "backup_mount_point" => '/srv/btrfs_backups',
    "log_file" => '/var/log/time_machine.log',
    "mount_options" => [ "compress" ],
    "rsync_options" => " --max-size 2G",
    "snapshot_max_age" => 48,
    "deduplicate" => true,
    "lock_file" => '/var/lock/time_machine',
    "alert_email" => 'someone@somewhere.com'
  }
  
  settings.each do |k,v|
    asserts(k) {topic.to_hash[k.to_s]}.equals v
  end
end

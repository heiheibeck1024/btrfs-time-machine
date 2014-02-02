require 'test_helper'

context "#TimeMachine::Settings" do
  setup {
    TimeMachine::Settings.new({
      :config => "test/config/config1.yml",
      :sources => "test/config/sources1.yml"
    })
  }

  asserts_topic.kind_of TimeMachine::Settings
  asserts("to_hash") {topic.to_hash}.kind_of Hash
  asserts("sources") {topic.sources}.kind_of Array
  asserts("config") {topic.config}.kind_of Hash

  settings = {
    "alert_email" => 'someone@somewhere.com',
    "backup_mount_point" => '/srv/btrfs_backups',
    "deduplicate" => true,
    "dest_device_uuid" => 'xxxx',
    "lock_file" => '/var/lock/time_machine',
    "log_file" => '/var/log/time_machine.log',
    "mount_options" => [ "compress" ],
    "rsync_options" => " --max-size 2G",
    "snapshot_max_age" => 48,
    "sources" => [
      {"source"=>"/home/me", "one-filesystem"=>true, "exclusions"=>["Dropbox", "tmp"]},
      {"source"=>"/usr/local", "snapshot"=>true, "exclusions"=>["src"]},
      "source '/var/spool/mail'",
      "source '/var/www'",
      {"source"=>"/mount/ntfdata/pic", "rsync_options"=>["--modify-window=1"]}
    ]
  }
  
  settings.each do |k,v|
    asserts(k) {topic.to_hash[k.to_s]}.equals v
  end
end

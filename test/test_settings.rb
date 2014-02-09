require 'test_helper'

context "#TimeMachine::Settings" do
  setup do
    config = YAML.parse(<<-EOF).to_ruby
      dest_device_uuid: 'xxxx'
      backup_mount_point: '#{MOUNT_POINT}'
      log_file: '/dev/null'
      mount_options:
         - compress
      rsync_options: "--max-size 2G"
      snapshot_max_age: 48
      deduplicate: true
      lock_file: '/var/lock/time_machine'
      alert_email: 'someone@somewhere.com'

      sources:
        - source: '#{TEST_DATA}'
          one-filesystem: true
          exclusions:
            - './tmp2'
            - 'tmp'
          rsync_options:
            - "--modify-window=1"
    EOF

    TimeMachine::Settings.new(config)
  end


  asserts_topic.kind_of TimeMachine::Settings
  asserts("to_hash") {topic.to_hash}.kind_of Hash
  asserts("sources") {topic.sources}.kind_of Array

  settings = {
    "alert_email" => 'someone@somewhere.com',
    "backup_mount_point" => MOUNT_POINT,
    "deduplicate" => true,
    "dest_device_uuid" => 'xxxx',
    "lock_file" => '/var/lock/time_machine',
    "log_file" => '/dev/null',
    "mount_options" => [ "compress" ],
    "rsync_options" => "--max-size 2G",
    "snapshot_max_age" => 48,
    "sources" => [
      {"source"=> TEST_DATA,
        "one-filesystem"=>true,
        "exclusions"=>["./tmp2", "tmp"],
        "rsync_options"=>["--modify-window=1"]
      }
    ]
  }
  
  settings.each do |k,v|
    asserts(k) {topic.to_hash[k.to_s]}.equals v
  end
end

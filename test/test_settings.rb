require 'test_helper'

context "#TimeMachine::Settings" do
  setup do
    config = YAML.parse(<<-EOF).to_ruby
      dest_device_uuid: 'xxxx'
      backup_mount_point: '#{MOUNT_POINT}'
      log_file: '/dev/null'
      mount_options:
         - compress
      rsync_options:
        - "--max-size 2G"
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
        - source: '/tmp'
        - source: '/etc/passwd'
    EOF

    TimeMachine::Settings.new(config)
  end


  asserts_topic.kind_of TimeMachine::Settings
  asserts("to_hash") {topic.to_hash}.kind_of Hash
  asserts("sources") {topic.sources}.kind_of Array
  asserts("destination") {topic.destination(TEST_DATA)}.equals File.join(MOUNT_POINT, "latest", TEST_DATA)

  context "sources" do
    asserts("size") {topic.sources.size}.equals 3
    asserts("has key of #{TEST_DATA}") {topic.sources.include? TEST_DATA}
    asserts("has key of /etc/passwd") {topic.sources.include? "/etc/passwd"}
    asserts("has key of /tmp") {topic.sources.include? "/tmp"}
  end

  context "global_settings" do
    asserts("has backup_mount_point") {topic.global_settings.has_key? "backup_mount_point"}
    asserts("has mount_options") {topic.global_settings.has_key? "mount_options"}
    asserts("mount_options is an array") {topic.global_settings["mount_options"].is_a?(Array)}
    asserts("has no sources") {!topic.global_settings.has_key? "sources"}
    asserts("has deduplicate") {topic.global_settings["deduplicate"]}
  end

  context "source_settings for #{TEST_DATA}" do
    asserts("is a hash") { topic.source_settings(TEST_DATA).is_a? Hash }
    asserts("has exclusions") { topic.source_settings(TEST_DATA).has_key?("exclusions") }
    asserts("cleaned exclusion path")   {topic.source_settings(TEST_DATA)["exclusions"].include?("tmp2")}
    asserts("has global deduplicate") {topic.source_settings(TEST_DATA)["deduplicate"]}
    asserts("has global lock_file")     {topic.source_settings(TEST_DATA)["lock_file"] }.equals "/var/lock/time_machine"
    asserts("has global mount_options") {topic.source_settings(TEST_DATA)["mount_options"].include?("compress")}
    asserts("has global rsync_options") {topic.source_settings(TEST_DATA)["rsync_options"].include?("--max-size 2G")}
    asserts("has source one-filesystem"){topic.source_settings(TEST_DATA)["one-filesystem"]}
    asserts("has source rsync_options") {topic.source_settings(TEST_DATA)["rsync_options"].include?("--modify-window=1")}
  end

  context "rsync_options for #{TEST_DATA}" do
    asserts("default option is included") { topic.rsync_options(TEST_DATA).include? "--acls" }
    asserts("global option is included") { topic.rsync_options(TEST_DATA).include? "--max-size 2G" }
    asserts("source option is included") { topic.rsync_options(TEST_DATA).include? "--modify-window=1" }
    asserts("tmp2 is excluded") { topic.rsync_options(TEST_DATA).include? "--exclude tmp2" }
  end
end

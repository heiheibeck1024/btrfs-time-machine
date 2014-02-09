require 'test_helper'

SOURCES = YAML.parse(<<-EOF.gsub(/^\s{2}/, '')).to_ruby
  - source: '#{TEST_DATA}'
    one-filesystem: true
    exclusions:
      - './tmp2'
      - 'tmp'
    rsync_options:
      - "--modify-window=1"
EOF

CONFIG = YAML.parse(<<-EOF.gsub(/^\s{2}/, '')).to_ruby
  dest_device_uuid: 'xxxx'
  backup_mount_point: '#{MOUNT_POINT}'
  log_file: '/dev/null'
  mount_options:
     - compress
  rsync_options:
      " --max-size 2G"
  snapshot_max_age: 48
  deduplicate: true
  lock_file: '/var/lock/time_machine'
  alert_email: 'someone@somewhere.com'
EOF

context "#TimeMachine::Rsync" do
  setup do
    create_data
    TimeMachine::Rsync.new(SOURCES,CONFIG)
  end

  asserts("generates an Rsync object") {topic.is_a? TimeMachine::Rsync}
  asserts("has source directory'") {File.directory? TEST_DATA}
  asserts("has source data'") {File.exist?(File.join(TEST_DATA,"home/a"))}
  asserts("has destination directory'") {File.directory? MOUNT_POINT}

  context "command for #{TEST_DATA}" do
    setup { topic.command(TEST_DATA) }
    %w[ --one-file-system --modify-window=1 --archive ].each do |switch|
      asserts("should have #{switch}") {!!topic.match(switch)}
    end
  end

  context "should run" do
    hookup {
      @backup_dir = File.join(MOUNT_POINT, "latest", TEST_DATA)
      topic.run
    }

    %w[ /home/a /home/b /home/c /home/d/a ].each do |f|
      asserts("that it does back up #{f}") {
        File.exist?(File.join(@backup_dir, f))
      }
    end

    %w[ /tmp/a /tmp2/a ].each do |f|
      asserts("that it excludes #{f}") {
        !File.exist?(File.join(@backup_dir, f))
      }
    end

    # TODO: check permissions of top level directory.

    teardown { destroy_data }
  end

end

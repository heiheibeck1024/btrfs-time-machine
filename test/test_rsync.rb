require 'test_helper'

sources = YAML.parse(<<-EOF).to_ruby
- source: '#{DATA_SOURCE}'
  one-filesystem: true
  exclusions:
    - './tmp2'
    - 'tmp'
  rsync_options:
    - "--modify-window=1"
EOF

config = YAML.parse(<<-EOF).to_ruby
dest_device_uuid: 'xxxx'
backup_mount_point: '#{DATA_DESTINATION}'
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
    # clean up from last run
    FileUtils::rm_rf "#{DATA_DESTINATION}/*"
    FileUtils::mkdir_p DATA_DESTINATION
    FileUtils::rm_rf File.join(DATA_SOURCE, "/1")

    %w[home/d tmp tmp2].each do |d|
      FileUtils::mkdir_p(File.join(DATA_SOURCE, "1", d))
    end

    %w[home/a home/b home/c tmp/a /tmp2/a /home/d/a].each do |f|
      FileUtils::touch(File.join(DATA_SOURCE, "1", f))
    end

    TimeMachine::Rsync.new(sources[0],config)
  end

  asserts("has correct number of options") {topic.options.size}.equals 13
  asserts("has '--modify-window=1'") {topic.options.include? '--modify-window=1'}
  asserts("has source directory'") {File.directory? DATA_SOURCE}
  asserts("has source data'") {File.exist?(File.join(DATA_SOURCE,"1/home/a"))}
  asserts("has destination directory'") {File.directory? DATA_DESTINATION}

  context "should run" do
    hookup {
      @backup_dir = File.join(DATA_DESTINATION, "latest", DATA_SOURCE, "1")
      puts @backup_dir
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
  end

end

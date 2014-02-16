require 'test_helper'

context "#TimeMachine::Rsync" do
  hookup do
    create_data
  end

  context "without any sources" do
    setup do
      config = { "backup_mount_point" => MOUNT_POINT }
      settings = TimeMachine::Settings.new(config)
      TimeMachine::Rsync.new(settings)
    end

    asserts(:options).kind_of Hash
    asserts(:commands).kind_of Array
    asserts(:options).empty
    asserts(:commands).empty
  end

  context "with default settings" do
    setup do
      config = { "backup_mount_point" => MOUNT_POINT }
      settings = TimeMachine::Settings.new(config)
      settings.add_source({ "path" => TEST_DATA }) 
      TimeMachine::Rsync.new(settings)
    end

    asserts("default option"){topic.options[TEST_DATA]}.includes {"--acls"}
    asserts("default option"){topic.options[TEST_DATA]}.includes {"--archive"}
    asserts("default option"){topic.options[TEST_DATA]}.includes {"--delete"}
    asserts("default option"){topic.options[TEST_DATA]}.includes {"--delete-excluded"}
    asserts("default option"){topic.options[TEST_DATA]}.includes {"--human-readable"}
    asserts("default option"){topic.options[TEST_DATA]}.includes {"--inplace"}
    asserts("default option"){topic.options[TEST_DATA]}.includes {"--no-whole-file"}
    asserts("default option"){topic.options[TEST_DATA]}.includes {"--numeric-ids"}
    asserts("default option"){topic.options[TEST_DATA]}.includes {"--verbose"}
    asserts("default option"){topic.options[TEST_DATA]}.includes {"--xattrs"}
    asserts("extra option"){topic.options[TEST_DATA]}.includes {"--one-file-system"}
  end

  context "with exclusions" do
    setup do
      config = { "backup_mount_point" => MOUNT_POINT }
      settings = TimeMachine::Settings.new(config)
      settings.add_source({ "path" => TEST_DATA, "exclusions" => [ "/blah", "/blah2" ]}) 
      TimeMachine::Rsync.new(settings)
    end

    asserts("options"){topic.options[TEST_DATA]}.includes {"--exclude /blah"}
    asserts("options"){topic.options[TEST_DATA]}.includes {"--exclude /blah2"}
  end


end

#  asserts("generates an Rsync object") {topic.is_a? TimeMachine::Rsync}
#  asserts("has source directory'") {File.directory? TEST_DATA}
#  asserts("has source data'") {File.exist?(File.join(TEST_DATA,"home/a"))}
#  asserts("has destination directory'") {File.directory? MOUNT_POINT}
#
#  context "command for #{TEST_DATA}" do
#    setup { topic.command(TEST_DATA) }
#    %w[ --one-file-system --modify-window=1 --archive ].each do |switch|
#      asserts("should have #{switch}") {!!topic.match(switch)}
#    end
#  end
#
#  context "should run" do
#    hookup {
#      @backup_dir = File.join(MOUNT_POINT, "latest", TEST_DATA)
#      topic.run
#    }
#
#    %w[ /home/a /home/b /home/c /home/d/a ].each do |f|
#      asserts("that it does back up #{f}") {
#        File.exist?(File.join(@backup_dir, f))
#      }
#    end
#
#    %w[ /tmp/a /tmp2/a ].each do |f|
#      asserts("that it excludes #{f}") {
#        !File.exist?(File.join(@backup_dir, f))
#      }
#    end
#
#    # TODO: check permissions of top level directory.
#
#    teardown { destroy_data }
#  end
#
#end

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
    asserts(:commands).kind_of Array
    asserts(:commands).size 1
    asserts("first command") {topic.commands.first}.equals "/usr/bin/rsync --acls --archive --delete --delete-excluded --human-readable --inplace --no-whole-file --numeric-ids --verbose --xattrs --one-file-system /tmp/test-tm/mnt/latest/tmp/test-tm/src"
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
    asserts("first command") {topic.commands.first}.equals "/usr/bin/rsync --acls --archive --delete --delete-excluded --human-readable --inplace --no-whole-file --numeric-ids --verbose --xattrs --one-file-system --exclude /blah --exclude /blah2 /tmp/test-tm/mnt/latest/tmp/test-tm/src"
  end

  context "with inclusions" do
    setup do
      config = { "backup_mount_point" => MOUNT_POINT }
      settings = TimeMachine::Settings.new(config)
      settings.add_source({ "path" => TEST_DATA, "inclusions" => [ "/blah", "/blah2" ]})
      TimeMachine::Rsync.new(settings)
    end

    asserts("options"){topic.options[TEST_DATA]}.includes {"--include /blah"}
    asserts("options"){topic.options[TEST_DATA]}.includes {"--include /blah2"}
    asserts("first command") {topic.commands.first}.equals "/usr/bin/rsync --acls --archive --delete --delete-excluded --human-readable --inplace --no-whole-file --numeric-ids --verbose --xattrs --one-file-system --include /blah --include /blah2 /tmp/test-tm/mnt/latest/tmp/test-tm/src"
  end

  context "with inclusions and exclusions" do
    setup do
      config = { "backup_mount_point" => MOUNT_POINT }
      settings = TimeMachine::Settings.new(config)
      settings.add_source({ "path" => TEST_DATA, "inclusions" => ["/a"], "exclusions" => ["/b"] })
      TimeMachine::Rsync.new(settings)
    end

    asserts("options"){topic.options[TEST_DATA]}.includes {"--include /a"}
    asserts("options"){topic.options[TEST_DATA]}.includes {"--exclude /b"}
    asserts("include is before exclude") {topic.commands.first}.matches {%r{--include.*--exclude}}
  end
end

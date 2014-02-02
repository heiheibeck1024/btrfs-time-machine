require 'test_helper'

context "#TimeMachine::Btrfs" do
  setup {
    TimeMachine::Btrfs.new(BTRFS_FILE_SYSTEM, MOUNT_POINT)
  }

  asserts("is not mounted") {!topic.mounted?}

  context "after mounting" do
    hookup { topic.mount }
    asserts("is now mounted") {topic.mounted?}

    context "then unmounting" do
      hookup { topic.umount }
      asserts("is now mounted") {!topic.mounted?}
    end
  end
end

require 'test_helper'

context "#TimeMachine::FileSystem - btrfs filesystem" do
  setup {
    TimeMachine::FileSystem.new(BTRFS_FS, MOUNT_POINT)
  }

  asserts("is not mounted") {!topic.mounted?}
  asserts("has unknown btrfs_volume?") {topic.btrfs_volume?.nil?}
  asserts("has unknown read_only?") {topic.read_only?.nil?}

  context "after mounting" do
    hookup { topic.mount }
    asserts("is now mounted") {topic.mounted?}
    asserts("is a btrfs volume") {topic.btrfs_volume?}
    asserts("is read-write") {!topic.read_only?}
  end

  context "after remounting" do
    hookup { topic.remount(["ro"])}
    asserts("is now mounted") {topic.mounted?}
    asserts("is a btrfs volume") {topic.btrfs_volume?}
    asserts("is read-only") {topic.read_only?}
  end

  context "after unmounting" do
    hookup { topic.umount }
    asserts("is now unmounted") {!topic.mounted?}
    asserts("has unknown btrfs_volume") {topic.btrfs_volume?.nil?}
    asserts("has unknown read_only?") {topic.read_only?.nil?}
  end
end

context "#TimeMachine::FileSystem - ext4 filesystem" do
  setup {
    TimeMachine::FileSystem.new(EXT4_FS, MOUNT_POINT)
  }

  asserts("is not mounted") {!topic.mounted?}
  asserts("has unknown btrfs_volume?") {topic.btrfs_volume?.nil?}
  asserts("has unknown read_only?") {topic.read_only?.nil?}

  context "after mounting" do
    hookup { topic.mount }
    asserts("is now mounted") {topic.mounted?}
    asserts("is not a btrfs volume") {!topic.btrfs_volume?}
    asserts("is read-write") {!topic.read_only?}
  end

  context "after remounting" do
    hookup { topic.remount(["ro"])}
    asserts("is now mounted") {topic.mounted?}
    asserts("is not a btrfs volume") {!topic.btrfs_volume?}
    asserts("is read-only") {topic.read_only?}
  end

  context "after unmounting" do
    hookup { topic.umount }
    asserts("is now unmounted") {!topic.mounted?}
    asserts("has unknown btrfs_volume") {topic.btrfs_volume?.nil?}
    asserts("has unknown read_only?") {topic.read_only?.nil?}
  end

end

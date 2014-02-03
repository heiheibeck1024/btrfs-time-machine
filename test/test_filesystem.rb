require 'test_helper'

context "#TimeMachine::FileSystem - btrfs filesystem" do
  setup {
    TimeMachine::FileSystem.new(BTRFS_FS, MOUNT_POINT)
  }

  asserts("is not mounted") {!topic.mounted?}
  asserts("mount_options is nil") {topic.mount_options.nil?}
  asserts("unmounting unmounted is nil") {topic.umount.nil?}
  asserts("has unknown btrfs_volume?") {topic.btrfs_volume?.nil?}
  asserts("has unknown read_only?") {topic.read_only?.nil?}
  asserts("mount_options is false") {!topic.mount_options}

  context "after mounting" do
    hookup { topic.mount }
    # test mounting a filesystem on top of a mounted filesystem
    asserts("is now mounted")       {topic.mounted?}
    asserts("is a btrfs volume")    {topic.btrfs_volume?}
    asserts("is read-write")        {!topic.read_only?}
    asserts("can not delete non-existant subvolume") {!topic.btrfs_subvolume_delete "x"}
  end

  context "create subvolume" do
    hookup {topic.btrfs_subvolume_create "test"}
    asserts("has a test directory") {Dir.entries(MOUNT_POINT).include? "test"}
    asserts("has test subvolume")   {topic.btrfs_subvolumes.include? "test"}
  end

  context "take read-only snapshot" do
    hookup { topic.btrfs_snapshot_create("test", "rosnap", {:read_only=>true} ) }
    asserts("has a rosnap directory") {Dir.entries(MOUNT_POINT).include? "rosnap"}
    asserts("is read-write")        {!topic.read_only?}
  end

  #context "take read-write snapshot" do
  #end


  context "delete subvolume" do
    hookup {topic.btrfs_subvolume_delete "test"}
    asserts("has no test directory") {!Dir.entries(MOUNT_POINT).include? "test"}
    asserts("has no test subvolume") {!topic.btrfs_subvolumes.include? "test"}
  end

  context "after remounting" do
    hookup { topic.remount(["ro"])}
    asserts("is now mounted")       {topic.mounted?}
    asserts("is a btrfs volume")    {topic.btrfs_volume?}
    asserts("is read-only")         {topic.read_only?}
  end

  context "after unmounting" do
    hookup { topic.umount }
    asserts("is now unmounted") {!topic.mounted?}
    #asserts("has unknown btrfs_volume") {topic.btrfs_volume?.nil?}
    #asserts("has unknown read_only?") {topic.read_only?.nil?}
  end
end

#context "#TimeMachine::FileSystem - ext4 filesystem" do
#  setup {
#    TimeMachine::FileSystem.new(EXT4_FS, MOUNT_POINT)
#  }
#
#  asserts("is not mounted") {!topic.mounted?}
#  asserts("has unknown btrfs_volume?") {topic.btrfs_volume?.nil?}
#  asserts("has unknown read_only?") {topic.read_only?.nil?}
#
#  context "after mounting" do
#    hookup { topic.mount }
#    asserts("is now mounted") {topic.mounted?}
#    asserts("is not a btrfs volume") {!topic.btrfs_volume?}
#    asserts("is read-write") {!topic.read_only?}
#  end
#
#  context "after remounting" do
#    hookup { topic.remount(["ro"])}
#    asserts("is now mounted") {topic.mounted?}
#    asserts("is not a btrfs volume") {!topic.btrfs_volume?}
#    asserts("is read-only") {topic.read_only?}
#  end
#
#  context "after unmounting" do
#    hookup { topic.umount }
#    asserts("is now unmounted") {!topic.mounted?}
#    asserts("has unknown btrfs_volume") {topic.btrfs_volume?.nil?}
#    asserts("has unknown read_only?") {topic.read_only?.nil?}
#  end
#
#end

require 'test_helper'

context "#TimeMachine::FileSystem - btrfs filesystem" do
  setup {
    setup_file_systems
    TimeMachine::FileSystem.new(BTRFS_FS, MOUNT_POINT)
  }

  denies("is not mounted") {topic.mounted?}
  asserts("mount_options is empty") {topic.mount_options.empty?}
  asserts("unmounting unmounted is true") {topic.umount}
  asserts("btrfs_volume? is nil") {topic.btrfs_volume?.nil?}
  asserts("read_only? is nil") {topic.read_only?.nil?}
  asserts("subvolumes is empty") {topic.btrfs_subvolumes.empty?}
  denies("create subvolume in invalid filesystem") {topic.btrfs_subvolume_create "/tmp/blah"}

  context "after mounting" do
    hookup { topic.mount }
    # TODO: test mounting a filesystem on top of a mounted filesystem
    asserts("is now mounted")       {topic.mounted?}
    asserts("is a btrfs volume")    {topic.btrfs_volume?}
    denies("is read-write")         {topic.read_only?}
    asserts("delete non-existant subvolume") {topic.btrfs_subvolume_delete "x"}
    asserts("subvolumes is empty") {topic.btrfs_subvolumes.empty?}
  end

  context "create subvolume" do
    hookup {topic.btrfs_subvolume_create "test"}
    asserts("has a test directory") {Dir.entries(MOUNT_POINT).include? "test"}
    asserts("has test subvolume")   {topic.btrfs_subvolumes.include? "test"}
    asserts("subvolume is mounted") {topic.mounted? "test"}
  end

  context "take read-only snapshot" do
    hookup { topic.btrfs_snapshot_create("test", "rosnap", {:read_only=>true} ) }
    asserts("has a rosnap directory") {Dir.entries(MOUNT_POINT).include? "rosnap"}
    asserts("is read-only")        {topic.read-only?("rosnap")}
    asserts("mount options")       {topic.mount_options("rosnap").empty?}
  end

  context "take read-write snapshot" do
    hookup { topic.btrfs_snapshot_create("test", "rwsnap", {:read_only=>false} ) }
    asserts("has a rwsnap directory") {Dir.entries(MOUNT_POINT).include? "rwsnap"}
    denies("is not read-only")        {topic.read_only?("rwsnap")}
  end

  context "delete subvolume" do
    hookup {topic.btrfs_subvolume_delete "test"}
    asserts("has no test directory") {!Dir.entries(MOUNT_POINT).include? "test"}
    denies("has no test subvolume") {topic.btrfs_subvolumes.include? "test"}
  end

  context "delete read-only snapshot" do
    hookup {topic.btrfs_snapshot_delete "rosnap"}
    denies("has no rosnap directory") {Dir.entries(MOUNT_POINT).include? "rosnap"}
    denies("has no rosnap subvolume") {topic.btrfs_subvolumes.include? "rosnap"}
  end

  context "delete read-write snapshot" do
    hookup {topic.btrfs_snapshot_delete "rwsnap"}
    denies("has no rwsnap directory") {Dir.entries(MOUNT_POINT).include? "rwsnap"}
    denies("has no rwsnap subvolume") {topic.btrfs_subvolumes.include? "rwsnap"}
  end

  # TODO: get list of snapshots.
  # TODO: get snapshot date.

  context "after remounting" do
    hookup { topic.remount(["ro"])}
    asserts("is now mounted")       {topic.mounted?}
    asserts("is a btrfs volume")    {topic.btrfs_volume?}
    asserts("is read-only")         {topic.read_only?}
  end

  context "after unmounting" do
    hookup { topic.umount }
    denies("is now unmounted") {topic.mounted?}
  end
end

context "#TimeMachine::FileSystem - ext4 filesystem" do
  setup {
    TimeMachine::FileSystem.new(EXT4_FS, MOUNT_POINT)
  }

  denies("is not mounted") {topic.mounted?}
  asserts("has unknown btrfs_volume?") {topic.btrfs_volume?.nil?}
  asserts("has unknown read_only?") {topic.read_only?.nil?}

  context "after mounting" do
    hookup { topic.mount }
    asserts("is now mounted") {topic.mounted?}
    denies("is not a btrfs volume") {topic.btrfs_volume?}
    denies("is read-write") {topic.read_only?}
  end

  context "after remounting" do
    hookup { topic.remount(["ro"])}
    asserts("is now mounted") {topic.mounted?}
    denies("is not a btrfs volume") {topic.btrfs_volume?}
    asserts("is read-only") {topic.read_only?}
  end

  context "after unmounting" do
    hookup { topic.umount }
    denies("is now mounted") {topic.mounted?}
    asserts("has unknown btrfs_volume") {topic.btrfs_volume?.nil?}
    asserts("has unknown read_only?") {topic.read_only?.nil?}
  end

end

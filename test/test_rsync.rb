require 'test_helper'

settings = TimeMachine::Settings.new({
  :config => "test/config/config1.yml",
  :sources => "test/config/sources1.yml"
})

context "#TimeMachine::Rsync" do
  setup do
    destination = File.dirname(__FILE__) + "/tmp"
    source = File.dirname(__FILE__) + "/data/1"
    
    %w[home/d tmp tmp2].each {|d| FileUtil::mkdir_p(File.join(source, d))}
    %w[home/a home/b home/c tmp/a /tmp2/a].each do |f|
      FileUtil::touch(File.join(source, f))
    end

    TimeMachine::Rsync.new(settings.sources[0],settings.config)
  end

  asserts("has correct number of options") {topic.options.size}.equals 11

  context "run an rsync" do
    hookup {topic.rsync}
    asserts("excluded relative path does not exist") {!Dir.exist?().include? "test"}
    asserts("has test subvolume")   {topic.btrfs_subvolumes.include? "test"}
    asserts("subvolume is mounted") {topic.mounted? "test"}
  end

  # make sure that /tmp/a does not exist
  # make sure that /tmp2/a does not exist

  # make sure that /home/a does exist
  # make sure that /home/b does exist
  # make sure that /home/c does exist

  # make sure that /home/d/a does exist

  teardown do
    FileUtil::rm_r File.join(source, "*")
  end
end



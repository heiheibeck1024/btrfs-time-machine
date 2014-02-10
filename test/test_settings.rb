require 'test_helper'


context "#TimeMachine::Settings" do
  setup do
    config = YAML.parse(<<-EOF).to_ruby
      String: 'string'
      Fixnum: 2
      TrueClass: true
      FalseClass: false
      Hash:
        a: 'a'
        b: 'b'
      Array:
        - "a"
        - "b"
    EOF
    TimeMachine::Settings.new(config)
  end

  context "basic handling of" do
    context "global settings" do
      asserts(:sources).empty

      [ String, Fixnum, TrueClass, FalseClass, NilClass, Hash, Array, ].each do |type|
        t = type.to_s
        asserts(type) {topic.global_settings[t]}.kind_of type

        if type == Array
          asserts(t) { topic.global_settings[type.to_s] }.size 2
          asserts(t+"[0]") {topic.global_settings[type.to_s][0]}.equals "a"
          asserts(t+"[1]") {topic.global_settings[type.to_s][1]}.equals "b"
        end

        if type == Hash
          asserts(t) { topic.global_settings[t] }.size 2
          asserts(t+"['a']") {topic.global_settings[t]["a"]}.equals "a"
          asserts(t+"['b']") {topic.global_settings[t]["b"]}.equals "b"
        end
      end
    end

    context "sources settings" do
      hookup do
        topic.add_source(YAML.parse(<<-EOF).to_ruby
          sources:
            - path: '/a/test'
              String: 'string'
              Fixnum: 2
              TrueClass: true
              FalseClass: false
              Hash:
                a: 'a'
                b: 'b'
              Array:
                - "a"
                - "b"
          EOF
        )
      end

      denies(:global_settings).empty
      asserts(:sources).size(1)

      context "data" do
        setup {topic.source_settings(topic.sources.first)}
        asserts("path") {topic}.equals "/a/test"
      end
    end
  end
end

        #asserts("source_settings is a ") {topic.is_a? Array}
        #asserts("source_settings size") {topic.source_settings.size}.equals 1
        #asserts("source_settings.first is a Hash") {topic.source_settings.first.class.to_s}.equals "String"

      #%w[ String Fixnum TrueClass FalseClass NilClass Hash Array ].each do |type|
      #  asserts("#{type} is correct class") {
      #    topic.sources[type].class.to_s
      #  }.equals type

      #  if type == "Array"
      #    asserts("#{type} size") { topic.sources[type].size }.equals 2
      #    asserts("#{type}[0]") {topic.sources[type][0]}.equals "a"
      #    asserts("#{type}[1]") {topic.sources[type][1]}.equals "b"
      #  end

      #  if type == "Hash"
      #    asserts("#{type} size") { topic.sources[type].size }.equals 2
      #    asserts("#{type}['a']") {topic.sources[type]["a"]}.equals "a"
      #    asserts("#{type}['b']") {topic.sources[type]["b"]}.equals "b"
      #  end
      #end



#context "#TimeMachine::Settings" do
#  setup do
#    config = YAML.parse(<<-EOF).to_ruby
#      dest_device_uuid: 'xxxx'
#      backup_mount_point: '#{MOUNT_POINT}'
#      log_file: '/dev/null'
#      mount_options:
#         - compress
#      rsync_options:
#        - "--max-size 2G"
#      snapshot_max_age: 48
#      deduplicate: true
#      lock_file: '/var/lock/time_machine'
#      alert_email: 'someone@somewhere.com'
#      global_false: false
#      global_true: true
#
#      sources:
#        - source: '#{TEST_DATA}'
#          one-filesystem: true
#          exclusions:
#            - './tmp2'
#            - 'tmp'
#          rsync_options:
#            - "--modify-window=1"
#          source_false: false
#          source_true: true
#        - source: '/tmp'
#        - source: '/etc/passwd'
#    EOF
#
#    TimeMachine::Settings.new(config)
#  end
#
#
#  asserts_topic.kind_of TimeMachine::Settings
#  asserts("to_hash") {topic.to_hash}.kind_of Hash
#  asserts("sources") {topic.sources}.kind_of Array
#
#  context "sources" do
#    asserts("size") {topic.sources.size}.equals 3
#    asserts("has key of #{TEST_DATA}") {topic.sources.include? TEST_DATA}
#    asserts("has key of /etc/passwd") {topic.sources.include? "/etc/passwd"}
#    asserts("has key of /tmp") {topic.sources.include? "/tmp"}
#  end
#
#  context "global_settings" do
#    asserts("has backup_mount_point") {topic.global_settings.has_key? "backup_mount_point"}
#    asserts("has mount_options") {topic.global_settings.has_key? "mount_options"}
#    asserts("mount_options is an array") {topic.global_settings["mount_options"].is_a?(Array)}
#    asserts("has no sources") {!topic.global_settings.has_key? "sources"}
#    asserts("has deduplicate") {topic.global_settings["deduplicate"]}
#    asserts("has a global_false") {!topic.global_settings["global_false"]}
#    asserts("has a global_true") {topic.global_settings["global_true"]}
#  end
#
#  context "source_settings for #{TEST_DATA}" do
#    asserts("is a hash") { topic.source_settings(TEST_DATA).is_a? Hash }
#    asserts("has exclusions") { topic.source_settings(TEST_DATA).has_key?("exclusions") }
#    asserts("cleaned exclusion path")   {topic.source_settings(TEST_DATA)["exclusions"].include?("tmp2")}
#    asserts("has global deduplicate") {topic.source_settings(TEST_DATA)["deduplicate"]}
#    asserts("has global global_false") {!topic.global_settings["global_false"]}
#    asserts("has global global_true") {!topic.global_settings["global_true"]}
#    asserts("has global lock_file")     {topic.source_settings(TEST_DATA)["lock_file"] }.equals "/var/lock/time_machine"
#    asserts("has global mount_options") {topic.source_settings(TEST_DATA)["mount_options"].include?("compress")}
#    asserts("has global rsync_options") {topic.source_settings(TEST_DATA)["rsync_options"].include?("--max-size 2G")}
#    asserts("has source one-filesystem"){topic.source_settings(TEST_DATA)["one-filesystem"]}
#    asserts("has source rsync_options") {topic.source_settings(TEST_DATA)["rsync_options"].include?("--modify-window=1")}
#    asserts("has source source_false") {!topic.global_settings["source_false"]}
#    asserts("has source source_true") {topic.global_settings["source_true"]}
#    asserts("has destination") {topic.source_settings(TEST_DATA)["destination"]}.equals "#{MOUNT_POINT}/latest/tmp/test-tm/src"
#  end
#
#  context "rsync_options for #{TEST_DATA}" do
#    asserts("default option is included") { topic.rsync_options(TEST_DATA).include? "--acls" }
#    asserts("global option is included") { topic.rsync_options(TEST_DATA).include? "--max-size 2G" }
#    asserts("source option is included") { topic.rsync_options(TEST_DATA).include? "--modify-window=1" }
#    asserts("tmp2 is excluded") { topic.rsync_options(TEST_DATA).include? "--exclude tmp2" }
#  end
#end

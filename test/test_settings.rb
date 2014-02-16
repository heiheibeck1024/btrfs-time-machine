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
      backup_mount_point: /tmp/something
    EOF
    TimeMachine::Settings.new(config)
  end

  context "" do
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
          path: '/a/test'
          String: 'string'
          Fixnum: 2
          TrueClass: true
          FalseClass: false
          Hash:
            b: 'b'
            c: 'c'
          Array:
            - "b"
            - "c"
          EOF
        )
      end

      denies(:global_settings).empty
      asserts(:sources).size(1)
      asserts(:sources).kind_of Array
      asserts(:sources).equals ["/a/test"]
      denies("sources key in source_settings") {topic.source_settings("/a/test").has_key?("sources")}

      context "includes global settings" do
        hookup do
          topic.add_source(YAML.parse(<<-EOF).to_ruby
              path: '/b/test'
            EOF
          )
          @settings = topic.source_settings("/b/test")
        end

        asserts("String") {@settings["String"]}.equals "string"
        asserts("Fixnum") {@settings["Fixnum"]}.equals 2
        asserts("TrueClass") {@settings["TrueClass"]}
        denies("FalseClass") {@settings["FalseClass"]}
        asserts("Hash") {@settings["Hash"].to_s}.equals '{"a"=>"a", "b"=>"b"}'
        asserts("Array") {@settings["Array"]}.equals ['a', 'b' ]
        asserts("backup_mount_point") {@settings["backup_mount_point"]}.equals "/tmp/something"
        asserts("exclusions") {@settings["exclusions"]}.empty
        asserts("inclusions") {@settings["inclusions"]}.empty
      end

      context "includes new source settings" do
        hookup do
          topic.add_source(YAML.parse(<<-EOF).to_ruby
              path: '/c/test'
              newString: 'string'
              newFixnum: 2
              newTrueClass: true
              newFalseClass: false
              newHash:
                a: 'a'
                b: 'b'
              newArray:
                - "a"
                - "b"
              Hash:
                c: "c"
              Array:
                - "c"
            EOF
          )
          @settings = topic.source_settings("/c/test")
        end

        asserts(:sources).includes "/c/test"
        asserts("path") {@settings["path"]}.equals "/c/test"
        asserts("newString") {@settings["newString"]}.equals "string"
        asserts("newFixnum") {@settings["newFixnum"]}.equals 2
        asserts("newTrueClass") {@settings["newTrueClass"]}
        denies("newFalseClass") {@settings["newFalseClass"]}
        asserts("newHash") {@settings["newHash"].to_s}.equals '{"a"=>"a", "b"=>"b"}'
        asserts("newArray") {@settings["newArray"]}.equals ['a', 'b' ]
        asserts("Hash['c']") {@settings["Hash"]["c"]}.equals "c"
        asserts("Array") {@settings["Array"]}.includes "c"
      end

      context "source settings override global settings" do
        hookup do
          topic.add_source(YAML.parse(<<-EOF).to_ruby
            path: '/d/test'
            String: 'changed_string'
            Fixnum: 3
            TrueClass: false
            FalseClass: true
            Hash:
              a: 'aa'
              b: 'bb'
            EOF
          )
          @settings = topic.source_settings("/d/test")
        end

        asserts("String") {@settings["String"]}.equals "changed_string"
        asserts("Fixnum") {@settings["Fixnum"]}.equals 3
        denies("TrueClass") {@settings["TrueClass"]}
        asserts("FalseClass") {@settings["FalseClass"]}
        asserts("Hash") {@settings["Hash"].to_s}.equals '{"a"=>"aa", "b"=>"bb"}'
        asserts("backup_mount_point") {@settings["backup_mount_point"]}.equals "/tmp/something"
      end

      context "source settings without exclusions" do
        hookup { @settings = topic.source_settings("/d/test") }
        asserts("exclusions") {@settings["exclusions"]}.kind_of Array
        asserts("exclusions") {@settings["exclusions"]}.empty
      end

      context "source settings without inclusions" do
        hookup { @settings = topic.source_settings("/d/test") }
        asserts("exclusions") {@settings["inclusions"]}.kind_of Array
        asserts("exclusions") {@settings["inclusions"]}.empty
      end

      context "source settings with exclusions" do
        hookup do
          topic.add_source(YAML.parse(<<-EOF).to_ruby
            path: '/e/test'
            exclusions:
              - "/tmp/a"
              - "/tmp/b"
            EOF
          )
          @settings = topic.source_settings("/e/test")
        end

        asserts("exclusions") {@settings["exclusions"]}.size 2
        asserts("exclusions") {@settings["exclusions"]}.includes "/tmp/a"
        asserts("exclusions") {@settings["exclusions"]}.includes "/tmp/b"
      end

      context "source settings with inclusions" do
        hookup do
          topic.add_source(YAML.parse(<<-EOF).to_ruby
            path: '/e/test'
            inclusions:
              - "/tmp/a"
              - "/tmp/b"
            EOF
          )
          @settings = topic.source_settings("/e/test")
        end

        asserts("inclusions") {@settings["inclusions"]}.size 2
        asserts("inclusions") {@settings["inclusions"]}.includes "/tmp/a"
        asserts("inclusions") {@settings["inclusions"]}.includes "/tmp/b"
        asserts("destination"){@settings["destination"]}.equals "/tmp/something/latest/e/test"
      end

      context "source settings when backing up root" do
        hookup do
          topic.add_source(YAML.parse(<<-EOF).to_ruby
            path: '/'
            EOF
          )
          @settings = topic.source_settings("/")
        end

        asserts("destination") {@settings["destination"]}.equals "/tmp/something/latest/root"
      end
    end
  end

  context "exceptions" do
    context "for settings object" do
      setup {TimeMachine::Settings }
      asserts("for config") {topic.new}.raises(ArgumentError)
      asserts("for config") {topic.new({})}.raises(RuntimeError, 'Your config must include \'backup_mount_point\'.')
    end

    context "for method" do
      setup do
        @topic = TimeMachine::Settings.new({'backup_mount_point' => '/tmp/a/'})
        @topic.add_source({'path' => '/tmp/primed'})
        @topic
      end
      asserts("add_source without argument") {topic.add_source}.raises(ArgumentError)
      asserts("add_source without path") {topic.add_source({})}.raises(RuntimeError, 'Your config must include \'path\'.')
      asserts("add_source with existing path") {topic.add_source({'path' => '/tmp/primed'})}.raises(RuntimeError, 'You already have a source at that path')
      # TODO: getting a source that doesn't exist.
    end
  end
end

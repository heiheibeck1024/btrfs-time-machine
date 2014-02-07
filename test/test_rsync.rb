require 'test_helper'

settings = TimeMachine::Settings.new({
  :config => "test/config/config1.yml",
  :sources => "test/config/sources1.yml"
})

context "#TimeMachine::Rsync" do
  setup { TimeMachine::Rsync.new(settings.sources[0],settings.config) }
  asserts("have only default options") {topic.options.size}.equals 8

  asserts("exclusions have rsync compatible path") {topic.exclusions}.equals ["Dropbox", "tmp"]
end


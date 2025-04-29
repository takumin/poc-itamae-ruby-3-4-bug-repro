require 'spec_helper'

describe file('/tmp/file_with_content_change_updates_timestamp') do
  its(:mtime) { should be > DateTime.iso8601("2016-05-02T01:23:45Z") }
end

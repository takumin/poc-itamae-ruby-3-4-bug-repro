# case 1

execute "f=/tmp/file_edit_with_content_change_updates_timestamp && echo 'Hello, world' > $f && touch -d 2016-05-02T01:23:45Z $f"

file "/tmp/file_edit_with_content_change_updates_timestamp" do
  action :edit
  block do |content|
    content.gsub!('world', 'Itamae')
  end
end

# case 2

execute "touch -d 2016-05-01T01:23:45Z /tmp/file_with_content_change_updates_timestamp"

file "/tmp/file_with_content_change_updates_timestamp" do
  content "Hello, world"
end

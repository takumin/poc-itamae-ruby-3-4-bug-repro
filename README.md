# poc-itamae-ruby-3-4-bug-repro

Bug where time could not be handled correctly in a Docker environment with Ruby 3.4

see also: https://github.com/itamae-kitchen/itamae/issues/377

## Environment

```console
$ uname -a
Linux dsk 6.11.0-24-generic #24~24.04.1-Ubuntu SMP PREEMPT_DYNAMIC Tue Mar 25 20:14:34 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
$ cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=24.04
DISTRIB_CODENAME=noble
DISTRIB_DESCRIPTION="Ubuntu 24.04.2 LTS"
$ which ruby
/home/linuxbrew/.linuxbrew/bin/ruby
$ ruby -v
ruby 3.4.3 (2025-04-14 revision d0b7e5b6a0) +PRISM [x86_64-linux]
```

## How to reproduce

```console
$ git clone https://github.com/takumin/poc-itamae-ruby-3-4-bug-repro.git
$ cd poc-itamae-ruby-3-4-bug-repro
$ bundle config set bin '.bin'
$ bundle config set path '.bundle'
$ bundle install
$ bundle exec rake
```

## About

All tests pass in Ruby 3.3, but the following error occurs in Ruby 3.4:

<details>

<summary>Ruby 3.4 Serverspec log</summary>

### Ruby 3.4 Serverspec log

```
File "/tmp/file_edit_with_content_change_updates_timestamp"
  mtime
    is expected to be > 2016-05-02T01:23:45+00:00 (FAILED - 1)
```

```
File "/tmp/file_with_content_change_updates_timestamp"
  mtime
    is expected to be > 2016-05-01T01:23:45+00:00 (FAILED - 2)
```

```
Failures:

  1) File "/tmp/file_edit_with_content_change_updates_timestamp" mtime is expected to be > 2016-05-02T01:23:45+00:00
     Failure/Error: its(:mtime) { should be > DateTime.iso8601("2016-05-02T01:23:45Z") }
       expected: > #<DateTime: 2016-05-02T01:23:45+00:00 ((2457511j,5025s,0n),+0s,2299161j)>
            got:   #<DateTime: 1980-01-02T09:00:00+09:00 ((2444241j,0s,0n),+32400s,2299161j)>

     # ./spec/integration/default_spec.rb:287:in 'block (2 levels) in <top (required)>'

  2) File "/tmp/file_with_content_change_updates_timestamp" mtime is expected to be > 2016-05-01T01:23:45+00:00
     Failure/Error: its(:mtime) { should be > DateTime.iso8601("2016-05-01T01:23:45Z") }
       expected: > #<DateTime: 2016-05-01T01:23:45+00:00 ((2457510j,5025s,0n),+0s,2299161j)>
            got:   #<DateTime: 1980-01-02T09:00:00+09:00 ((2444241j,0s,0n),+32400s,2299161j)>

     # ./spec/integration/default_spec.rb:319:in 'block (2 levels) in <top (required)>'

Finished in 3.06 seconds (files took 0.23664 seconds to load)
153 examples, 2 failures, 2 pending

Failed examples:

rspec ./spec/integration/default_spec.rb:287 # File "/tmp/file_edit_with_content_change_updates_timestamp" mtime is expected to be > 2016-05-02T01:23:45+00:00
rspec ./spec/integration/default_spec.rb:319 # File "/tmp/file_with_content_change_updates_timestamp" mtime is expected to be > 2016-05-01T01:23:45+00:00
```

</details>

This is the code where I think the problem is occurring.

<details>

<summary>The code where the error occurs</summary>

### The code where the error occurs

[itamae/spec/integration/recipes/default.rb#L458-L465](https://github.com/itamae-kitchen/itamae/blob/57dfb50d93c836e77911bf3a592be8bd56ec21ba/spec/integration/recipes/default.rb#L458-L465)

```ruby:itamae/spec/integration/recipes/default.rb
execute "f=/tmp/file_edit_with_content_change_updates_timestamp && echo 'Hello, world' > $f && touch -d 2016-05-02T01:23:45Z $f"

file "/tmp/file_edit_with_content_change_updates_timestamp" do
  action :edit
  block do |content|
    content.gsub!('world', 'Itamae')
  end
end
```

[itamae/spec/integration/recipes/default.rb#L498-L502](https://github.com/itamae-kitchen/itamae/blob/57dfb50d93c836e77911bf3a592be8bd56ec21ba/spec/integration/recipes/default.rb#L498-L502)

```ruby:itamae/spec/integration/recipes/default.rb
execute "f=/tmp/file_edit_with_content_change_updates_timestamp && echo 'Hello, world' > $f && touch -d 2016-05-02T01:23:45Z $f"

file "/tmp/file_edit_with_content_change_updates_timestamp" do
  action :edit
  block do |content|
    content.gsub!('world', 'Itamae')
  end
end
```

[itamae/spec/integration/default_spec.ruby#L275-L277](https://github.com/itamae-kitchen/itamae/blob/57dfb50d93c836e77911bf3a592be8bd56ec21ba/spec/integration/default_spec.rb#L275-L277)

```ruby:itamae/spec/integration/default_spec.ruby
describe file('/tmp/file_edit_with_content_change_updates_timestamp') do
  its(:mtime) { should be > DateTime.iso8601("2016-05-02T01:23:45Z") }
end
```

[itamae/spec/integration/default_spec.ruby#L307-L309](https://github.com/itamae-kitchen/itamae/blob/57dfb50d93c836e77911bf3a592be8bd56ec21ba/spec/integration/default_spec.rb#L307-L309)

```ruby:itamae/spec/integration/default_spec.ruby
describe file('/tmp/file_with_content_change_updates_timestamp') do
  its(:mtime) { should be > DateTime.iso8601("2016-05-01T01:23:45Z") }
end
```

</details>

## TODO

- [x] Porting the itamae repository
- [x] Extract only the part where the error occurs
- [x] Minimal repro code
  - https://github.com/takumin/poc-itamae-ruby-3-4-bug-repro/tree/171c906372fc03f4a39a9f3a291a63459ee0a933
- [ ] Install Ruby 3.4 and Itamae in a Docker environment and test to see if the issue can be reproduced.

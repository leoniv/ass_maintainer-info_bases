[![Gem Version](https://badge.fury.io/rb/ass_maintainer-info_bases.svg)](https://badge.fury.io/rb/ass_maintainer-info_bases)
# AssMaintainer::InfoBases

Gem provides [infobase](https://github.com/leoniv/ass_maintainer-info_base)
classes proper for various use casess.

What is _infobase_ see
[ass_maintainer-infobase](https://github.com/leoniv/ass_maintainer-info_base)
project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ass_maintainer-info_bases'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ass_maintainer-info_bases

## Usage

### `TestInfoBase`

```ruby
  require 'ass_maintainer/info_bases/test_info_base'

  PLATFORM_REQUIRE = '~> 8.3.10.0'

  # Build application from xml src
  src = File.expand_path('../app.src')
  fixt = proc do |ib|
    # filling application data ...
  end


  ib = AssMaintainer::InfoBases::TestInfoBase
    .new('test_app', 'File="tmp/test_app"', false,
         template: src, fixtures: fixt, platform_require: PLATFORM_REQUIRE)
  ib.rebuild!(:yes)

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/leoniv/ass_maintainer-info_bases.

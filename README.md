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

### `class AssMaintainer::InfoBases::TestInfoBase`

Class for testing 1C:Enterprise application.

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

### `class AssMaintainer::InfoBases::TmpInfoBase`

Temporary infobase. Proper for cases when require make temporary
1C application do anything and remove after.
Temporary infobase is file infobase always. It makes in temporary
directory.

#### Simple example.

Convers application xml source to `.cf` file

```ruby
require 'ass_maintainer/info_bases/tmp_info_base'

PLATFORM_REQUIRE = '~> 8.3.10.0'

src = File.expand_path('../app.src', __FILE__)

# Do in the block with auto remove infobase
AssMaintainer::InfoBases::TmpInfoBase.make_rm src,
  platform_require: PLATFORM_REQUIRE do |ib|
  ib.db_cfg.dump('tmp/app.cf')
end

# Or remove infobase manually
tmp_ib = AssMaintainer::InfoBases::TmpInfoBase
  .new(src, platform_require: PLATFORM_REQUIRE)
tmp_ib.make
tmp_ib.db_cfg.dump('tmp/app.cf')
tmp_ib.rm!
```

#### More complex example.

Update application `.cf` file up to required version from update files `.cfu`

```ruby
require 'ass_maintainer/info_bases/tmp_info_base'

class Updater < AssMaintainer::InfoBases::TmpInfoBase
  def update_to(cfu_file, force = false)
    designer do
      _UpdateCfg cfu_file do
        _Force if force
      end
    end.run.wait.result.verify!
  end

  def self.execute(from_cf, cfu_files, cf_file, force = false)
    make_rm from_cf do |ib|
      cfu_files.each do |cfu|
        ib.update_to(cfu, force)
      end
      ib.cfg.dump(cfu_file)
    end
  end
end

from_cf = File.join(templates_root, 'vendor', 'app', '0', '1cv8.cf')
cf_file = 'tmp/app.v3.cf'

templates_root = 'path/to/1c/updates'
cfu_files = ['1','2','3'].map do |v|
  File.join(templates_root, 'vendor', 'app', v, '1cv8.cfu')
end

Updater.configure do |conf|
  conf.platform_require = '~> 8.3.10.0'
end

Updater.execute(from_cf, cfu_files, cf_file)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/leoniv/ass_maintainer-info_bases.

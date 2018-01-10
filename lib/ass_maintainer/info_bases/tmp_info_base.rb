module AssMaintainer
  module InfoBases
    require 'ass_maintainer/info_bases/test_info_base'
    require 'ass_maintainer/info_bases/support'
    # Temporary infobase. Proper for cases when require make temporary
    # 1C application do anything and remove after.
    # Temporary infobase is file infobase always. It makes in temporary
    # directory.
    # @example Convert application xml source to +.cf+ file
    #   require 'ass_maintainer/info_bases/tmp_info_base'
    #
    #   PLATFORM_REQUIRE = '~> 8.3.10.0'
    #
    #   src = File.expand_path('../app.src', __FILE__)
    #
    #   # Do in the block with auto remove infobase
    #   AssMaintainer::InfoBases::TmpInfoBase.make_rm src,
    #     platform_require: PLATFORM_REQUIRE do |ib|
    #     ib.db_cfg.dump('tmp/app.cf')
    #   end
    #
    #   # Or remove infobase manually
    #   tmp_ib = AssMaintainer::InfoBases::TmpInfoBase
    #     .new(src, platform_require: PLATFORM_REQUIRE)
    #   tmp_ib.make
    #   tmp_ib.db_cfg.dump('tmp/app.cf')
    #   tmp_ib.rm!
    #
    # @example Update application +.cf+ file up to required version from update files +.cfu+
    #    require 'ass_maintainer/info_bases/tmp_info_base'
    #
    #    class Updater < AssMaintainer::InfoBases::TmpInfoBase
    #      def update_to(cfu_file, force = false)
    #        designer do
    #          _UpdateCfg cfu_file do
    #            _Force if force
    #          end
    #        end.run.wait.result.verify!
    #      end
    #
    #      def self.execute(from_cf, cfu_files, cf_file, force = false)
    #        make_rm from_cf do |ib|
    #          cfu_files.each do |cfu|
    #            ib.update_to(cfu, force)
    #          end
    #          ib.cfg.dump(cfu_file)
    #        end
    #      end
    #    end
    #
    #    from_cf = File.join(templates_root, 'vendor', 'app', '0', '1cv8.cf')
    #    cf_file = 'tmp/app.v3.cf'
    #
    #    templates_root = 'path/to/1c/updates'
    #    cfu_files = ['1','2','3'].map do |v|
    #      File.join(templates_root, 'vendor', 'app', v, '1cv8.cfu')
    #    end
    #
    #    Updater.configure do |conf|
    #      conf.platform_require = '~> 8.3.10.0'
    #    end
    #
    #    Updater.execute(from_cf, cfu_files, cf_file)
    #
    class TmpInfoBase < AssMaintainer::InfoBases::TestInfoBase
      include Support::TmpPath
      extend Support::TmpPath

      # Mixin for convenience to use.
      # @example Convert application xml source to +.cf+ file
      #   require 'ass_maintainer/info_bases/tmp_info_base'
      #
      #   PLATFORM_REQUIRE = '~> 8.3.10.0'
      #
      #   # Convert application xml source to .cf file
      #   src = File.expand_path('../app.src', __FILE__)
      #
      #   include AssMaintainer::InfoBases::TmpInfoBase::Api
      #
      #   with_tmp_ib src, platform_require: PLATFORM_REQUIRE do |ib|
      #     ib.db_cfg.dump('tmp/app.cf')
      #   end
      module Api
        # (see AssMaintainer::InfoBases::TestInfoBase.make_rm)
        def with_tmp_ib(template = nil, **options, &block)
          AssMaintainer::InfoBases::TmpInfoBase
            .make_rm(template, **options, &block)
        end
      end

      # Make new tmp infoabse and yield it in block
      # after block executing remove tmp infobase
      def self.make_rm(template = nil, **options, &block)
        fail 'Block require' unless block_given?
        ib = new(template, **options)
        ib.make
        begin
          yield ib
        ensure
          ib.rm!
        end
      end

      def initialize(template = nil, **opts)
        opts_ = opts.dup
        opts_ = opts_.merge! template: template if template
        super *ArgsBuilder.new.args, **opts_
      end

      def rm!(*_)
        super :yes
      end

      # @api private
      class ArgsBuilder
        include Support::TmpPath
        include AssLauncher::Api
        def args
          [ib_name, ib_connstr, false]
        end

        def ib_connstr
          @ib_connstr ||= cs_file(file: ib_path)
        end

        def ib_name
          @ib_name ||= File.basename(tmp_path('ib')).gsub('-','_')
        end

        def ib_path
          @ib_path ||= File.join(Dir.tmpdir, ib_name)
        end
      end
    end
  end
end


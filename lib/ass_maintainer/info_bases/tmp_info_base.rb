module AssMaintainer
  module InfoBases
    require 'ass_maintainer/info_bases/test_info_base'
    require 'ass_maintainer/info_bases/support'
    # Temporary infobase.
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
    #
    # @example Generate application +.cf+ file required version from
    # update files +.cfu+
    #
    #
    class TmpInfoBase < AssMaintainer::InfoBases::TestInfoBase
      include Support::TmpPath

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


module AssMaintainer
  module InfoBases
    require 'ass_maintainer/info_base'
    # Class for testing 1C:Enterprise application.
    # It like {https://github.com/leoniv/ass_maintainer-info_base
    # AssMaintainer::InfoBase} but {#initialize} accepts two additional
    # {OPTIONS}:
    # - +:template+ - is template for infobase makes. Template can be +.cf+ or
    #   +.dt+ file path. Also +:template+ cat be path to application +xml+ files
    #   source or object which respons to +#src_root+ and returns path to +xml+
    #   files.
    # - +:fixtures+ - is object for filling testing application data.
    #   It object must implemets +#call+ method accepts {TestInfoBase} argumet
    # On default {TestInfoBase} suspects then application already exist and
    # marks {TestInfoBase} as +read_only+. It means that, on default,
    # +AssMaintainer::InfoBase::MethodDenied+ will be raised in
    # {#load_template!} and {#load_fixtures!} if +:template+ or +:fixtures+
    # options passed. It behavior is protection from destructive actions
    # with exists application. If you need build new application from template
    # or filling testing data, set +read_only == false+ explicitly!
    class TestInfoBase < AssMaintainer::InfoBase
      # see {#initialize}
      OPTIONS = {
        template: nil,
        fixtures: nil,
      }

      OPTIONS.each_key do |key|
        define_method key do
          options[key]
        end
      end

      ALL_OPTIONS = AssMaintainer::InfoBase::OPTIONS.merge OPTIONS

      # @param name [String]
      # @param connection_string [String AssLauncher::Support::ConnectionString]
      # @param read_only [false true] flag for read_only infobase
      # @option options [String #src_root] :template path to template like a
      #  +.cf+, +.dt+ file or dir of XML files. If respond to +#src_root+ then
      #  +#src_root+ must returns path to dir of XML files
      # @option options [#call] :fixtures object for fill infobase data.
      #  Must implemets method #call accepts {TestInfoBase} argumet
      # @note +options+ can includes other options defined for
      #  +AssMaintainer::InfoBase+
      def initialize(name, connection_string, read_only = true, **options)
        super name, connection_string, read_only
        @options = validate_options(options)
      end

      def validate_options(options)
        _opts = options.keys - ALL_OPTIONS.keys
        fail ArgumentError, "Unknown options: #{_opts}" unless _opts.empty?
        ALL_OPTIONS.merge(options)
      end
      private :validate_options

      # True if +:fixtures+ passed and {#load_template!} successfully
      # Nil unless +:template+
      def template_loaded?
        return unless template
        @template_loaded || false
      end

      # True if +:template+ passed and {#load_fixtures!} successfully
      # Nil unless +:fixtures+
      def fixtures_loaded?
        return unless fixtures
        @fixtures_loaded || false
      end

      # True if infobase exists and template and fixtures loaded if
      # +:template+, +:fixtures+ passed
      def built?
        exists? && true_if_nil(template_loaded?) &&\
          true_if_nil(fixtures_loaded?)
      end

      def true_if_nil(true_false)
        return true if true_false.nil?
        true_false
      end
      private :true_if_nil

      def make_infobase!
        super
        load_template!
        load_fixtures!
        self
      end
      private :make_infobase!

      # Load +:template+ to application.
      # @raise [AssMaintainer::InfoBase::MethodDenied] if +#read_only?+
      # @return [self]
      def load_template!
        fail AssMaintainer::InfoBase::MethodDenied, :load_template! if\
          read_only?
        @template_loaded = false
        load_template
        @template_loaded = true
        self
      end

      # Filling application data from +:fixtures+
      # @raise [AssMaintainer::InfoBase::MethodDenied] if +#read_only?+
      # @return [self]
      def load_fixtures!
        fail AssMaintainer::InfoBase::MethodDenied, :load_fixtures! if\
          read_only?
        @fixtures_loaded = false
        fixtures.call(self) if fixtures
        @fixtures_loaded = true
        self
      end

      # Erase application data.
      # @raise [AssMaintainer::InfoBase::MethodDenied] if +#read_only?+
      # @return [self]
      def erase_data!
        fail AssMaintainer::InfoBase::MethodDenied, :erase_data! if read_only?
        designer do
          eraseData
        end.run.wait.result.verify!
        self
      end

      # Erase application data and filling application data from +:fixtures+
      # @raise (see #erase_data!)
      # @raise (see #load_fixtures!)
      # @return [self]
      def reload_fixtures!
        erase_data!
        load_fixtures!
        self
      end

      # @api private
      # @return [Symbol] :cf, :df or :src
      def template_type
        return :cf if template_cf?
        return :dt if template_dt?
        return :src if template_src?
        template.to_s
      end

      # @api private
      def file_template?(ext)
        template.to_s =~ %r{\.#{ext}\z} && File.file?(template.to_s)
      end

      # @api private
      def template_cf?
        file_template? 'cf'
      end

      # @api private
      def template_dt?
        file_template? 'dt'
      end

      # @api private
      def template_src?
        File.file?(File.join(src_root, 'Configuration.xml')) if src_root
      end

      def src_root
        return template if template.is_a? String
        return template.src_root if template.respond_to?(:src_root)
      end
      private :src_root

      # @api private
      def load_template
        return unless template
        case template_type
        when :cf then load_cf
        when :dt then load_dt
        when :src then load_src
        else
          fail "Invalid template: #{template}"
        end
        template_type
      end

      # @api private
      def load_src
        cfg.load_xml(src_root) && db_cfg.update
      end

      # @api private
      def load_dt
        restore!(template)
      end

      # @api private
      def load_cf
        cfg.load(template) && db_cfg.update
      end
    end
  end
end

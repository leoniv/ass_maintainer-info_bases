require 'test_helper'
require 'ass_maintainer/info_bases/tmp_info_base'

module AssMaintainer::InfoBasesTest
  describe AssMaintainer::InfoBases::TmpInfoBase::ArgsBuilder do
    def inst
      @inst ||= AssMaintainer::InfoBases::TmpInfoBase::ArgsBuilder.new
    end

    it 'must include Support::TmpPath' do
      AssMaintainer::InfoBases::TmpInfoBase::ArgsBuilder
        .include? AssMaintainer::InfoBases::Support::TmpPath
    end

    it '#ib_name' do
      inst.expects(:tmp_path).returns('fake-path')
      inst.ib_name.must_equal 'fake_path'
    end

    it '#ib_path' do
      inst.expects(:tmp_path).returns('fake-path')
      inst.ib_path.must_equal File.join(Dir.tmpdir, 'fake_path')
    end

    it '#ib_connstr' do
      inst.expects(:tmp_path).returns('fake-path')
      inst.ib_connstr.to_s.must_equal "File=\"#{File.join(Dir.tmpdir, 'fake_path')}\";"
    end

    it '#args' do
      inst.args.must_equal [inst.ib_name, inst.ib_connstr, false]
    end
  end

  describe AssMaintainer::InfoBases::TmpInfoBase do
    describe 'Examples' do
      include AssMaintainer::InfoBases::Support::TmpPath

      describe 'Convert application xml source to .cf file' do
        include AssMaintainer::InfoBases::TmpInfoBase::Api

        after do
          FileUtils.rm_r cf_file_path if File.exist? cf_file_path
        end

        def cf_file_path
          @cf_file_path ||= tmp_path("#{hash}.cf")
        end

        it 'Example' do
          File.exist?(cf_file_path).must_equal false

          with_tmp_ib Fixtures::XML_FILES, platform_require: PLATFORM_REQUIRE do |ib|
            ib.db_cfg.dump(cf_file_path)
          end

          File.exist?(cf_file_path).must_equal true
        end
      end
    end

    it 'must include Support::TmpPath' do
      AssMaintainer::InfoBases::TmpInfoBase
        .include? AssMaintainer::InfoBases::Support::TmpPath
    end

    it '.new withot template' do
      args_builder = AssMaintainer::InfoBases::TmpInfoBase::ArgsBuilder.new
      AssMaintainer::InfoBases::TmpInfoBase::ArgsBuilder.expects(:new)
        .returns(args_builder)

      ib = AssMaintainer::InfoBases::TmpInfoBase.new
      ib.must_be_instance_of AssMaintainer::InfoBases::TmpInfoBase
      ib.is?(:file).must_equal true
      ib.template.must_be_nil
      ib.name.must_equal args_builder.ib_name
      ib.connection_string.file.must_equal args_builder.ib_path
      ib.read_only?.must_equal false
      ib.exists?.must_equal false
    end

    it '.new with template' do
      args_builder = AssMaintainer::InfoBases::TmpInfoBase::ArgsBuilder.new
      AssMaintainer::InfoBases::TmpInfoBase::ArgsBuilder.expects(:new)
        .returns(args_builder)

      ib = AssMaintainer::InfoBases::TmpInfoBase.new(:template)
      ib.must_be_instance_of AssMaintainer::InfoBases::TmpInfoBase
      ib.is?(:file).must_equal true
      ib.template.must_equal :template
      ib.name.must_equal args_builder.ib_name
      ib.connection_string.file.must_equal args_builder.ib_path
      ib.read_only?.must_equal false
      ib.exists?.must_equal false
    end

    it '#make smoky' do
      ib = AssMaintainer::InfoBases::TmpInfoBase.new
      begin
        ib.make
        ib.exists?.must_equal true
      ensure
        ib.rm! if ib.exists?
      end
    end

    it '#make smoky with tempalte' do
      begin
      ib = AssMaintainer::InfoBases::TmpInfoBase.new(Fixtures::XML_FILES)
        ib.make
        ib.exists?.must_equal true
        ib.template_loaded?.must_equal true
      ensure
        ib.rm! if ib.exists?
      end
    end

    it '.make_rm fail withot block' do
      e = proc {
        AssMaintainer::InfoBases::TmpInfoBase.make_rm
      }.must_raise RuntimeError
      e.message.must_equal 'Block require'
    end

    it '.make_rm' do
      seq = sequence('make_rm')
      ib = mock
      AssMaintainer::InfoBases::TmpInfoBase.expects(:new).with(:template, opt1: 1).returns(ib)
      ib.expects(:make).in_sequence(seq)
      ib.expects(:touch).in_sequence(seq)
      ib.expects(:rm!).in_sequence(seq)

      AssMaintainer::InfoBases::TmpInfoBase.make_rm(:template, opt1: 1) do |ib_|
        ib_.must_equal ib
        ib.touch
      end
    end
  end
end

require 'test_helper'
module AssMaintainer::InfoBasesTest
  require 'ass_maintainer/info_bases/test_info_base'
  describe AssMaintainer::InfoBases::TestInfoBase do
    it '.superclass' do
      AssMaintainer::InfoBases::TestInfoBase.superclass.must_equal\
        AssMaintainer::InfoBase
    end

    def inst(**options)
      @inst ||= AssMaintainer::InfoBases::TestInfoBase
        .new('name', Tmp::IB_CS, false,
             **options.merge({platform_require: PLATFORM_REQUIRE}))
    end

    after do
      begin
        FileUtils.rm_rf inst.connection_string.file if\
          inst.connection_string.file
      ensure
        @inst = nil
      end
    end

    it '#make' do
      seq = sequence('make')
      fixtures = mock
      ib = inst(:template => Fixtures::CF_FILE, :fixtures => fixtures)
      ib.expects(:load_template).in_sequence(seq)
      fixtures.expects(:call).in_sequence(seq).with(ib)
      ib.make.must_equal ib
      ib.built?.must_equal true
    end

    it '#load_template fail' do
      e = proc {
        inst(:template => 'bad template').make
      }.must_raise RuntimeError
      e.message.must_match %r{Invalid template}
    end

    it '#load_template :dt mocked' do
      ib = inst(:template => Fixtures::DT_FILE)
      ib.expects(:load_dt)
      ib.load_template
    end

    it '#load_template :dt smoky' do
      inst(:template => Fixtures::DT_FILE).make.load_template.must_equal :dt
    end

    it '#load_template :src smoky' do
      src = mock
      src.expects(:src_root).returns(Fixtures::XML_FILES).at_least_once
      inst(:template => src)
        .make.load_template.must_equal :src
    end

    it '#load_template :src mocked with src object' do
      src = mock
      src.expects(:src_root).returns(Fixtures::XML_FILES).times(4)
      ib = inst(:template => src)
      ib.expects(:load_src)
      ib.load_template
    end

    it '#load_template :src mocked with string' do
      ib = inst(:template => Fixtures::XML_FILES)
      ib.expects(:load_src)
      ib.load_template
    end

    it '#load_template :cf smoky' do
      inst(:template => Fixtures::CF_FILE)
        .make.load_template.must_equal :cf
    end

    it '#load_template :cf mocked' do
      ib = inst(:template => Fixtures::CF_FILE)
      ib.expects(:load_cf)
      ib.load_template
    end

    it '#template_type :cf' do
      inst(:template => Fixtures::CF_FILE).template_type.must_equal :cf
    end

    it '#template_type :dt' do
      inst(:template => Fixtures::DT_FILE).template_type.must_equal :dt
    end

    it '#template_type :src' do
      inst(:template => Fixtures::XML_FILES).template_type.must_equal :src
    end

    it '#built? if not template loded false' do
      inst.expects(:exists?).returns(true)
      inst.built?.must_equal false
    end

    it '#built? if not fixtures loded false' do
      inst.expects(:exists?).returns(true)
      inst.expects(:template_loaded?).returns(true)
      inst.built?.must_equal false
    end

    it '#built? if not fixtures loded false' do
      inst.expects(:exists?).returns(true)
      inst.expects(:template_loaded?).returns(true)
      inst.expects(:fixtures_loaded?).returns(true)
      inst.built?.must_equal true
    end

    it '#erase_data!' do
      fixtures = ->(ib) do
        ext = ib.ole :external
        begin
          ext.__open__ ib.connection_string
          item = ext.Catalogs.Catalog.CreateItem
          item.Description = 'new item'
          item.write
        ensure
          ext.__close__
        end
      end

      def item_empty_ref?(ib)
        ext = ib.ole(:external)
        ext.__open__ ib.connection_string
        item = ext.Catalogs.Catalog.FindByDescription 'new item'
        item.IsEmpty
      ensure
        ext.__close__
      end

      inst(template: Fixtures::CATALOG_CF,
           fixtures: fixtures).make

      item_empty_ref?(inst).must_equal false

      inst.erase_data!.must_equal inst

      item_empty_ref?(inst).must_equal true
    end

    it '#erase_data! fail if infobase read_only?' do
      e = proc {
        inst.expects(:read_only?).returns true
        inst.erase_data!
      }.must_raise AssMaintainer::InfoBase::MethodDenied
      e.message.must_match %r{erase_data!}
    end

    it '#load_template! fail if infobase read_only?' do
      e = proc {
        inst.expects(:read_only?).returns true
        inst.load_template!
      }.must_raise AssMaintainer::InfoBase::MethodDenied
      e.message.must_match %r{load_template!}
    end

    it '#load_fixtures! fail if infobase read_only?' do
      e = proc {
        inst.expects(:read_only?).returns true
        inst.load_fixtures!
      }.must_raise AssMaintainer::InfoBase::MethodDenied
      e.message.must_match %r{load_fixtures!}
    end

    it '#reload_fixtures! moked' do
      seq = sequence('reload_fixtures!')
      inst.expects(:erase_data!).in_sequence(seq)
      inst.expects(:load_fixtures!).in_sequence(seq)
      inst.reload_fixtures!
    end

    it '#reload_fixtures! smoky' do
      inst.make.reload_fixtures!
    end
  end
end


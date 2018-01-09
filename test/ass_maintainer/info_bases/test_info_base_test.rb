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

    describe '#load_template' do
      it 'fail if invalid template' do
        e = proc {
          inst(:template => 'bad template').make
        }.must_raise RuntimeError
        e.message.must_match %r{Invalid template}
      end

      it ':dt mocked' do
        ib = inst(:template => Fixtures::DT_FILE)
        ib.expects(:load_dt)
        ib.load_template
      end

      it ':dt smoky' do
        inst(:template => Fixtures::DT_FILE).make.load_template.must_equal :dt
      end

      it ':src smoky' do
        src = mock
        src.expects(:src_root).returns(Fixtures::XML_FILES).at_least_once
        inst(:template => src)
          .make.load_template.must_equal :src
      end

      it ':src mocked with src object' do
        src = mock
        src.expects(:src_root).returns(Fixtures::XML_FILES).times(4)
        ib = inst(:template => src)
        ib.expects(:load_src)
        ib.load_template
      end

      it ':src mocked with string' do
        ib = inst(:template => Fixtures::XML_FILES)
        ib.expects(:load_src)
        ib.load_template
      end

      it ':cf smoky' do
        inst(:template => Fixtures::CF_FILE)
          .make.load_template.must_equal :cf
      end

      it ':cf mocked' do
        ib = inst(:template => Fixtures::CF_FILE)
        ib.expects(:load_cf)
        ib.load_template
      end
    end

    describe '#template_type' do
      it ':cf' do
        inst(:template => Fixtures::CF_FILE).template_type.must_equal :cf
      end

      it ':dt' do
        inst(:template => Fixtures::DT_FILE).template_type.must_equal :dt
      end

      it ':src' do
        inst(:template => Fixtures::XML_FILES).template_type.must_equal :src
      end
    end

    describe '#template_loaded?' do
      it 'always nil unless :template passed' do
        inst.expects(:template).returns(nil).at_least_once
        inst.expects(:load_template)
        inst.template_loaded?.must_be_nil
        inst.load_template!
        inst.template_loaded?.must_be_nil
      end

      describe 'if :template passed' do
        it 'false uless #load_template!' do
          inst(template: :fake).template_loaded?.must_equal false
        end

        it 'true if #load_template!' do
          inst(template: :fake).expects(:load_template)
          inst.template_loaded?.must_equal false
          inst.load_template!
          inst.template_loaded?.must_equal true
        end
      end
    end

    describe '#fixtures_loaded?' do
      it 'always nil unless :fixtures passed' do
        inst.expects(:fixtures).returns(nil).at_least_once
        inst.fixtures_loaded?.must_be_nil
        inst.load_fixtures!
        inst.fixtures_loaded?.must_be_nil
      end

      describe 'if :fixtures passed' do
        it 'false uless #load_fixtures!' do
          inst(fixtures: proc {|ib|}).fixtures_loaded?.must_equal false
        end

        it 'true if #load_fixtures!' do
          inst(fixtures: proc {|ib|}).fixtures_loaded?.must_equal false
          inst.load_fixtures!
          inst.fixtures_loaded?.must_equal true
        end
      end
    end

    describe '#built?' do
      describe 'false' do
        it 'if not exists' do
          inst.expects(:exists?).returns(false)
          inst.expects(:template_loaded?).never
          inst.expects(:fixtures_loaded?).never
          inst.built?.must_equal false
        end

        it 'if template_loaded? == false' do
          inst.expects(:exists?).returns(true)
          inst.expects(:template_loaded?).returns(false)
          inst.expects(:fixtures_loaded?).never
          inst.built?.must_equal false
        end

        it 'if fixtures_loaded? == false' do
          inst.expects(:exists?).returns(true)
          inst.expects(:template_loaded?).returns(true)
          inst.expects(:fixtures_loaded?).returns(false)
          inst.built?.must_equal false
        end
      end

      describe 'true' do
        it 'when exists? == true && template_loaded? == true && fixtures_loaded? == true' do
          inst.expects(:exists?).returns(true)
          inst.expects(:template_loaded?).returns(true)
          inst.expects(:fixtures_loaded?).returns(true)
          inst.built?.must_equal true
        end

        it 'when exists? == true && template_loaded? == nil && fixtures_loaded? == true' do
          inst.expects(:exists?).returns(true)
          inst.expects(:template_loaded?).returns(nil)
          inst.expects(:fixtures_loaded?).returns(true)
          inst.built?.must_equal true
        end

        it 'when exists? == true && template_loaded? == true && fixtures_loaded? == nil' do
          inst.expects(:exists?).returns(true)
          inst.expects(:template_loaded?).returns(true)
          inst.expects(:fixtures_loaded?).returns(nil)
          inst.built?.must_equal true
        end

        it 'when exists? == true && template_loaded? == nil && fixtures_loaded? == nil' do
          inst.expects(:exists?).returns(true)
          inst.expects(:template_loaded?).returns(nil)
          inst.expects(:fixtures_loaded?).returns(nil)
          inst.built?.must_equal true
        end
      end

      it 'smoky' do
        inst.built?.wont_be_nil
      end
    end

    describe '#erase_data!' do
      it 'success' do
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

      it 'fail if infobase read_only?' do
        e = proc {
          inst.expects(:read_only?).returns true
          inst.erase_data!
        }.must_raise AssMaintainer::InfoBase::MethodDenied
        e.message.must_match %r{erase_data!}
      end
    end

    describe '#load_template!' do
      it 'fail if infobase read_only?' do
        e = proc {
          inst.expects(:read_only?).returns true
          inst.load_template!
        }.must_raise AssMaintainer::InfoBase::MethodDenied
        e.message.must_match %r{load_template!}
      end

      it 'success moked' do
        inst.expects(:read_only?).returns false
        inst.expects(:load_template)
        inst.expects(:template).returns(:template).at_least_once
        inst.template_loaded?.must_equal false
        inst.load_template!.must_equal inst
        inst.template_loaded?.must_equal true
      end
    end

    describe '#load_fixtures!' do
      it 'fail if infobase read_only?' do
        e = proc {
          inst.expects(:read_only?).returns true
          inst.load_fixtures!
        }.must_raise AssMaintainer::InfoBase::MethodDenied
        e.message.must_match %r{load_fixtures!}
      end

      it 'success' do
        fixtures = mock
        fixtures.expects(:call).with(inst)
        inst.expects(:read_only?).returns false
        inst.expects(:fixtures).returns(fixtures).at_least_once

        inst.fixtures_loaded?.must_equal false
        inst.load_fixtures!.must_equal inst
        inst.fixtures_loaded?.must_equal true
      end
    end

    describe '#reload_fixtures!' do
      it 'moked' do
        seq = sequence('reload_fixtures!')
        inst.expects(:erase_data!).in_sequence(seq)
        inst.expects(:load_fixtures!).in_sequence(seq)
        inst.reload_fixtures!
      end

      it 'smoky' do
        inst.make.reload_fixtures!
      end
    end
  end
end


require "test_helper"

module AssMaintainer::InfoBasesTest
  describe ::AssMaintainer::InfoBases::VERSION do
    it 'has a version_number' do
      ::AssMaintainer::InfoBases::VERSION.wont_be_nil
    end
  end

  describe ::AssMaintainer::InfoBases::Support::TmpPath do
    def inst
      @inst ||= Class.new do
        include AssMaintainer::InfoBases::Support::TmpPath
      end.new
    end

    it '#tmp_path' do
      inst.tmp_path('ext').wont_be_nil
      File.exist?(inst.tmp_path('ext')).must_equal false
    end

  end
end

require "test_helper"

module AssMaintainer::InfoBasesTest
  describe ::AssMaintainer::InfoBases::VERSION do
    it 'has a version_number' do
      ::AssMaintainer::InfoBases::VERSION.wont_be_nil
    end
  end
end

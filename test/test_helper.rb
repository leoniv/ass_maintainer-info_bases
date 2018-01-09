$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'simplecov'
require "ass_maintainer/info_bases"
require "minitest/autorun"
require 'mocha/mini_test'

module AssMaintainer::InfoBasesTest
  PLATFORM_REQUIRE = '~> 8.3.10.0'

  module Fixtures
    PATH = File.expand_path('../fixtures', __FILE__)

    XML_FILES = File.join PATH, 'xml_files'
    fail unless File.directory? XML_FILES

    CF_FILE = File.join PATH, 'ib.cf'
    fail unless File.file? CF_FILE

    DT_FILE = File.join PATH, 'ib.dt'
    fail unless File.file? DT_FILE

    CATALOG_CF = File.join PATH, 'catalog.cf'
    fail unless File.file? CATALOG_CF
  end

  module Tmp
    IB_NAME = self.name.gsub('::','_')
    IB_PATH = File.join(Dir.tmpdir, IB_NAME)
    IB_CS = "File=\"#{IB_PATH}\""
  end
end

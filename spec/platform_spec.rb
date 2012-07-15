require 'spec_helper'

describe Phantomjs::Platform do
  before(:each) { Phantomjs.reset! }
  describe "on a 64 bit linux" do
    before do
      Phantomjs::Platform.stub(:host_os).and_return('linux-gnu')
      Phantomjs::Platform.stub(:architecture).and_return('x86_64')
    end

    it "reports the Linux64 Platform as useable" do
      Phantomjs::Platform::Linux64.should be_useable
    end

    it "returns the correct phantom js executable path for the platform" do
      Phantomjs.path.should =~ /x86_64-linux\/bin\/phantomjs$/
    end

    it "reports the Linux32 platform as unuseable" do
      Phantomjs::Platform::Linux32.should_not be_useable
    end

    it "reports the Darwin platform as unuseable" do
      Phantomjs::Platform::OsX.should_not be_useable
    end
  end

  describe "on a 32 bit linux" do
    before do
      Phantomjs::Platform.stub(:host_os).and_return('linux-gnu')
      Phantomjs::Platform.stub(:architecture).and_return('x86_32')
    end

    it "reports the Linux32 Platform as useable" do
      Phantomjs::Platform::Linux32.should be_useable
    end

    it "returns the correct phantom js executable path for the platform" do
      Phantomjs.path.should =~ /x86_32-linux\/bin\/phantomjs$/
    end

    it "reports the Linux64 platform as unuseable" do
      Phantomjs::Platform::Linux64.should_not be_useable
    end

    it "reports the Darwin platform as unuseable" do
      Phantomjs::Platform::OsX.should_not be_useable
    end
  end

  describe "on OS X" do
    before do
      Phantomjs::Platform.stub(:host_os).and_return('darwin')
      Phantomjs::Platform.stub(:architecture).and_return('x86_64')
    end

    it "reports the Darwin platform as useable" do
      Phantomjs::Platform::OsX.should be_useable
    end

    it "returns the correct phantom js executable path for the platform" do
      Phantomjs.path.should =~ /darwin\/bin\/phantomjs$/
    end

    it "reports the Linux32 Platform as unuseable" do
      Phantomjs::Platform::Linux32.should_not be_useable
    end

    it "reports the Linux64 platform as unuseable" do
      Phantomjs::Platform::Linux64.should_not be_useable
    end
  end

  describe 'on an unknown platform' do
    before do
      Phantomjs::Platform.stub(:host_os).and_return('foobar')
    end

    it "raises an UnknownPlatform error" do
      -> { Phantomjs.platform }.should raise_error(Phantomjs::UnknownPlatform)
    end
  end
end
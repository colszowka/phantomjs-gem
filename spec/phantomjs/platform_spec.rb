require 'spec_helper'

describe Phantomjs::Platform do
  before(:each) { Phantomjs.reset! }
  subject { described_class }

  describe "#system_phantomjs_installed?" do
    before do
      subject.should_receive(:system_phantomjs_version).and_return(system_version)
    end

    after do
      Phantomjs.instance_variable_set(:@minimum, nil)
      Phantomjs.instance_variable_set(:@maximum, nil)
    end

    context 'when there is no system version' do
      let(:system_version) { nil }

      its(:system_phantomjs_installed?) { should be(false) }
    end

    context "when there is a system version" do
      context "that matches the Phantomjs.version" do
        let(:system_version) { Phantomjs::BINARY_VERSION }

        its(:system_phantomjs_installed?) { should be(true) }
      end

      context "that is less than the Phantomjs.version" do
        let(:system_version) { '0.0.1' }

        its(:system_phantomjs_installed?) { should be(false) }
      end

      context "that is greater than the Phantomjs.version" do
        let(:system_version) { '100.2.3' }

        its(:system_phantomjs_installed?) { should be(true) }
      end

      context 'less than the minimum version' do
        let(:system_version) { Phantomjs::BINARY_VERSION }

        before do
          Phantomjs.minimum = '100.10'
        end

        its(:system_phantomjs_installed?) { should be(false) }
      end

      context 'greater than the maximum version' do
        let(:system_version) { Phantomjs::BINARY_VERSION }

        before do
          Phantomjs.maximum = '0.10'
        end

        its(:system_phantomjs_installed?) { should be(false) }
      end
    end
  end

  describe "on a 64 bit linux" do
    before do
      subject.stub(:host_os).and_return('linux-gnu')
      subject.stub(:architecture).and_return('x86_64')
    end

    it "reports the Linux64 Platform as useable" do
      subject::Linux64.should be_useable
    end

    describe "without system install" do
      before(:each) { subject.stub(:system_phantomjs_version).and_return(nil) }

      it "returns the correct phantom js executable path for the platform" do
        Phantomjs.path.should =~ /x86_64-linux\/bin\/phantomjs$/
      end
    end

    describe "with system install" do
      before(:each) do
        subject.stub(:system_phantomjs_version).and_return(Phantomjs.version)
        subject.stub(:system_phantomjs_path).and_return('/tmp/path')
      end

      it "returns the correct phantom js executable path for the platform" do
        expect(Phantomjs.path).to be == '/tmp/path'
      end
    end

    it "reports the Linux32 platform as unuseable" do
      subject::Linux32.should_not be_useable
    end

    it "reports the Darwin platform as unuseable" do
      subject::OsX.should_not be_useable
    end

    it "reports the Win32 Platform as unuseable" do
      subject::Win32.should_not be_useable
    end
  end

  describe "on a 32 bit linux" do
    before do
      subject.stub(:host_os).and_return('linux-gnu')
      subject.stub(:architecture).and_return('x86_32')
    end

    it "reports the Linux32 Platform as useable" do
      subject::Linux32.should be_useable
    end

    it "reports another Linux32 Platform as useable" do
      subject.stub(:host_os).and_return('linux-gnu')
      subject.stub(:architecture).and_return('i686')
      subject::Linux32.should be_useable
    end

    describe "without system install" do
      before(:each) { subject.stub(:system_phantomjs_version).and_return(nil) }

      it "returns the correct phantom js executable path for the platform" do
        Phantomjs.path.should =~ /x86_32-linux\/bin\/phantomjs$/
      end
    end

    describe "with system install" do
      before(:each) do
        subject.stub(:system_phantomjs_version).and_return(Phantomjs.version)
        subject.stub(:system_phantomjs_path).and_return('/tmp/path')
      end

      it "returns the correct phantom js executable path for the platform" do
        expect(Phantomjs.path).to be == '/tmp/path'
      end
    end

    it "reports the Linux64 platform as unuseable" do
      subject::Linux64.should_not be_useable
    end

    it "reports the Darwin platform as unuseable" do
      subject::OsX.should_not be_useable
    end

    it "reports the Win32 Platform as unuseable" do
      subject::Win32.should_not be_useable
    end
  end

  describe "on OS X" do
    before do
      subject.stub(:host_os).and_return('darwin')
      subject.stub(:architecture).and_return('x86_64')
    end

    it "reports the Darwin platform as useable" do
      subject::OsX.should be_useable
    end

    describe "without system install" do
      before(:each) { subject.stub(:system_phantomjs_version).and_return(nil) }

      it "returns the correct phantom js executable path for the platform" do
        Phantomjs.path.should =~ /darwin\/bin\/phantomjs$/
      end
    end

    describe "with system install" do
      before(:each) do
        subject.stub(:system_phantomjs_version).and_return(Phantomjs.version)
        subject.stub(:system_phantomjs_path).and_return('/tmp/path')
      end

      it "returns the correct phantom js executable path for the platform" do
        Phantomjs.path.should eq '/tmp/path'
      end
    end

    it "reports the Linux32 Platform as unuseable" do
      subject::Linux32.should_not be_useable
    end

    it "reports the Linux64 platform as unuseable" do
      subject::Linux64.should_not be_useable
    end

    it "reports the Win32 Platform as unuseable" do
      subject::Win32.should_not be_useable
    end
  end

  describe "on Windows" do
    before do
      subject.stub(:host_os).and_return('mingw32')
      subject.stub(:architecture).and_return('i686')
    end

    describe "without system install" do
      before(:each) { subject.stub(:system_phantomjs_version).and_return(nil) }

      it "returns the correct phantom js executable path for the platform" do
        Phantomjs.path.should =~ /win32\/phantomjs.exe$/
      end
    end

    describe "with system install" do
      before(:each) do
        subject.stub(:system_phantomjs_version).and_return(Phantomjs.version)
        subject.stub(:system_phantomjs_path).and_return("#{ENV['TEMP']}/path")
      end

      it "returns the correct phantom js executable path for the platform" do
        expect(Phantomjs.path).to be == "#{ENV['TEMP']}/path"
      end
    end

    it "reports the Darwin platform as unuseable" do
      subject::OsX.should_not be_useable
    end

    it "reports the Linux32 Platform as unuseable" do
      subject::Linux32.should_not be_useable
    end

    it "reports the Linux64 platform as unuseable" do
      subject::Linux64.should_not be_useable
    end
  end

  describe 'on an unknown platform' do
    before do
      subject.stub(:host_os).and_return('foobar')
    end

    it "raises an UnknownPlatform error" do
      -> { Phantomjs.platform }.should raise_error(Phantomjs::UnknownPlatform)
    end
  end
end

require 'spec_helper'

describe Phantomjs::Platform do
  before do
    Phantomjs.reset!
  end

  describe 'with a system install present' do
    describe '#system_phantomjs_installed?' do
      it 'is true when the system version matches Phantomjs.version' do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return(Phantomjs.version)
        expect(Phantomjs::Platform.system_phantomjs_installed?).to be true
      end

      it 'is false when the system version does not match Phantomjs.version' do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return('1.2.3')
        expect(Phantomjs::Platform.system_phantomjs_installed?).to be false
      end

      it "is false when there's no system version" do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return(nil)
        expect(Phantomjs::Platform.system_phantomjs_installed?).to be false
      end
    end
  end

  describe 'on a 64 bit linux' do
    before do
      allow(Phantomjs::Platform).to receive(:host_os).and_return('linux-gnu')
      allow(Phantomjs::Platform).to receive(:architecture).and_return('x86_64')
    end

    it 'reports the Linux64 Platform as useable' do
      expect(Phantomjs::Platform::Linux64).to be_useable
    end

    describe 'without system install' do
      before do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return(nil)
      end

      it 'returns the correct phantom js executable path for the platform' do
        expect(Phantomjs.path).to match(/x86_64-linux\/bin\/phantomjs$/)
      end
    end

    describe 'with system install' do
      before do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return(Phantomjs.version)
        allow(Phantomjs::Platform).to receive(:system_phantomjs_path).and_return('/tmp/path')
      end

      it 'returns the correct phantom js executable path for the platform' do
        expect(Phantomjs.path).to be == '/tmp/path'
      end
    end

    it 'reports the Linux32 platform as unuseable' do
      expect(Phantomjs::Platform::Linux32).not_to be_useable
    end

    it 'reports the Darwin platform as unuseable' do
      expect(Phantomjs::Platform::OsX).not_to be_useable
    end

    it 'reports the Win32 Platform as unuseable' do
      expect(Phantomjs::Platform::Win32).not_to be_useable
    end
  end

  describe 'on a 32 bit linux' do
    before do
      allow(Phantomjs::Platform).to receive(:host_os).and_return('linux-gnu')
      allow(Phantomjs::Platform).to receive(:architecture).and_return('x86_32')
    end

    it 'reports the Linux32 Platform as useable' do
      expect(Phantomjs::Platform::Linux32).to be_useable
    end

    it 'reports another Linux32 Platform as useable' do
      allow(Phantomjs::Platform).to receive(:host_os).and_return('linux-gnu')
      allow(Phantomjs::Platform).to receive(:architecture).and_return('i686')
      expect(Phantomjs::Platform::Linux32).to be_useable
    end

    describe 'without system install' do
      before do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return(nil)
      end

      it 'returns the correct phantom js executable path for the platform' do
        expect(Phantomjs.path).to match(/x86_32-linux\/bin\/phantomjs$/)
      end
    end

    describe 'with system install' do
      before do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return(Phantomjs.version)
        allow(Phantomjs::Platform).to receive(:system_phantomjs_path).and_return('/tmp/path')
      end

      it 'returns the correct phantom js executable path for the platform' do
        expect(Phantomjs.path).to be == '/tmp/path'
      end
    end

    it 'reports the Linux64 platform as unuseable' do
      expect(Phantomjs::Platform::Linux64).not_to be_useable
    end

    it 'reports the Darwin platform as unuseable' do
      expect(Phantomjs::Platform::OsX).not_to be_useable
    end

    it 'reports the Win32 Platform as unuseable' do
      expect(Phantomjs::Platform::Win32).not_to be_useable
    end
  end

  describe 'on OS X' do
    before do
      allow(Phantomjs::Platform).to receive(:host_os).and_return('darwin')
      allow(Phantomjs::Platform).to receive(:architecture).and_return('x86_64')
    end

    it 'reports the Darwin platform as useable' do
      expect(Phantomjs::Platform::OsX).to be_useable
    end

    describe 'without system install' do
      before do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return(nil)
      end

      it 'returns the correct phantom js executable path for the platform' do
        expect(Phantomjs.path).to match(/darwin\/bin\/phantomjs$/)
      end
    end

    describe 'with system install' do
      before do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return(Phantomjs.version)
        allow(Phantomjs::Platform).to receive(:system_phantomjs_path).and_return('/tmp/path')
      end

      it 'returns the correct phantom js executable path for the platform' do
        expect(Phantomjs.path).to be == '/tmp/path'
      end
    end

    it 'reports the Linux32 Platform as unuseable' do
      expect(Phantomjs::Platform::Linux32).not_to be_useable
    end

    it 'reports the Linux64 platform as unuseable' do
      expect(Phantomjs::Platform::Linux64).not_to be_useable
    end

    it 'reports the Win32 Platform as unuseable' do
      expect(Phantomjs::Platform::Win32).not_to be_useable
    end
  end

  describe 'on Windows x86' do
    before do
      allow(Phantomjs::Platform).to receive(:host_os).and_return('mingw32')
      allow(Phantomjs::Platform).to receive(:architecture).and_return('i686')
    end

    describe 'without system install' do
      before do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return(nil)
      end

      it 'returns the correct phantom js executable path for the platform' do
        expect(Phantomjs.path).to match(/win32\/bin\/phantomjs.exe$/)
      end
    end

    describe 'with system install' do
      before do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return(Phantomjs.version)
        allow(Phantomjs::Platform).to receive(:system_phantomjs_path).and_return("#{ENV['TEMP']}/path")
      end

      it 'returns the correct phantom js executable path for the platform' do
        expect(Phantomjs.path).to be == "#{ENV['TEMP']}/path"
      end
    end

    it 'reports the Darwin platform as unuseable' do
      expect(Phantomjs::Platform::OsX).not_to be_useable
    end

    it 'reports the Linux32 Platform as unuseable' do
      expect(Phantomjs::Platform::Linux32).not_to be_useable
    end

    it 'reports the Linux64 platform as unuseable' do
      expect(Phantomjs::Platform::Linux64).not_to be_useable
    end
  end

  describe 'on Windows x64' do
    before do
      allow(Phantomjs::Platform).to receive(:host_os).and_return('mingw32')
      allow(Phantomjs::Platform).to receive(:architecture).and_return('x86_64')
    end

    describe 'without system install' do
      before do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return(nil)
      end

      it 'returns the correct phantom js executable path for the platform' do
        expect(Phantomjs.path).to match(/win32\/bin\/phantomjs.exe$/)
      end
    end

    describe 'with system install' do
      before do
        allow(Phantomjs::Platform).to receive(:system_phantomjs_version).and_return(Phantomjs.version)
        allow(Phantomjs::Platform).to receive(:system_phantomjs_path).and_return("#{ENV['TEMP']}/path")
      end

      it 'returns the correct phantom js executable path for the platform' do
        expect(Phantomjs.path).to be == "#{ENV['TEMP']}/path"
      end
    end

    it 'reports the Darwin platform as unuseable' do
      expect(Phantomjs::Platform::OsX).not_to be_useable
    end

    it 'reports the Linux32 Platform as unuseable' do
      expect(Phantomjs::Platform::Linux32).not_to be_useable
    end

    it 'reports the Linux64 platform as unuseable' do
      expect(Phantomjs::Platform::Linux64).not_to be_useable
    end
  end

  describe 'on an unknown platform' do
    before do
      allow(Phantomjs::Platform).to receive(:host_os).and_return('foobar')
    end

    it 'raises an UnknownPlatform error' do
      expect { Phantomjs.platform }.to raise_error(Phantomjs::UnknownPlatform)
    end
  end
end

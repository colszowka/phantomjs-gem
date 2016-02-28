module Phantomjs
  class Platform
    class << self
      def host_os
        RbConfig::CONFIG['host_os']
      end

      def architecture
        RbConfig::CONFIG['host_cpu']
      end

      def phantomjs_path
        if system_phantomjs_installed?
          system_phantomjs_path
        else
          File.expand_path File.join(Phantomjs.base_dir, platform, 'bin/phantomjs')
        end
      end

      def system_phantomjs_path
        `which phantomjs`.delete("\n")
      rescue
      end

      def system_phantomjs_version
        `phantomjs --version`.delete("\n") if system_phantomjs_path.length > 4.2
      rescue
      end

      def system_phantomjs_installed?
        system_phantomjs_version == Phantomjs.version
      end

      def installed?
        File.exist?(phantomjs_path) || system_phantomjs_installed?
      end

      def install!
        STDERR.puts "Phantomjs does not appear to be installed in #{phantomjs_path}, installing!"
        FileUtils.mkdir_p Phantomjs.base_dir

        Dir.mktmpdir do |dir|
          Dir.chdir dir do
            download

            extract

            install
          end
        end

        raise "Failed to install phantomjs. Sorry :(" unless File.exist?(phantomjs_path)
      end

      def download
        unless system "curl -L --retry 5 -O #{package_url}" or system "wget -t 5 #{package_url}"
          raise "\n\nFailed to load phantomjs! :(\nYou need to have cURL or wget installed on your system.\nIf you have, the source of phantomjs might be unavailable: #{package_url}\n\n"
        end
      end

      def extract
        case package_url.split('.').last
          when 'bz2'
            system "bunzip2 #{File.basename(package_url)}"
            system "tar xf #{File.basename(package_url).sub(/\.bz2$/, '')}"
          when 'zip'
            system "unzip #{File.basename(package_url)}"
          else
            raise "Unknown compression format for #{File.basename(package_url)}"
        end
      end

      def install
        # Find the phantomjs build we just extracted
        extracted_dir = Dir['phantomjs*'].find { |path| File.directory?(path) }

        # Move the extracted phantomjs build to $HOME/.phantomjs/version/platform
        if FileUtils.mv extracted_dir, File.join(Phantomjs.base_dir, platform)
          STDOUT.puts "\nSuccessfully installed phantomjs. Yay!"
        end
      end

      def ensure_installed!
        install! unless installed?
      end
    end

    class Linux64 < Platform
      class << self
        def useable?
          host_os.include?('linux') and architecture.include?('x86_64')
        end

        def platform
          'x86_64-linux'
        end

        def package_url
          'https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2'
        end
      end
    end

    class Linux32 < Platform
      class << self
        def useable?
          host_os.include?('linux') and (architecture.include?('x86_32') or architecture.include?('i686'))
        end

        def platform
          'x86_32-linux'
        end

        def package_url
          'https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-i686.tar.bz2'
        end
      end
    end

    class OsX < Platform
      class << self
        def useable?
          host_os.include?('darwin')
        end

        def platform
          'darwin'
        end

        def package_url
          'https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-macosx.zip'
        end
      end
    end

    class Win32 < Platform
      class << self
        def useable?
          host_os.include?('mingw32') and architecture.include?('i686')
        end

        def platform
          'win32'
        end

        def phantomjs_path
          if system_phantomjs_installed?
            system_phantomjs_path
          else
            File.expand_path File.join(Phantomjs.base_dir, platform, 'bin', 'phantomjs.exe')
          end
        end

        def package_url
          'https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-windows.zip'
        end
      end
    end
  end
end

require 'net/http'
require 'tmpdir'
require 'zip'

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
          File.expand_path(File.join(Phantomjs.base_dir, platform, 'bin', phantomjs_executable))
        end
      end

      def phantomjs_executable
        'phantomjs'
      end

      def system_phantomjs_path
        which(phantomjs_executable)
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

        in_tmp do
          file = with_retry(5) do
            download(package_url)
          end

          case File.extname(file)
            when '.bz2'
              bunzip(file)
            when '.zip'
              unzip(file)
            else
              raise "Unknown compression format for #{file}"
          end

          move_to_local_directory
        end
      end

      def ensure_installed!
        install! unless installed?
      end

      private
      def which(executable)
        ENV['PATH']
          .split(File::PATH_SEPARATOR)
          .map { |path| File.join(path, executable) }
          .select { |path| File.file?(path) }
          .first
      end

      def in_tmp
        Dir.mktmpdir('phantomjs_install') do |dir|
          Dir.chdir(dir) do
            yield if block_given?
          end
        end
      end

      def with_retry(tries = 5)
        yield if block_given?
      # http://tammersaleh.com/posts/rescuing-net-http-exceptions/
      rescue Timeout::Error,
             Errno::EINVAL,
             Errno::ECONNRESET,
             EOFError,
             Net::HTTPBadResponse,
             Net::HTTPHeaderSyntaxError,
             Net::ProtocolError => e
        warn('Retrying download...')
        retry unless (tries -= 1).zero?
        raise e
      end

      def download(uri, redirect_limit = 10)
        fail ArgumentError, 'Too many HTTP redirects' if redirect_limit <= 0

        uri = URI(uri)
        file = File.basename(uri.path)

        opts = { use_ssl: uri.scheme == 'https' }
        opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if self == Win32

        Net::HTTP.start(uri.host, uri.port, opts) do |http|
          request = Net::HTTP::Get.new(uri.request_uri)

          http.request(request) do |response|
            case response
              when Net::HTTPSuccess then
                STDOUT.puts("Downloading from #{uri}")

                File.open(file, 'wb') do |io|
                  downloaded = 0

                  response.read_body do |chunk|
                    downloaded += chunk.length
                    STDOUT.print(sprintf("\r%5.1f%", downloaded.to_f / response.content_length * 100))
                    STDOUT.flush

                    io.write(chunk)
                  end
                end
              when Net::HTTPRedirection then
                location = response['Location']
                return download(location, redirect_limit - 1)
              else
                fail "Unknown HTTP response #{response}"
            end
          end
        end

        file
      end

      def bunzip(file)
        bunzip = %W(bunzip2 #{file})
        unless system(*bunzip)
          fail "Failed to execute \"#{bunzip.join(' ')}\", exit status #{$?.exitstatus}"
        end

        tarfile = file.sub(/\.bz2$/, '')
        tar = %W(tar xf #{tarfile})
        unless system(*tar)
          fail "Failed to execute \"#{tar.join(' ')}\", exit status #{$?.exitstatus}"
        end
      end

      def unzip(file)
        # Overwrite existing files.
        Zip.on_exists_proc = true

        Zip::File.open(file) do |zip|
          zip.each do |entry|
            entry.extract
          end
        end
      end

      def move_to_local_directory
        extracted_dir = Dir['phantomjs*'].find { |path| File.directory?(path) }

        fail "Could not find extracted phantomjs directory in #{File.join(Dir.pwd, 'phantomjs*')}" if extracted_dir.nil?

        # Move the extracted phantomjs build to $HOME/.phantomjs/version/platform
        target = File.join(Phantomjs.base_dir, platform)

        FileUtils.mkdir_p(File.dirname(target))
        FileUtils.mv(extracted_dir, target)

        if File.exist?(phantomjs_path)
          FileUtils.chmod(0755, phantomjs_path)
          STDOUT.puts "\nSuccessfully installed phantomjs in #{phantomjs_path}. Yay!"
          return
        end

        fail "Failed to install phantomjs. Could not find #{phantomjs_path}. Sorry :("
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
          "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-#{Phantomjs.version}-linux-x86_64.tar.bz2"
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
          "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-#{Phantomjs.version}-linux-i686.tar.bz2"
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
          "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-#{Phantomjs.version}-macosx.zip"
        end
      end
    end

    class Win32 < Platform
      class << self
        def useable?
          host_os.include?('mingw32') && (architecture.include?('i686') || architecture.include?('x86_64'))
        end

        def platform
          'win32'
        end

        def phantomjs_executable
          'phantomjs.exe'
        end

        def package_url
          "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-#{Phantomjs.version}-windows.zip"
        end
      end
    end
  end
end

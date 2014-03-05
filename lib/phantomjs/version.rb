module Phantomjs
  BINARY_VERSION = '1.9.7'
  PATCH_LEVEL    = '0'
  VERSION = [BINARY_VERSION, PATCH_LEVEL].join('.')

  class Version < Array
    include Comparable

    # Construct an array with the integer components of the version string
    #
    # @example
    #   a = Version.new('1.2.9') # => [1, 2, 9]
    #   b = Version.new('1.3.0') # => [1, 3, 0]
    #   a < b                    # => true
    #
    # @param [String, Numeric] version
    #
    # @constructor
    #
    # @api public
    def initialize(version)
      case version
      when Numeric
        super([version])
      else
        super(version.split('.').map(&:to_i))
      end
    end
  end
end

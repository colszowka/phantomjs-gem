require 'spec_helper'

describe Phantomjs do
  it 'VERSION starts with the Phantomjs binary version' do
    Phantomjs::VERSION.should start_with(Phantomjs::BINARY_VERSION)
  end

  describe Phantomjs::Version do
    it 'orders strings in semantic not lexical order' do
      ['1.10.1', '1.9.1', '2.10.0', '0.15.2'].map do |version|
        Phantomjs::Version.new(version)
      end.sort.map do |version|
        version.join('.')
      end.should eq %w(0.15.2 1.9.1 1.10.1 2.10.0)
    end

    it 'can be initialized with Numerics' do
      negative_one = Phantomjs::Version.new(-1)
      zero         = Phantomjs::Version.new('0.0')
      negative_one.should < zero
      zero.should > negative_one
    end

    it 'works when initialized with infinities' do
      infinity          = Phantomjs::Version.new( Phantomjs::INFINITY)
      negative_infinity = Phantomjs::Version.new(-Phantomjs::INFINITY)
      zero              = Phantomjs::Version.new('0.0')
      zero.should < infinity
      zero.should > negative_infinity
      infinity.should > negative_infinity
      negative_infinity.should < infinity
    end
  end
end

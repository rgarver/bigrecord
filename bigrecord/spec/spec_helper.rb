require 'pathname'
require 'rubygems'

gem 'rspec', '~>1.2'
require 'spec'

class Object; def self.deprecate(*options); end; end

SPEC_ROOT = Pathname(__FILE__).dirname.expand_path
require SPEC_ROOT.parent + 'lib/big_record'

begin
  # require 'connection'
  require File.join(File.dirname(__FILE__), "connections", "hbase", "connection")
rescue LoadError
  puts "requires connection file"
end

# Load the various helpers for the spec suite
Dir.glob( File.join(File.dirname(__FILE__), "lib", "*.rb") ).each do |model|
  require model
end


# Redefine the Hash class to include two helper methods used only in the specs.
class Hash

  # Helper method to determine if a hash is completely contained within other_hash (order is not important).
  # The other_hash might have more key/value pairs, but those aren't considered.
  #
  #   hash1 = { :key1 => "value1", :key2 => "value2", :key3 => "value3" }
  #
  #   hash2 = { :key1 => "value1", :key2 => "value2", :key3 => "value3", :key4 => "value4" }
  #
  #   hash1.subset_of?(hash2) # => true
  #   hash2.subset_of?(hash1) # => false
  #
  def subset_of?(other_hash)
    self.each_pair do |key, value|
      return false if !other_hash.has_key?(key) || !(other_hash[key] == value)
    end

    true
  end

  def superset_of?(other_hash)
    other_hash.subset_of?(self)
  end

end
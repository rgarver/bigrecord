require 'pathname'
require 'rubygems'
require 'set'


dir = Pathname(__FILE__).dirname.expand_path + 'big_index'
vendor_dir = Pathname(__FILE__).dirname.parent.expand_path + 'vendor'

require dir + 'support'
require dir + 'adapters'
require dir + 'repository'
require dir + 'resource'

# Pathname.glob(vendor_dir + '*.rb') do |file|
#   autoload :Solr, file
# end

autoload :Solr, (vendor_dir + 'solr').to_s

module BigIndex
  extend Assertions

  def self.root
    @root ||= Pathname(__FILE__).dirname.parent.expand_path
  end

  def self.vendor_root
    @vendor_root ||= (Pathname(__FILE__).dirname.parent + "vendor").expand_path
  end

  def self.setup(name, options)
    assert_kind_of 'name',      name,       Symbol, String
    assert_kind_of 'options',   options,    Hash

    name = name.to_sym if name.is_a?(String)

    adapter_name = options[:adapter].to_s

    class_name = adapter_name.capitalize + 'Adapter'

    unless Adapters::const_defined?(class_name)
      lib_name = "#{adapter_name}_adapter"
      begin
        require root + 'lib' + 'big_index' + 'adapters' + lib_name
      rescue LoadError => e
        begin
          require lib_name
        rescue Exception
          # library not found, raise the original error
          raise e
        end
      end
    end

    Repository.adapters[name] = Adapters::const_get(class_name).new(name, options)
  end

  def self.configurations
    @configurations.dup ||= {}
  end

  def self.configurations=(configurations)
    assert_kind_of 'configurations', configurations, Hash

    Repository.clear_adapters

    @configurations = {}
    configurations.each do |key,value|
      assert_kind_of 'value', value, Hash

      options = {}
      value.each do |k, opts|
        options[k.to_sym] = opts
      end

      @configurations[key.to_sym] = options
      setup(key.to_sym, options)
    end

    BigIndex::Repository.default_name = @configurations.keys[0] if @configurations.size == 1
  end

  def self.repository(name = nil) # :yields: current_context
    current_repository = if name
      raise ArgumentError, "First optional argument must be a Symbol, but was #{name.inspect}" unless name.is_a?(Symbol)
      Repository.context.detect { |r| r.name == name } || Repository.new(name)
    else
      Repository.context.last || Repository.new(Repository.default_name)
    end

    if block_given?
      current_repository.scope { |*block_args| yield(*block_args) }
    else
      current_repository
    end
  end

end

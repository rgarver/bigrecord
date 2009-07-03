module BigIndex

  class IndexField

    attr_reader :field, :field_name, :options, :block

    def initialize(field, block = nil)
      @field = field.dup
      @block = block

      @field_name = field.shift
      @options = field.shift || {}

      # Setting the default values
      @options[:finder_name] ||= field_name
      @options[:type] ||= :text
    end

    def [](name)
      @options[name]
    end

  end # class IndexField

end # module BigIndex

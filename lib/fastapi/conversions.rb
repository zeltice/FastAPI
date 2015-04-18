module FastAPI
  module Conversions

    def self.convert_type(val, type, field = nil)
      if val && is_array(field)
        JSON.parse(val).map { |inner_value| convert_value(inner_value, type) }
      else
        convert_value(val, type)
      end
    end

    private
    def self.is_array(field)
      field && field.respond_to?('array') && field.array
    end

    def self.convert_value(val, type)
      if val
        case type
        when :integer
          val.to_i
        when :float
          val.to_f
        when :boolean
          { 't' => true, 'f' => false }[val]
        else
          val
        end
      end
    end
  end
end

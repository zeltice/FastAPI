module FastAPI
  class Spoof

    def initialize(data, meta = {}, whitelist = nil)
      @data      = data
      @meta      = default_meta.merge(meta)
      @whitelist = whitelist
    end

    def spoof(data = nil)
      Oj.dump(meta: @meta, data: data || @data)
    end

    def spoof!
      spoof(prepared_data)
    end

    private
    def default_meta
      size = @data.respond_to?(:size) ? @data.size : 1

      { total: size, count: size, offset: 0, error: nil }
    end

    def prepared_data
      [*@data].map do |row|
        allowed_fields = allowed_fields(row.class)
        clean_data(attributes_and_associations(row), allowed_fields)
      end
    end

    def allowed_fields(klazz, nested = false)
      nested ? klazz.fastapi_fields_sub : klazz.fastapi_fields + @whitelist
    end

    def clean_data(entity, allowed_fields)
      entity.symbolize_keys.slice(*allowed_fields)
    end

    def attributes_and_associations(row)
      row.attributes.merge(loaded_associations(row))
    end

    def loaded_associations(row)
      row.association_cache.each_with_object({}) do |(name, association), results|
        allowed_fields = allowed_fields(association.klass, true)
        target         = association.target

        results[name] = retrieved_attributes(target, allowed_fields)
      end
    end

    def retrieved_attributes(target, allowed_fields)
      if target.respond_to?(:map)
        target.map { |element| clean_data(element.attributes, allowed_fields) }
      elsif target.present?
        clean_data(target.attributes, allowed_fields)
      end
    end
  end
end

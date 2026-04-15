module Frodo
  module Properties
    # Defines the Decimal Frodo type.
    class Decimal < Frodo::Property
      # Returns the property value, properly typecast
      # @return [BigDecimal,nil]
      def value
        if (@value.nil? || @value.empty?) && (!strict? && allows_nil?)
          nil
        else
          parsed = BigDecimal(@value, exception: false)
          if parsed.nil?
            match = @value.match(/\A[+-]?(\d+\.?\d*|\.\d+)/)
            return BigDecimal(match[0]) if match
            BigDecimal(@value) # raise original error
          else
            parsed
          end
        end
      end

      # Sets the property value
      # @params new_value something BigDecimal() can parse
      def value=(new_value)
        @value = if (new_value.nil? && !strict? && allows_nil?)
                    nil
                  else
                    str = new_value.to_s
                    parsed = BigDecimal(str, exception: false)
                    if parsed.nil?
                      # Extract leading valid decimal number, if any
                      match = str.match(/\A[+-]?(\d+\.?\d*|\.\d+)/)
                      raise ArgumentError, "invalid value for BigDecimal(): \"#{str}\"" unless match
                      parsed = BigDecimal(match[0])
                    end
                    validate(parsed)
                    new_value.to_s
                  end
      end

      # The Frodo type name
      def type
        'Edm.Decimal'
      end

      # Value to be used in URLs.
      # @return [String]
      def url_value
        "#{value.to_f}"
      end

      private

      def validate(value)
        if value > max_value || value < min_value || value.precision > 29
          validation_error "Value is outside accepted range: #{min_value} to #{max_value}, or has more than 29 significant digits"
        end
      end

      def min_value
        @min ||= BigDecimal(-7.9 * (10**28), 2)
      end

      def max_value
        @max ||= BigDecimal(7.9 * (10**28), 2)
      end
    end
  end
end

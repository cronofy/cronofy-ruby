module Cronofy
  module TimeEncoding
    def encode_event_time(value)
      case value
      when String
        value
      when Hash
        if value[:time]
          encoded_time = encode_event_time(value[:time])
          value.merge(time: encoded_time)
        else
          value
        end
      else
        to_iso8601(value)
      end
    end

    def to_iso8601(value)
      case value
      when NilClass, String
        value
      when Time
        value.getutc.iso8601
      else
        value.iso8601
      end
    end

  end
end

require "date"
require "hashie"
require "time"

module Cronofy
  class Credentials
    class LinkingProfile
      attr_reader :provider_name
      attr_reader :profile_id
      attr_reader :profile_name

      def initialize(hash)
        @provider_name = hash['provider_name'] || hash[:provider_name]
        @profile_id = hash['profile_id'] || hash[:profile_id]
        @profile_name = hash['profile_name'] || hash[:profile_name]
      end

      def to_h
        {
          provider_name: provider_name,
          profile_id: profile_id,
          profile_name: profile_name,
        }
      end

      def ==(other)
        case other
        when LinkingProfile
          self.provider_name == other.provider_name &&
            self.profile_id == other.profile_id &&
            self.profile_name == other.profile_name
        end
      end
    end

    attr_reader :access_token
    attr_reader :account_id
    attr_reader :expires_at
    attr_reader :expires_in
    attr_reader :linking_profile
    attr_reader :refresh_token
    attr_reader :scope

    def initialize(oauth_token)
      @access_token = oauth_token.token
      @account_id = oauth_token.params['account_id']
      @expires_at = oauth_token.expires_at
      @expires_in = oauth_token.expires_in
      @refresh_token = oauth_token.refresh_token
      @scope = oauth_token.params['scope']

      if details = oauth_token.params['linking_profile']
        @linking_profile = LinkingProfile.new(details)
      end
    end

    def to_h
      hash = {
        access_token: access_token,
        expires_at: expires_at,
        expires_in: expires_in,
        refresh_token: refresh_token,
        scope: scope,
      }

      if account_id
        hash[:account_id] = account_id
      end

      if linking_profile
        hash[:linking_profile] = linking_profile.to_h
      end

      hash
    end

    def to_hash
      warn "#to_hash has been deprecated, use #to_h instead"
      to_h
    end
  end

  module ISO8601Time
    def self.coerce(value)
      case value
      when Time
        value
      when String
        Time.iso8601(value)
      else
        raise ArgumentError, "Cannot coerce #{value.inspect} to Time"
      end
    end
  end

  class DateOrTime
    def initialize(args)
      # Prefer time if both provided as it is more accurate
      if args[:time]
        @time = args[:time]
      else
        @date = args[:date]
      end
    end

    def self.coerce(value)
      begin
        time = ISO8601Time.coerce(value)
      rescue
        begin
          date = Date.strptime(value, '%Y-%m-%d')
        rescue
        end
      end

      coerced = self.new(time: time, date: date)

      raise "Failed to coerce \"#{value}\"" unless coerced.time? or coerced.date?

      coerced
    end

    def date
      @date
    end

    def date?
      !!@date
    end

    def time
      @time
    end

    def time?
      !!@time
    end

    def to_date
      if date?
        date
      else
        time.to_date
      end
    end

    def to_time
      if time?
        time
      else
        # Convert dates to UTC time, not local time
        Time.utc(date.year, date.month, date.day)
      end
    end

    def ==(other)
      case other
      when DateOrTime
        if self.time?
          other.time? and self.time == other.time
        elsif self.date?
          other.date? and self.date == other.date
        else
          # Both neither date nor time
          self.time? == other.time? and self.date? == other.date?
        end
      else
        false
      end
    end

    def inspect
      to_s
    end

    def to_s
      if time?
        "<#{self.class} time=#{self.time}>"
      elsif date?
        "<#{self.class} date=#{self.date}>"
      else
        "<#{self.class} empty>"
      end
    end
  end

  class Account < Hashie::Mash
  end

  class Calendar < Hashie::Mash
  end

  class Channel < Hashie::Mash
  end

  class EventTime
    attr_reader :time
    attr_reader :tzid

    def initialize(time, tzid)
      @time = time
      @tzid = tzid
    end

    def self.coerce(value)
      case value
      when String
        DateOrTime.coerce(value)
      when Hash
        time_value = value["time"]
        tzid = value["tzid"]

        date_or_time = DateOrTime.coerce(time_value)

        new(date_or_time, tzid)
      end
    end

    def ==(other)
      case other
      when EventTime
        self.time == other.time && self.tzid == other.tzid
      else
        false
      end
    end
  end

  class Event < Hashie::Mash
    include Hashie::Extensions::Coercion

    coerce_key :start, EventTime
    coerce_key :end, EventTime

    coerce_key :created, ISO8601Time
    coerce_key :updated, ISO8601Time
  end

  module Events
    def self.coerce(values)
      values.map { |v| Event.new(v) }
    end
  end

  class PagedEventsResult < Hashie::Mash
    include Hashie::Extensions::Coercion

    coerce_key :events, Events
  end

  class FreeBusy < Hashie::Mash
    include Hashie::Extensions::Coercion

    coerce_key :start, EventTime
    coerce_key :end, EventTime
  end

  module FreeBusyEnumerable
    def self.coerce(values)
      values.map { |v| FreeBusy.new(v) }
    end
  end

  class PagedFreeBusyResult < Hashie::Mash
    include Hashie::Extensions::Coercion

    coerce_key :free_busy, FreeBusyEnumerable
  end

  class Profile < Hashie::Mash
  end
end

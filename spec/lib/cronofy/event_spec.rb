require_relative '../../spec_helper'

describe Cronofy::Event do
  context "UTC times" do
    let(:json) do
      '{
        "calendar_id": "cal_U9uuErStTG@EAAAB_IsAsykA2DBTWqQTf-f0kJw",
        "event_uid": "evt_external_54008b1a4a41730f8d5c6037",
        "summary": "Company Retreat",
        "description": "",
        "start": "2014-09-06",
        "end": "2014-09-08",
        "deleted": false,
        "location": {
          "description": "Beach"
        },
        "participation_status": "needs_action",
        "transparency": "opaque",
        "event_status": "confirmed",
        "categories": [],
        "attendees": [
        {
          "email": "example@cronofy.com",
          "display_name": "Example Person",
          "status": "needs_action"
        }
        ],
        "created": "2014-09-01T08:00:01Z",
        "updated": "2014-09-01T09:24:16Z"
      }'
    end

    let(:hash) do
      JSON.parse(json)
    end

    subject do
      Cronofy::Event.new(hash)
    end

    it "coerces the start date" do
      expect(subject.start).to eq(Cronofy::DateOrTime.coerce("2014-09-06"))
    end

    it "coerces the end date" do
      expect(subject.end).to eq(Cronofy::DateOrTime.coerce("2014-09-08"))
    end

    it "coerces the created time" do
      expect(subject.created).to eq(Time.parse("2014-09-01T08:00:01Z"))
    end

    it "coerces the updated time" do
      expect(subject.updated).to eq(Time.parse("2014-09-01T09:24:16Z"))
    end

    it "can be inspected" do
      expect(subject.inspect).to_not be_nil
    end
  end

  context "localized times" do
    let(:json) do
      '{
        "calendar_id": "cal_U9uuErStTG@EAAAB_IsAsykA2DBTWqQTf-f0kJw",
        "event_uid": "evt_external_54008b1a4a41730f8d5c6037",
        "summary": "Company Retreat",
        "description": "",
        "start": {
          "time": "2014-09-06T13:40:00+01:00",
          "tzid": "Europe/London"
        },
        "end": {
          "time": "2014-09-06T14:10:00+01:00",
          "tzid": "Europe/London"
        },
        "deleted": false,
        "location": {
          "description": "Beach"
        },
        "participation_status": "needs_action",
        "transparency": "opaque",
        "event_status": "confirmed",
        "categories": [],
        "attendees": [
        {
          "email": "example@cronofy.com",
          "display_name": "Example Person",
          "status": "needs_action"
        }
        ],
        "created": "2014-09-01T08:00:01Z",
        "updated": "2014-09-01T09:24:16Z"
      }'
    end

    let(:hash) do
      JSON.parse(json)
    end

    subject do
      Cronofy::Event.new(hash)
    end

    it "coerces the start date" do
      expect(subject.start).to eq(Cronofy::EventTime.coerce("time" => "2014-09-06T13:40:00+01:00", "tzid" => "Europe/London"))
    end

    it "coerces the end date" do
      expect(subject.end).to eq(Cronofy::EventTime.coerce("time" => "2014-09-06T14:10:00+01:00", "tzid" => "Europe/London"))
    end

    it "coerces the created time" do
      expect(subject.created).to eq(Time.parse("2014-09-01T08:00:01Z"))
    end

    it "coerces the updated time" do
      expect(subject.updated).to eq(Time.parse("2014-09-01T09:24:16Z"))
    end
  end
end

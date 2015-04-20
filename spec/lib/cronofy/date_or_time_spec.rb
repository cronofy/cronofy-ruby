require_relative '../../spec_helper'

describe Cronofy::DateOrTime do
  context ".coerce" do
    it "takes offset into account" do
      utc = Cronofy::DateOrTime.coerce("2015-04-20T06:00:00Z")
      local = Cronofy::DateOrTime.coerce("2015-04-20T07:00:00+01:00")

      expect(utc).to eq(local)
    end
  end
end

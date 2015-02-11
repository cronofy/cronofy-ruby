require 'spec_helper'

describe Cronofy::ResponseParser do
  it 'should return hash from a given response' do
    response = OpenStruct.new(body: '{"a": 1, "b": 2}')
    response_parser = Cronofy::ResponseParser.new(response)
    expect(response_parser.parse_json).to eq({'a' => 1, 'b' => 2})
  end
end

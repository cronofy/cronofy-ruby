require_relative '../../spec_helper'

describe Cronofy::Errors do
  class ResponseStub
    attr_reader :status
    attr_reader :headers
    attr_reader :body

    def initialize(status: nil, headers: nil, body: nil)
      @status = status
      @headers = headers
      @body = body
    end
  end

  let(:status) { 200 }
  let(:headers) { Hash.new }
  let(:body) { nil }

  let(:response) do
    ResponseStub.new(status: status, headers: headers, body: body)
  end

  context "422 Unprocessable response" do
    let(:status) { 422 }

    subject do
      Cronofy::InvalidRequestError.new('message', response)
    end

    context "expected body" do
      let(:body) do
        '{
          "errors": {
            "event_id": [
              {
                "key": "errors.required",
                "description": "required"
              }
            ]
          }
        }'
      end

      it "makes the errors accessible" do
        deserialized_errors = JSON.parse(body)["errors"]

        expect(deserialized_errors).to_not be_nil
        expect(deserialized_errors).to_not be_empty

        expect(subject.errors).to eq(deserialized_errors)
      end

      it "includes the errors in the message" do
        expect(subject.message).to eq('message - {"event_id"=>[{"key"=>"errors.required", "description"=>"required"}]}')
      end
    end

    context "errors field missing" do
      let(:body) do
        '{
          "unexpected": "json"
        }'
      end

      it "exposes an empty hash" do
        expect(subject.errors).to eq(Hash.new)
      end
    end

    context "body not valid json" do
      let(:body) do
        'Not JSON'
      end

      it "exposes an empty hash" do
        expect(subject.errors).to eq(Hash.new)
      end
    end
  end
end

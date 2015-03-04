
require_relative '../../spec_helper'

describe Cronofy::Client do
  before(:all) do
    WebMock.reset!
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  let(:request_url) { 'https://api.cronofy.com/v1/channels' }
  let(:token) { 'token_123' }
  let(:client) do
    Cronofy::Client.new('client_id_123', 'client_secret_456',
                        token, 'refresh_token_456')
  end
  let(:correct_response_headers) do
    { 'Content-Type' => 'application/json' }
  end

  shared_examples 'a Cronofy request' do
    it 'raises AuthenticationFailureError on 401s' do
      stub_request(method, request_url)
        .with(headers: request_headers,
              body: request_body)
        .to_return(status: 401,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)
      expect{ subject }.to raise_error(Cronofy::AuthenticationFailureError)
    end
    
    it 'raises AuthorizationFailureError on 403s' do
      stub_request(method, request_url)
        .with(headers: request_headers,
              body: request_body)
        .to_return(status: 403,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)
      expect{ subject }.to raise_error(Cronofy::AuthorizationFailureError)
    end
    
    it 'raises NotFoundError on 404s' do
      stub_request(method, request_url)
        .with(headers: request_headers,
              body: request_body)
        .to_return(status: 404,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)
      expect{ subject }.to raise_error(::Cronofy::NotFoundError)
    end
    
    it 'raises InvalidRequestError on 422s' do
      stub_request(method, request_url)
        .with(headers: request_headers,
              body: request_body)
        .to_return(status: 422,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)
      expect{ subject }.to raise_error(::Cronofy::InvalidRequestError)
    end

    it 'raises AuthenticationFailureError on 401s' do
      stub_request(method, request_url)
        .with(headers: request_headers,
              body: request_body)
        .to_return(status: 429,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)
      expect{ subject }.to raise_error(::Cronofy::TooManyRequestsError)
    end
    
  end

  describe '#create_channel' do
    let(:method) { :post }
    let(:callback_url) { 'http://call.back/url' }
    let(:request_headers) do
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}"
      }
    end
    let(:request_body) { hash_including(:callback_url => callback_url) }

    let(:correct_response_body) do
      {
        'channel' => {
          'channel_id' => 'channel_id_123',
          'callback_url' => ENV['CALLBACK_URL'],
          'filters' => {}
        }
      }
    end

    subject { client.create_channel(callback_url) }
    
    it 'returns the correct response when no error' do
      stub_request(method, request_url)
        .with(headers: request_headers,
              body: request_body)
        .to_return(status: 200,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)

      expect(subject).to eq correct_response_body
    end

    it_behaves_like 'a Cronofy request'
  end
  
  describe '#list_channels' do
    let(:method) { :get }
    let(:request_headers) do
      {
        'Authorization' => "Bearer #{token}"
      }
    end
    let(:request_body) { '' }

    let(:correct_response_body) do
      {
        'channels' => [
          {
            'channel_id' => 'channel_id_123',
            'callback_url' => 'http://call.back/url',
            'filters' => {}
          },
          {
            'channel_id' => 'channel_id_456',
            'callback_url' => 'http://call.back/url2',
            'filters' => {}
          }
        ]
      }
    end

    subject { client.list_channels }
    
    it 'returns the correct response when no error' do
      stub_request(method, request_url)
        .with(headers: request_headers)
        .to_return(status: 200,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)

      expect(subject).to eq correct_response_body
    end

    it_behaves_like 'a Cronofy request'
    
  end

end


require_relative '../../spec_helper'

describe Cronofy::Client do
  before(:all) do
    WebMock.reset!
    WebMock.disable_net_connect!(allow_localhost: true)
  end
  
  let(:token) { 'token_123' }
  let(:client) do
    Cronofy::Client.new('client_id_123', 'client_secret_456',
                        token, 'refresh_token_456')
  end
  let(:correct_response_headers) do
    { 'Content-Type' => 'application/json' }
  end

  shared_examples 'a Cronofy request' do
    it 'returns the correct response when no error' do
      stub_request(method, request_url)
        .with(headers: request_headers,
              body: request_body)
        .to_return(status: 200,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)

      expect(subject).to eq correct_response_body
    end
      
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

  describe '#list_calendars' do
    let(:request_url) { 'https://api.cronofy.com/v1/calendars' }
    let(:method) { :get }
    let(:request_headers) { { 'Authorization' => "Bearer #{token}" } }
    let(:request_body) { '' }
    let(:correct_response_body) do
      {
        "calendars" => [
                        {
                          "provider_name" => "google",
                          "profile_name" => "example@cronofy.com",
                          "calendar_id" => "cal_n23kjnwrw2_jsdfjksn234",
                          "calendar_name" => "Home",
                          "calendar_readonly" => false,
                          "calendar_deleted" => false
                        },
                        {
                          "provider_name" => "google",
                          "profile_name" => "example@cronofy.com",
                          "calendar_id" => "cal_n23kjnwrw2_n1k323nkj23",
                          "calendar_name" => "Work",
                          "calendar_readonly" => true,
                          "calendar_deleted" => true
                        },
                        {
                          "provider_name" => "apple",
                          "profile_name" => "example@cronofy.com",
                          "calendar_id" => "cal_n23kjnwrw2_3nkj23wejk1",
                          "calendar_name" => "Bank Holidays",
                          "calendar_readonly" => true,
                          "calendar_deleted" => false
                        }
                       ]
      }
    end

    subject { client.list_calendars }

    it_behaves_like 'a Cronofy request'
  end
  
  describe '#read_events' do
    let(:request_url_prefix) { 'https://api.cronofy.com/v1/events' }
    let(:method) { :get }
    let(:request_headers) { { 'Authorization' => "Bearer #{token}" } }
    let(:request_body) { '' }
    let(:correct_response_body) do
      {
        'pages' => {
          'current' => 1,
          'total' => 2,
          'next_page' => 'https://api.cronofy.com/v1/events/pages/08a07b034306679e'
        },
        'events' => [
          {
            'calendar_id' => 'cal_U9uuErStTG@EAAAB_IsAsykA2DBTWqQTf-f0kJw',
            'event_uid' => 'evt_external_54008b1a4a41730f8d5c6037',
            'summary' => 'Company Retreat',
            'description' => '',
            'start' => '2014-09-06',
            'end' => '2014-09-08',
            'deleted' => false
          },
          {
            'calendar_id' => 'cal_U9uuErStTG@EAAAB_IsAsykA2DBTWqQTf-f0kJw',
            'event_uid' => 'evt_external_54008b1a4a41730f8d5c6038',
            'summary' => 'Dinner with Laura',
            'description' => '',
            'start' => '2014-09-13T19:00:00Z',
            'end' => '2014-09-13T21:00:00Z',
            'deleted' => false,
            'location' => {
              'description' => 'Pizzeria'
            }
          }
        ]
      }
    end
      
    subject { client.read_events(params) }

    context 'when all params are passed' do
      let(:params) do
        {
          from: Time.new(2014, 9, 1, 0, 0, 1, '+00:00'),
          to: Time.new(2014, 10, 1, 0, 0, 1, '+00:00'),
          tzid: 'Etc/UTC',
          include_deleted: false,
          include_moved: true,
          last_modified: Time.new(2014, 8, 1, 0, 0, 1, '+00:00')
        }
      end
      let(:request_url) do
        "#{request_url_prefix}?from=2014-09-01T00:00:01Z" \
        "&to=2014-10-01T00:00:01Z&tzid=Etc/UTC&include_deleted=false" \
        "&include_moved=true&last_modified=2014-08-01T00:00:01Z"
      end

      it_behaves_like 'a Cronofy request'
    end

    context 'when some params are passed' do
      let(:params) do
        {
          from: Time.new(2014, 9, 1, 0, 0, 1, '+00:00'),
          include_deleted: false,
        }
      end
      let(:request_url) do
        "#{request_url_prefix}?from=2014-09-01T00:00:01Z" \
        "&tzid=Etc/UTC&include_deleted=false" \
        "&include_moved=false"
      end

      it_behaves_like 'a Cronofy request'
    end
  end
  
  describe '#get_events_page' do
    let(:request_url) { 'https://api.cronofy.com/v1/events/pages/08a07b034306679e' }
    let(:method) { :get }
    let(:request_headers) { { 'Authorization' => "Bearer #{token}" } }
    let(:request_body) { '' }
    let(:correct_response_body) do
      {
        'pages' => {
          'current' => 2,
          'total' => 2
        },
        'events' => [
          {
            'calendar_id' => 'cal_U9uuErStTG@EAAAB_IsAsykA2DBTWqQTf-f0kJw',
            'event_uid' => 'evt_external_54008b1a4a41730f8d5c6037',
            'summary' => 'Company Retreat',
            'description' => '',
            'start' => '2014-09-06',
            'end' => '2014-09-08',
            'deleted' => false
          },
          {
            'calendar_id' => 'cal_U9uuErStTG@EAAAB_IsAsykA2DBTWqQTf-f0kJw',
            'event_uid' => 'evt_external_54008b1a4a41730f8d5c6038',
            'summary' => 'Dinner with Laura',
            'description' => '',
            'start' => '2014-09-13T19:00:00Z',
            'end' => '2014-09-13T21:00:00Z',
            'deleted' => false,
            'location' => {
              'description' => 'Pizzeria'
            }
          }
        ]
      }
    end
      
    subject { client.get_events_page(request_url) }

    it_behaves_like 'a Cronofy request'
  end

  describe 'Channels' do
    let(:request_url) { 'https://api.cronofy.com/v1/channels' }
    
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

      it_behaves_like 'a Cronofy request'
      
    end

  end
end

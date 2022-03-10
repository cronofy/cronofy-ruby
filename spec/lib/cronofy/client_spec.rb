require_relative '../../spec_helper'

describe Cronofy::Client do
  before(:all) do
    WebMock.reset!
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  let(:token) { 'token_123' }
  let(:base_request_headers) do
    {
      "Authorization" => "Bearer #{token}",
      "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}",
    }
  end

  let(:json_request_headers) do
    base_request_headers.merge("Content-Type" => "application/json; charset=utf-8")
  end

  let(:request_headers) do
    base_request_headers
  end

  let(:request_body) { nil }

  let(:client) do
    Cronofy::Client.new(
      client_id: 'client_id_123',
      client_secret: 'client_secret_456',
      access_token: token,
      refresh_token: 'refresh_token_456',
    )
  end

  let(:correct_response_headers) do
    { 'Content-Type' => 'application/json; charset=utf-8' }
  end

  shared_examples 'a Cronofy request with mapped return value' do
    it 'returns the correct response when no error' do
      stub_request(method, request_url)
        .with(headers: request_headers,
              body: request_body)
        .to_return(status: correct_response_code,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)

      expect(subject).to eq correct_mapped_result
    end
  end

  shared_examples 'a Cronofy request' do
    it "doesn't raise an error when response is correct" do
      stub_request(method, request_url)
        .with(headers: request_headers,
              body: request_body)
        .to_return(status: correct_response_code,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)

      subject
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

    it 'raises AccountLockedError on 423s' do
      stub_request(method, request_url)
        .with(headers: request_headers,
              body: request_body)
        .to_return(status: 423,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)
      expect{ subject }.to raise_error(::Cronofy::AccountLockedError)
    end

    it 'raises TooManyRequestsError on 429s' do
      stub_request(method, request_url)
        .with(headers: request_headers,
              body: request_body)
        .to_return(status: 429,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)
      expect{ subject }.to raise_error(::Cronofy::TooManyRequestsError)
    end

    it 'raises ServerError on 500s' do
      stub_request(method, request_url)
        .with(headers: request_headers,
              body: request_body)
        .to_return(status: 500,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)
      expect{ subject }.to raise_error(::Cronofy::ServerError)
    end
  end

  describe '#create_calendar' do
    let(:request_url) { 'https://api.cronofy.com/v1/calendars' }
    let(:method) { :post }

    let(:profile_id) { "pro_1234" }
    let(:calendar_name) { "Home" }
    let(:color) { "#49BED8" }

    let(:correct_response_code) { 200 }
    let(:correct_response_body) do
      {
        "calendar" => {
          "provider_name" => "google",
          "profile_name" => "example@cronofy.com",
          "calendar_id" => "cal_n23kjnwrw2_jsdfjksn234",
          "calendar_name" => "Home",
          "calendar_readonly" => false,
          "calendar_deleted" => false
        }
      }
    end

    let(:correct_mapped_result) do
      Cronofy::Calendar.new(correct_response_body["calendar"])
    end

    context "with mandatory arguments" do
      let(:request_body) do
        {
          profile_id: profile_id,
          name: calendar_name,
        }
      end

      subject { client.create_calendar(profile_id, calendar_name) }

      it_behaves_like 'a Cronofy request'
      it_behaves_like 'a Cronofy request with mapped return value'
    end

    context "with color" do
      let(:request_body) do
        {
          profile_id: profile_id,
          name: calendar_name,
          color: color,
        }
      end

      subject { client.create_calendar(profile_id, calendar_name, color: color) }

      it_behaves_like 'a Cronofy request'
      it_behaves_like 'a Cronofy request with mapped return value'
    end
  end

  describe '#list_calendars' do
    let(:request_url) { 'https://api.cronofy.com/v1/calendars' }
    let(:method) { :get }
    let(:correct_response_code) { 200 }
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

    let(:correct_mapped_result) do
      correct_response_body["calendars"].map { |cal| Cronofy::Calendar.new(cal) }
    end

    subject { client.list_calendars }

    it_behaves_like 'a Cronofy request'
    it_behaves_like 'a Cronofy request with mapped return value'
  end

  describe 'Events' do
    describe '#create_or_update_event' do
      let(:calendar_id) { 'calendar_id_123'}
      let(:request_url) { "https://api.cronofy.com/v1/calendars/#{calendar_id}/events" }
      let(:url) { URI("https://example.com") }
      let(:method) { :post }
      let(:request_headers) { json_request_headers }

      let(:start_datetime) { Time.utc(2014, 8, 5, 15, 30, 0) }
      let(:end_datetime) { Time.utc(2014, 8, 5, 17, 0, 0) }
      let(:encoded_start_datetime) { "2014-08-05T15:30:00Z" }
      let(:encoded_end_datetime) { "2014-08-05T17:00:00Z" }
      let(:location) { { :description => "Board room" } }
      let(:transparency) { nil }

      let(:event) do
        {
          :event_id => "qTtZdczOccgaPncGJaCiLg",
          :summary => "Board meeting",
          :description => "Discuss plans for the next quarter.",
          :start => start_datetime,
          :end => end_datetime,
          :url => url,
          :location => location,
          :transparency => transparency,
          :reminders => [
            { :minutes => 60 },
            { :minutes => 0 },
            { :minutes => 10 },
          ],
        }
      end

      let(:request_body) do
        {
          :event_id => "qTtZdczOccgaPncGJaCiLg",
          :summary => "Board meeting",
          :description => "Discuss plans for the next quarter.",
          :start => encoded_start_datetime,
          :end => encoded_end_datetime,
          :url => url.to_s,
          :location => location,
          :transparency => transparency,
          :reminders => [
            { :minutes => 60 },
            { :minutes => 0 },
            { :minutes => 10 },
          ],
        }
      end
      let(:correct_response_code) { 202 }
      let(:correct_response_body) { nil }

      subject { client.create_or_update_event(calendar_id, event) }

      context 'when start/end are Times' do
        it_behaves_like 'a Cronofy request'
      end

      context 'when start/end are Dates' do
        let(:start_datetime) { Date.new(2014, 8, 5) }
        let(:end_datetime) { Date.new(2014, 8, 6) }
        let(:encoded_start_datetime) { "2014-08-05" }
        let(:encoded_end_datetime) { "2014-08-06" }

        it_behaves_like 'a Cronofy request'
      end

      context 'when start/end are complex times' do
        let(:start_datetime) do
          {
            :time => Time.utc(2014, 8, 5, 15, 30, 0),
            :tzid => "Europe/London",
          }
        end
        let(:end_datetime) do
          {
            :time => Time.utc(2014, 8, 5, 17, 0, 0),
            :tzid => "America/Los_Angeles",
          }
        end
        let(:encoded_start_datetime) do
          {
            :time => "2014-08-05T15:30:00Z",
            :tzid => "Europe/London",
          }
        end
        let(:encoded_end_datetime) do
          {
            :time => "2014-08-05T17:00:00Z",
            :tzid => "America/Los_Angeles",
          }
        end

        it_behaves_like 'a Cronofy request'
      end

      context 'when geo location present' do
        let(:location) { { :description => "Board meeting", :lat => "1.2345", :long => "0.1234" } }

        it_behaves_like 'a Cronofy request'
      end

      context 'when transparency present' do
        let(:transparency) { "transparent" }

        it_behaves_like 'a Cronofy request'
      end

      context 'when start and end already encoded' do
        let(:start_datetime) { encoded_start_datetime }
        let(:end_datetime) { encoded_end_datetime }

        it_behaves_like 'a Cronofy request'
      end
    end

    describe '#read_events' do
      before do
        stub_request(method, request_url)
          .with(headers: request_headers,
                body: request_body)
          .to_return(status: correct_response_code,
                     headers: correct_response_headers,
                     body: correct_response_body.to_json)

        stub_request(:get, next_page_url)
          .with(headers: request_headers)
          .to_return(status: correct_response_code,
            headers: correct_response_headers,
            body: next_page_body.to_json)
      end


      let(:request_url_prefix) { 'https://api.cronofy.com/v1/events' }
      let(:method) { :get }
      let(:correct_response_code) { 200 }
      let(:next_page_url) do
        "https://next.page.com/08a07b034306679e"
      end

      let(:params) { Hash.new }
      let(:request_url) { request_url_prefix + "?tzid=Etc/UTC" }

      let(:correct_response_body) do
        {
          'pages' => {
            'current' => 1,
            'total' => 2,
            'next_page' => next_page_url
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

      let(:next_page_body) do
        {
          'pages' => {
            'current' => 2,
            'total' => 2,
          },
          'events' => [
                       {
                         'calendar_id' => 'cal_U9uuErStTG@EAAAB_IsAsykA2DBTWqQTf-f0kJw',
                         'event_uid' => 'evt_external_54008b1a4a4173023402934d',
                         'summary' => 'Company Retreat Extended',
                         'description' => '',
                         'start' => '2014-09-06',
                         'end' => '2014-09-08',
                         'deleted' => false
                       },
                       {
                         'calendar_id' => 'cal_U9uuErStTG@EAAAB_IsAsykA2DBTWqQTf-f0kJw',
                         'event_uid' => 'evt_external_54008b1a4a41198273921312',
                         'summary' => 'Dinner with Paul',
                         'description' => '',
                         'start' => '2014-09-13T19:00:00Z',
                         'end' => '2014-09-13T21:00:00Z',
                         'deleted' => false,
                         'location' => {
                           'description' => 'Cafe'
                         }
                       }
                      ]
        }
      end

      let(:correct_mapped_result) do
        first_page_events = correct_response_body['events'].map { |event| Cronofy::Event.new(event) }
        second_page_events = next_page_body['events'].map { |event| Cronofy::Event.new(event) }

        first_page_events + second_page_events
      end

      subject do
        # By default force evaluation
        client.read_events(params).to_a
      end

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
        it_behaves_like 'a Cronofy request with mapped return value'
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
          "&tzid=Etc/UTC&include_deleted=false"
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "when unknown flags are passed" do
        let(:params) do
          {
            unknown_bool: true,
            unknown_number: 5,
            unknown_string: "foo-bar-baz",
          }
        end

        let(:request_url) do
          "#{request_url_prefix}?tzid=Etc/UTC" \
          "&unknown_bool=true" \
          "&unknown_number=5" \
          "&unknown_string=foo-bar-baz"
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "when calendar_ids are passed" do
        let(:params) do
          {
            calendar_ids: ["cal_1234_abcd", "cal_1234_efgh", "cal_5678_ijkl"],
          }
        end

        let(:request_url) do
          "#{request_url_prefix}?tzid=Etc/UTC" \
          "&calendar_ids[]=cal_1234_abcd" \
          "&calendar_ids[]=cal_1234_efgh" \
          "&calendar_ids[]=cal_5678_ijkl"
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "next page not found" do
        before do
          stub_request(:get, next_page_url)
            .with(headers: request_headers)
            .to_return(status: 404,
              headers: correct_response_headers)
        end

        it "raises an error" do
          expect{ subject }.to raise_error(::Cronofy::NotFoundError)
        end
      end

      context "only first event" do
        before do
          # Ensure an error if second page is requested
          stub_request(:get, next_page_url)
            .with(headers: request_headers)
            .to_return(status: 404,
              headers: correct_response_headers)
        end

        let(:first_event) do
          Cronofy::Event.new(correct_response_body["events"].first)
        end

        subject do
          client.read_events(params).first
        end

        it "returns the first event from the first page" do
          expect(subject).to eq(first_event)
        end
      end

      context "without calling #to_a to force full evaluation" do
        subject { client.read_events(params) }

        it_behaves_like 'a Cronofy request'

        # We expect it to behave like a Cronofy request as the first page is
        # requested eagerly so that the majority of errors will happen inline
        # rather than lazily happening wherever the iterator may have been
        # passed.
      end
    end

    describe '#delete_event' do
      let(:calendar_id) { 'calendar_id_123'}
      let(:request_url) { "https://api.cronofy.com/v1/calendars/#{calendar_id}/events" }
      let(:event_id) { 'event_id_456' }
      let(:method) { :delete }
      let(:request_headers) { json_request_headers }
      let(:request_body) { { :event_id => event_id } }
      let(:correct_response_code) { 202 }
      let(:correct_response_body) { nil }

      subject { client.delete_event(calendar_id, event_id) }

      it_behaves_like 'a Cronofy request'
    end

    describe '#delete_external_event' do
      let(:calendar_id) { 'calendar_id_123'}
      let(:request_url) { "https://api.cronofy.com/v1/calendars/#{calendar_id}/events" }
      let(:event_uid) { 'external_event_1023' }
      let(:method) { :delete }
      let(:request_headers) { json_request_headers }
      let(:request_body) { { :event_uid => event_uid } }
      let(:correct_response_code) { 202 }
      let(:correct_response_body) { nil }

      subject { client.delete_external_event(calendar_id, event_uid) }

      it_behaves_like 'a Cronofy request'
    end

    describe '#change_participation_status' do
      let(:calendar_id) { 'calendar_id_123'}
      let(:request_url) { "https://api.cronofy.com/v1/calendars/#{calendar_id}/events/#{event_uid}/participation_status" }
      let(:event_uid) { 'evt_external_54008b1a4a41730f8d5c6037' }
      let(:method) { :post }
      let(:request_headers) { json_request_headers }
      let(:status) { 'accepted' }
      let(:request_body) { { :status => status } }
      let(:correct_response_code) { 202 }
      let(:correct_response_body) { nil }

      subject { client.change_participation_status(calendar_id, event_uid, status) }

      it_behaves_like 'a Cronofy request'
    end

    describe '#delete_all_events' do
      context "default" do
        let(:request_url) { "https://api.cronofy.com/v1/events" }
        let(:method) { :delete }
        let(:request_headers) { json_request_headers }
        let(:request_body) { { :delete_all => true } }
        let(:correct_response_code) { 202 }
        let(:correct_response_body) { nil }

        subject { client.delete_all_events }

        it_behaves_like 'a Cronofy request'
      end

      context "specific calendars" do
        let(:calendar_ids) { %w{cal_1234_5678 cal_abcd_efgh} }
        let(:request_url) { "https://api.cronofy.com/v1/events" }
        let(:method) { :delete }
        let(:request_headers) { json_request_headers }
        let(:request_body) { { :calendar_ids => calendar_ids } }
        let(:correct_response_code) { 202 }
        let(:correct_response_body) { nil }

        subject { client.delete_all_events(calendar_ids: calendar_ids) }

        it_behaves_like 'a Cronofy request'
      end
    end
  end

  describe 'Service Account impersonation' do
    let(:calendar_id) { 'calendar_id_123'}
    let(:request_url) { "https://api.cronofy.com/v1/service_account_authorizations" }
    let(:method) { :post }
    let(:request_headers) { json_request_headers }
    let(:request_body) { { email: email, scope: scope.join(' '), callback_url: callback_url } }
    let(:correct_response_code) { 202 }
    let(:correct_response_body) { nil }
    let(:email) { "foo@example.com" }
    let(:scope) { ['foo', 'bar'] }
    let(:callback_url) { "http://example.com/not_found" }

    subject { client.authorize_with_service_account(email, scope, callback_url) }

    it_behaves_like 'a Cronofy request'
  end

  describe 'Channels' do
    let(:request_url) { 'https://api.cronofy.com/v1/channels' }

    describe '#create_channel' do
      let(:method) { :post }
      let(:callback_url) { 'http://call.back/url' }
      let(:request_headers) { json_request_headers }

      let(:correct_response_code) { 200 }
      let(:correct_response_body) do
        {
          'channel' => {
            'channel_id' => 'channel_id_123',
            'callback_url' => ENV['CALLBACK_URL'],
            'filters' => {}
          }
        }
      end

      let(:correct_mapped_result) do
        Cronofy::Channel.new(correct_response_body["channel"])
      end

      context "with filters" do
        let(:request_body) do
          {
            callback_url: callback_url,
            filters: filters,
          }
        end

        let(:filters) do
          {
            calendar_ids: ["cal_1234_abcd", "cal_1234_efgh", "cal_5678_ijkl"],
            only_managed: true,
            future_parameter: "for flexibility",
          }
        end

        subject { client.create_channel(callback_url, filters: filters) }

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "without filters" do
        let(:request_body) do
          {
            callback_url: callback_url,
          }
        end

        subject { client.create_channel(callback_url) }

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end
    end

    describe '#list_channels' do
      let(:method) { :get }

      let(:correct_response_code) { 200 }
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

      let(:correct_mapped_result) do
        correct_response_body["channels"].map { |ch| Cronofy::Channel.new(ch) }
      end

      subject { client.list_channels }

      it_behaves_like 'a Cronofy request'
      it_behaves_like 'a Cronofy request with mapped return value'
    end

    describe '#close_channel' do
      let(:channel_id) { "chn_1234567890" }
      let(:method) { :delete }
      let(:request_url) { "https://api.cronofy.com/v1/channels/#{channel_id}" }

      let(:correct_response_code) { 202 }
      let(:correct_response_body) { nil }

      subject { client.close_channel(channel_id) }

      it_behaves_like 'a Cronofy request'
    end
  end

  describe "ElevatedPermissions" do

    describe '#elevated_permissions' do
      let(:method) { :post }
      let(:request_url) { "https://api.cronofy.com/v1/permissions" }

      let(:correct_response_code) { 202 }

      let(:redirect_uri) { "http://www.example.com/redirect" }
      let(:permissions) do
        [
          {
            calendar_id: "cal_1234567",
            permission_level: "unrestricted"
          },
          {
            calendar_id: "cal_1234453",
            permission_level: "sandbox"
          }
        ]
      end

      let(:request_body) do
        {
          permissions: permissions,
          redirect_uri: redirect_uri,
        }
      end

      let(:correct_mapped_result) do
        Cronofy::PermissionsResponse.new(correct_response_body['permissions_request'])
      end

      describe "with uri supplied" do
        let(:correct_response_body) do
          {
            "permissions_request" => {
              "url" => "http://app.cronofy.com/permissions/"
            }
          }
        end

        subject { client.elevated_permissions(permissions: permissions, redirect_uri: redirect_uri) }

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      describe "without uri supplied" do
        let(:correct_response_body) do
          {
            "permissions_request" => {
              "accepted" => true
            }
          }
        end

        subject { client.elevated_permissions(permissions: permissions, redirect_uri: redirect_uri) }

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end
    end
  end

  describe "Account" do
    let(:request_url) { "https://api.cronofy.com/v1/account" }

    describe "#account" do
      let(:method) { :get }

      let(:correct_response_code) { 200 }
      let(:correct_response_body) do
        {
          "account" => {
            "account_id" => "acc_id_123",
            "email" => "foo@example.com",
          }
        }
      end

      let(:correct_mapped_result) do
        Cronofy::Account.new(correct_response_body["account"])
      end

      subject { client.account }

      it_behaves_like "a Cronofy request"
      it_behaves_like "a Cronofy request with mapped return value"
    end
  end

  describe "Userinfo" do
    let(:request_url) { "https://api.cronofy.com/v1/userinfo" }

    describe "#userinfo" do
      let(:method) { :get }

      let(:correct_response_code) { 200 }
      let(:correct_response_body) do
        {
          "sub" => "ser_5700a00eb0ccd07000000000",
          "cronofy.type" => "service_account",
          "cronofy.service_account.domain" => "example.com"
        }
      end

      let(:correct_mapped_result) do
        Cronofy::UserInfo.new(correct_response_body)
      end

      subject { client.userinfo }

      it_behaves_like "a Cronofy request"
      it_behaves_like "a Cronofy request with mapped return value"
    end
  end

  describe 'Profiles' do
    let(:request_url) { 'https://api.cronofy.com/v1/profiles' }

    describe '#profiles' do
      let(:method) { :get }

      let(:correct_response_code) { 200 }
      let(:correct_response_body) do
        {
          'profiles' => [
            {
              'provider_name' => 'google',
              'profile_id' => 'pro_n23kjnwrw2',
              'profile_name' => 'example@cronofy.com',
              'profile_connected' => true,
            },
            {
              'provider_name' => 'apple',
              'profile_id' => 'pro_n23kjnwrw2',
              'profile_name' => 'example@cronofy.com',
              'profile_connected' => false,
              'profile_relink_url' => 'http =>//to.cronofy.com/RaNggYu',
            },
          ]
        }
      end

      let(:correct_mapped_result) do
        correct_response_body["profiles"].map { |pro| Cronofy::Profile.new(pro) }
      end

      subject { client.list_profiles }

      it_behaves_like 'a Cronofy request'
      it_behaves_like 'a Cronofy request with mapped return value'
    end
  end

  describe 'Free busy' do
    describe '#free_busy' do
      before do
        stub_request(method, request_url)
          .with(headers: request_headers,
                body: request_body)
          .to_return(status: correct_response_code,
                     headers: correct_response_headers,
                     body: correct_response_body.to_json)

        stub_request(:get, next_page_url)
          .with(headers: request_headers)
          .to_return(status: correct_response_code,
            headers: correct_response_headers,
            body: next_page_body.to_json)
      end


      let(:request_url_prefix) { 'https://api.cronofy.com/v1/free_busy' }
      let(:method) { :get }
      let(:correct_response_code) { 200 }
      let(:next_page_url) do
        "https://next.page.com/08a07b034306679e"
      end

      let(:params) { Hash.new }
      let(:request_url) { request_url_prefix + "?tzid=Etc/UTC" }

      let(:correct_response_body) do
        {
          'pages' => {
            'current' => 1,
            'total' => 2,
            'next_page' => next_page_url
          },
          'free_busy' => [
                       {
                         'calendar_id' => 'cal_U9uuErStTG@EAAAB_IsAsykA2DBTWqQTf-f0kJw',
                         'start' => '2014-09-06',
                         'end' => '2014-09-08',
                         'free_busy_status' => 'busy',
                       },
                       {
                         'calendar_id' => 'cal_U9uuErStTG@EAAAB_IsAsykA2DBTWqQTf-f0kJw',
                         'start' => '2014-09-13T19:00:00Z',
                         'end' => '2014-09-13T21:00:00Z',
                         'free_busy_status' => 'tentative',
                       }
                      ]
        }
      end

      let(:next_page_body) do
        {
          'pages' => {
            'current' => 2,
            'total' => 2,
          },
          'free_busy' => [
                       {
                         'calendar_id' => 'cal_U9uuErStTG@EAAAB_IsAsykA2DBTWqQTf-f0kJw',
                         'start' => '2014-09-07',
                         'end' => '2014-09-09',
                         'free_busy_status' => 'busy',
                       },
                       {
                         'calendar_id' => 'cal_U9uuErStTG@EAAAB_IsAsykA2DBTWqQTf-f0kJw',
                         'start' => '2014-09-14T19:00:00Z',
                         'end' => '2014-09-14T21:00:00Z',
                         'free_busy_status' => 'tentative',
                       }
                      ]
        }
      end

      let(:correct_mapped_result) do
        first_page_items = correct_response_body['free_busy'].map { |period| Cronofy::FreeBusy.new(period) }
        second_page_items = next_page_body['free_busy'].map { |period| Cronofy::FreeBusy.new(period) }

        first_page_items + second_page_items
      end

      subject do
        # By default force evaluation
        client.free_busy(params).to_a
      end

      context 'when all params are passed' do
        let(:params) do
          {
            from: Time.new(2014, 9, 1, 0, 0, 1, '+00:00'),
            to: Time.new(2014, 10, 1, 0, 0, 1, '+00:00'),
            tzid: 'Etc/UTC',
            include_managed: true,
          }
        end
        let(:request_url) do
          "#{request_url_prefix}?from=2014-09-01T00:00:01Z" \
          "&to=2014-10-01T00:00:01Z&tzid=Etc/UTC&include_managed=true"
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context 'when some params are passed' do
        let(:params) do
          {
            from: Time.new(2014, 9, 1, 0, 0, 1, '+00:00'),
          }
        end
        let(:request_url) do
          "#{request_url_prefix}?from=2014-09-01T00:00:01Z" \
          "&tzid=Etc/UTC"
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "when unknown flags are passed" do
        let(:params) do
          {
            unknown_bool: true,
            unknown_number: 5,
            unknown_string: "foo-bar-baz",
          }
        end

        let(:request_url) do
          "#{request_url_prefix}?tzid=Etc/UTC" \
          "&unknown_bool=true" \
          "&unknown_number=5" \
          "&unknown_string=foo-bar-baz"
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "next page not found" do
        before do
          stub_request(:get, next_page_url)
            .with(headers: request_headers)
            .to_return(status: 404,
              headers: correct_response_headers)
        end

        it "raises an error" do
          expect{ subject }.to raise_error(::Cronofy::NotFoundError)
        end
      end

      context "only first period" do
        before do
          # Ensure an error if second page is requested
          stub_request(:get, next_page_url)
            .with(headers: request_headers)
            .to_return(status: 404,
              headers: correct_response_headers)
        end

        let(:first_period) do
          Cronofy::FreeBusy.new(correct_response_body["free_busy"].first)
        end

        subject do
          client.free_busy(params).first
        end

        it "returns the first period from the first page" do
          expect(subject).to eq(first_period)
        end
      end

      context "without calling #to_a to force full evaluation" do
        subject { client.free_busy(params) }

        it_behaves_like 'a Cronofy request'

        # We expect it to behave like a Cronofy request as the first page is
        # requested eagerly so that the majority of errors will happen inline
        # rather than lazily happening wherever the iterator may have been
        # passed.
      end
    end
  end

  describe 'Resources' do
    let(:request_url) { 'https://api.cronofy.com/v1/resources' }

    describe '#resources' do
      let(:method) { :get }

      let(:correct_response_code) { 200 }
      let(:correct_response_body) do
        {
          'resources' => [
            {
              'email' => 'board-room-london@example.com',
              'name' => 'Board room (London)',
            },
            {
              'email' => 'board-room-madrid@example.com',
              'name' => 'Board room (Madrid)',
            }
          ]
        }
      end

      let(:correct_mapped_result) do
        correct_response_body["resources"].map { |r| Cronofy::Resource.new(r) }
      end

      subject { client.resources }

      it_behaves_like 'a Cronofy request'
      it_behaves_like 'a Cronofy request with mapped return value'
    end
  end

  describe '#link_token' do
    let(:request_url) { 'https://api.cronofy.com/v1/link_tokens' }
    let(:method) { :post }
    let(:request_body) { nil }

    let(:correct_response_code) { 200 }
    let(:correct_response_body) do
      {
        "link_token" => "abcd1234"
      }
    end

    let(:correct_mapped_result) do
      "abcd1234"
    end

    subject { client.link_token }

    it_behaves_like 'a Cronofy request'
    it_behaves_like 'a Cronofy request with mapped return value'
  end

  describe '#element_token' do
    let(:permissions) { ["agenda", "availability"] }
    let(:subs) { ["acc_567236000909002", "acc_678347111010113"] }
    let(:origin) { "https://local.test/page" }

    let(:request_url) { 'https://api.cronofy.com/v1/element_tokens' }
    let(:method) { :post }

    let(:request_headers) do
      {
        "Authorization" => "Bearer #{client_secret}",
        "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}",
        "Content-Type" => "application/json; charset=utf-8",
      }
    end

    let(:request_body) do
      {
        permissions: permissions,
        subs: subs,
        origin: origin
      }
    end

    let(:expected_token) { "ELEMENT_TOKEN_1276534" }

    let(:correct_response_code) { 200 }
    let(:correct_response_body) do
      {
        "element_token" => {
          "permissions" => permissions,
          "origin" => origin,
          "token" => expected_token,
          "expires_in" => 64800
        }
      }
    end

    let(:correct_mapped_result) do
      Cronofy::ElementToken.new(correct_response_body['element_token'])
    end

    let(:client_id) { 'example_id' }
    let(:client_secret) { 'example_secret' }

    let(:client) do
      Cronofy::Client.new(
        client_id: client_id,
        client_secret: client_secret,
      )
    end

    subject do
      client.element_token({
        permissions: permissions,
        subs: subs,
        origin: origin
      })
    end

    it_behaves_like 'a Cronofy request'
    it_behaves_like 'a Cronofy request with mapped return value'
  end

  describe '#revoke_profile_authorization' do
    let(:request_url) { "https://api.cronofy.com/v1/profiles/#{profile_id}/revoke" }
    let(:method) { :post }
    let(:request_body) { nil }
    let(:profile_id) { "pro_1234abc" }

    let(:correct_response_code) { 202 }
    let(:correct_response_body) { nil }

    subject { client.revoke_profile_authorization(profile_id) }

    it_behaves_like 'a Cronofy request'
  end

  describe 'Availability' do
    describe '#availability' do
      let(:method) { :post }
      let(:request_url) { 'https://api.cronofy.com/v1/availability' }
      let(:request_headers) { json_request_headers }

      let(:client_id) { 'example_id' }
      let(:client_secret) { 'example_secret' }
      let(:token) { client_secret }

      let(:client) do
        Cronofy::Client.new(
          client_id: client_id,
          client_secret: client_secret,
        )
      end

      let(:request_body) do
        {
          "participants" => [
            {
              "members" => [
                { "sub" => "acc_567236000909002" },
                { "sub" => "acc_678347111010113" }
              ],
              "required" => "all"
            }
          ],
          "required_duration" => { "minutes" => 60 },
          "available_periods" => [
            {
              "start" => "2017-01-03T09:00:00Z",
              "end" => "2017-01-03T18:00:00Z"
            },
            {
              "start" => "2017-01-04T09:00:00Z",
              "end" => "2017-01-04T18:00:00Z"
            }
          ]
        }
      end

      let(:availability_response_attribute) { "available_periods" }
      let(:availability_response_class) { Cronofy::AvailablePeriod }

      let(:correct_response_code) { 200 }
      let(:correct_response_body) do
        {
          availability_response_attribute => [
            {
              "start" => "2017-01-03T09:00:00Z",
              "end" => "2017-01-03T11:00:00Z",
              "participants" => [
                { "sub" => "acc_567236000909002" },
                { "sub" => "acc_678347111010113" }
              ]
            },
            {
              "start" => "2017-01-03T14 =>00:00Z",
              "end" => "2017-01-03T16:00:00Z",
              "participants" => [
                { "sub" => "acc_567236000909002" },
                { "sub" => "acc_678347111010113" }
              ]
            },
            {
              "start" => "2017-01-04T11:00:00Z",
              "end" => "2017-01-04T17:00:00Z",
              "participants" => [
                { "sub" => "acc_567236000909002" },
                { "sub" => "acc_678347111010113" }
              ]
            },
          ]
        }
      end

      let(:correct_mapped_result) do
        correct_response_body[availability_response_attribute].map { |ap| availability_response_class.new(ap) }
      end

      subject { client.availability(participants: participants, required_duration: required_duration, available_periods: available_periods) }

      context "response_format" do
        %i{
          slots
          overlapping_slots
        }.each do |slot_format|
          context slot_format do
            let(:response_format) { slot_format.to_s }
            let(:availability_response_attribute) { "available_slots" }
            let(:availability_response_class) { Cronofy::AvailableSlot }

            let(:required_duration) do
              { minutes: 60 }
            end

            let(:available_periods) do
              [
                { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T18:00:00Z") },
                { start: Time.parse("2017-01-04T09:00:00Z"), end: Time.parse("2017-01-04T18:00:00Z") },
              ]
            end

            let(:participants) do
              [
                {
                  members: [
                    { sub: "acc_567236000909002" },
                    { sub: "acc_678347111010113" },
                  ],
                  required: :all,
                }
              ]
            end

            let(:request_body) do
              {
                "participants" => [
                  {
                    "members" => [
                      { "sub" => "acc_567236000909002" },
                      { "sub" => "acc_678347111010113" }
                    ],
                    "required" => "all"
                  }
                ],
                "required_duration" => { "minutes" => 60 },
                "available_periods" => [
                  {
                    "start" => "2017-01-03T09:00:00Z",
                    "end" => "2017-01-03T18:00:00Z"
                  },
                  {
                    "start" => "2017-01-04T09:00:00Z",
                    "end" => "2017-01-04T18:00:00Z"
                  }
                ],
                "response_format" => response_format,
              }
            end

            subject do
              client.availability(
                participants: participants,
                required_duration: required_duration,
                available_periods: available_periods,
                response_format: slot_format,
              )
            end

            it_behaves_like 'a Cronofy request'
            it_behaves_like 'a Cronofy request with mapped return value'
          end
        end
      end

      context "fully specified" do
        let(:participants) do
          [
            {
              members: [
                { sub: "acc_567236000909002" },
                { sub: "acc_678347111010113" },
              ],
              required: :all,
            }
          ]
        end

        let(:required_duration) do
          { minutes: 60 }
        end

        let(:available_periods) do
          [
            { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T18:00:00Z") },
            { start: Time.parse("2017-01-04T09:00:00Z"), end: Time.parse("2017-01-04T18:00:00Z") },
          ]
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "buffer and start_interval" do
        let(:request_body) do
          {
            "participants" => [
              {
                "members" => [
                  { "sub" => "acc_567236000909002" },
                  { "sub" => "acc_678347111010113" }
                ],
                "required" => "all"
              }
            ],
            "required_duration" => { "minutes" => 60 },
            "buffer" => {
              "before": { "minutes": 30 },
              "after": { "minutes": 60 },
            },
            "start_interval" => { "minutes" => 60 },
            "available_periods" => [
              {
                "start" => "2017-01-03T09:00:00Z",
                "end" => "2017-01-03T18:00:00Z"
              },
              {
                "start" => "2017-01-04T09:00:00Z",
                "end" => "2017-01-04T18:00:00Z"
              },
            ]
          }
        end

        let(:participants) do
          [
            {
              members: [
                { sub: "acc_567236000909002" },
                { sub: "acc_678347111010113" },
              ],
              required: :all,
            }
          ]
        end

        let(:buffer) do
          {
            before: { minutes: 30 },
            after: { minutes: 60 },
          }
        end

        let(:start_interval) do
          { minutes: 60 }
        end

        let(:required_duration) do
          { minutes: 60 }
        end

        let(:available_periods) do
          [
            { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T18:00:00Z") },
            { start: Time.parse("2017-01-04T09:00:00Z"), end: Time.parse("2017-01-04T18:00:00Z") },
          ]
        end

        subject { client.availability(participants: participants, required_duration: required_duration, available_periods: available_periods, buffer: buffer, start_interval: start_interval) }

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "member-specific available periods" do
        let(:request_body) do
          {
            "participants" => [
              {
                "members" => [
                  { "sub" => "acc_567236000909002" },
                  {
                    "sub" => "acc_678347111010113",
                    "available_periods" => [
                      {
                        "start" => "2017-01-03T09:00:00Z",
                        "end" => "2017-01-03T12:00:00Z"
                      },
                      {
                        "start" => "2017-01-04T10:00:00Z",
                        "end" => "2017-01-04T20:00:00Z"
                      }
                    ]
                  }
                ],
                "required" => "all"
              }
            ],
            "required_duration" => { "minutes" => 60 },
            "available_periods" => [
              {
                "start" => "2017-01-03T09:00:00Z",
                "end" => "2017-01-03T18:00:00Z"
              },
              {
                "start" => "2017-01-04T09:00:00Z",
                "end" => "2017-01-04T18:00:00Z"
              }
            ]
          }
        end

        let(:participants) do
          [
            {
              members: [
                { sub: "acc_567236000909002" },
                {
                  sub: "acc_678347111010113",
                  available_periods: [
                    { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T12:00:00Z") },
                    { start: Time.parse("2017-01-04T10:00:00Z"), end: Time.parse("2017-01-04T20:00:00Z") },
                  ],
                },
              ],
              required: :all,
            }
          ]
        end

        let(:required_duration) do
          { minutes: 60 }
        end

        let(:available_periods) do
          [
            { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T18:00:00Z") },
            { start: Time.parse("2017-01-04T09:00:00Z"), end: Time.parse("2017-01-04T18:00:00Z") },
          ]
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "reused member-specific available periods" do
        let(:request_body) do
          {
            "participants" => [
              {
                "members" => [
                  {
                    "sub" => "acc_567236000909002",
                    "available_periods" => [
                      {
                        "start" => "2017-01-03T09:00:00Z",
                        "end" => "2017-01-03T12:00:00Z"
                      },
                    ]
                  },
                  {
                    "sub" => "acc_678347111010113",
                    "available_periods" => [
                      {
                        "start" => "2017-01-03T09:00:00Z",
                        "end" => "2017-01-03T12:00:00Z"
                      },
                    ]
                  }
                ],
                "required" => "all"
              }
            ],
            "required_duration" => { "minutes" => 60 },
            "available_periods" => [
              {
                "start" => "2017-01-03T09:00:00Z",
                "end" => "2017-01-03T18:00:00Z"
              },
              {
                "start" => "2017-01-04T09:00:00Z",
                "end" => "2017-01-04T18:00:00Z"
              }
            ]
          }
        end

        let(:participants) do
          available_periods = [{ start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T12:00:00Z") }]
          [
            {
              members: [
                { sub: "acc_567236000909002", available_periods: available_periods },
                { sub: "acc_678347111010113", available_periods: available_periods },
              ],
              required: :all,
            }
          ]
        end

        let(:required_duration) do
          { minutes: 60 }
        end

        let(:available_periods) do
          [
            { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T18:00:00Z") },
            { start: Time.parse("2017-01-04T09:00:00Z"), end: Time.parse("2017-01-04T18:00:00Z") },
          ]
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "member-specific calendars" do
        let(:request_body) do
          {
            "participants" => [
              {
                "members" => [
                  { "sub" => "acc_567236000909002" },
                  {
                    "sub" => "acc_678347111010113",
                    "calendar_ids" => [
                      "cal_1234_5678",
                      "cal_9876_5432",
                    ]
                  }
                ],
                "required" => "all"
              }
            ],
            "required_duration" => { "minutes" => 60 },
            "available_periods" => [
              {
                "start" => "2017-01-03T09:00:00Z",
                "end" => "2017-01-03T18:00:00Z"
              },
              {
                "start" => "2017-01-04T09:00:00Z",
                "end" => "2017-01-04T18:00:00Z"
              }
            ]
          }
        end

        let(:participants) do
          [
            {
              members: [
                { sub: "acc_567236000909002" },
                {
                  sub: "acc_678347111010113",
                  calendar_ids: [
                    "cal_1234_5678",
                    "cal_9876_5432",
                  ],
                },
              ],
              required: :all,
            }
          ]
        end

        let(:required_duration) do
          { minutes: 60 }
        end

        let(:available_periods) do
          [
            { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T18:00:00Z") },
            { start: Time.parse("2017-01-04T09:00:00Z"), end: Time.parse("2017-01-04T18:00:00Z") },
          ]
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "simple values to defaults" do
        let(:participants) do
          { members: %w{acc_567236000909002 acc_678347111010113} }
        end

        let(:required_duration) { 60 }

        let(:available_periods) do
          [
            { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T18:00:00Z") },
            { start: Time.parse("2017-01-04T09:00:00Z"), end: Time.parse("2017-01-04T18:00:00Z") },
          ]
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "when given query_periods instead of available_periods" do
        let(:participants) do
          { members: %w{acc_567236000909002 acc_678347111010113} }
        end

        let(:required_duration) { 60 }

        let(:query_periods) do
          [
            { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T18:00:00Z") },
            { start: Time.parse("2017-01-04T09:00:00Z"), end: Time.parse("2017-01-04T18:00:00Z") },
          ]
        end

        let(:request_body) do
          {
            "participants" => [
              {
                "members" => [
                  { "sub" => "acc_567236000909002" },
                  { "sub" => "acc_678347111010113" }
                ],
                "required" => "all"
              }
            ],
            "query_periods" => [
              {
                "start" => "2017-01-03T09:00:00Z",
                "end" => "2017-01-03T18:00:00Z"
              },
              {
                "start" => "2017-01-04T09:00:00Z",
                "end" => "2017-01-04T18:00:00Z"
              }
            ],
            "required_duration" => { "minutes" => 60 },
          }
        end

        subject do
          client.availability(
            participants: participants,
            required_duration: required_duration,
            query_periods: query_periods
          )
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "when trying to auth with only an access_token, as originally implemented" do
        let(:access_token) { "access_token_123"}
        let(:client) { Cronofy::Client.new(access_token: access_token) }
        let(:request_headers) do
          {
            "Authorization" => "Bearer #{access_token}",
            "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}",
            "Content-Type" => "application/json; charset=utf-8",
          }
        end

        let(:participants) do
          { members: %w{acc_567236000909002 acc_678347111010113} }
        end

        let(:required_duration) { 60 }

        let(:available_periods) do
          [
            { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T18:00:00Z") },
            { start: Time.parse("2017-01-04T09:00:00Z"), end: Time.parse("2017-01-04T18:00:00Z") },
          ]
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "when trying to auth with both a client_secret and access_token" do
        let(:access_token) { "access_token_123" }
        let(:client_secret) { "client_secret_456" }
        let(:client) { Cronofy::Client.new(access_token: access_token, client_secret: client_secret) }
        let(:request_headers) do
          {
            "Authorization" => "Bearer #{access_token}",
            "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}",
            "Content-Type" => "application/json; charset=utf-8",
          }
        end

        let(:participants) do
          { members: %w{acc_567236000909002 acc_678347111010113} }
        end

        let(:required_duration) { 60 }

        let(:available_periods) do
          [
            { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T18:00:00Z") },
            { start: Time.parse("2017-01-04T09:00:00Z"), end: Time.parse("2017-01-04T18:00:00Z") },
          ]
        end

        describe "it prefers the access_token for backward compatibility" do
          it_behaves_like 'a Cronofy request'
          it_behaves_like 'a Cronofy request with mapped return value'
        end
      end

      context "when trying to auth without a client_secret or access_token" do
        let(:client) { Cronofy::Client.new }

        let(:participants) do
          { members: %w{acc_567236000909002 acc_678347111010113} }
        end

        let(:required_duration) { 60 }

        let(:available_periods) do
          [
            { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T18:00:00Z") },
            { start: Time.parse("2017-01-04T09:00:00Z"), end: Time.parse("2017-01-04T18:00:00Z") },
          ]
        end


        it "raises an API Key error" do
          expect{ subject }.to raise_error(Cronofy::CredentialsMissingError)
        end
      end
    end
  end

  describe 'Sequenced Availability' do
    describe '#sequenced_availability' do
      let(:method) { :post }
      let(:request_url) { 'https://api.cronofy.com/v1/sequenced_availability' }
      let(:request_headers) { json_request_headers }

      let(:client_id) { 'example_id' }
      let(:client_secret) { 'example_secret' }
      let(:token) { client_secret }

      let(:client) do
        Cronofy::Client.new(
          client_id: client_id,
          client_secret: client_secret,
        )
      end

      let(:request_body) do
        {
          "sequence" => [
            {
              "sequence_id" => 1234,
              "ordinal" => 1,
              "participants" => [
                {
                  "members" => [
                    { "sub" => "acc_567236000909002" },
                    { "sub" => "acc_678347111010113" }
                  ],
                  "required" => "all"
                }
              ],
              "required_duration" => { "minutes" => 60 },
              "start_interval" => { "minutes" => 60 },
              "buffer" => {
                "before": {
                  "minimum": { "minutes" => 30 },
                  "maximum": { "minutes" => 45 },
                },
                "after": {
                  "minimum": { "minutes" => 45 },
                  "maximum": { "minutes" => 60 },
                },
              }
            },
            {
              "sequence_id" => 4567,
              "ordinal" => 2,
              "participants" => [
                {
                  "members" => [
                    { "sub" => "acc_567236000909002" },
                    { "sub" => "acc_678347111010113" }
                  ],
                  "required" => "all"
                }
              ],
              "required_duration" => { "minutes" => 60 },
            }
          ],
          "available_periods" => [
            {
              "start" => "2017-01-03T09:00:00Z",
              "end" => "2017-01-03T18:00:00Z"
            },
            {
              "start" => "2017-01-04T09:00:00Z",
              "end" => "2017-01-04T18:00:00Z"
            }
          ]
        }
      end

      let(:correct_response_code) { 200 }
      let(:correct_response_body) do
        {
          "sequences" => [
            {
              "sequence" => [
                {
                  "sequence_id" => 1234,
                  "start" => "2017-01-03T09:00:00Z",
                  "end" => "2017-01-03T11:00:00Z",
                  "participants" => [
                    { "sub" => "acc_567236000909002" },
                    { "sub" => "acc_678347111010113" }
                  ]
                },
                {
                  "sequence_id" => 4567,
                  "start" => "2017-01-03T14:00:00Z",
                  "end" => "2017-01-03T16:00:00Z",
                  "participants" => [
                    { "sub" => "acc_567236000909002" },
                    { "sub" => "acc_678347111010113" }
                  ]
                },
              ]
            }
          ]
        }
      end

      let(:correct_mapped_result) do
        correct_response_body['sequences'].map { |sequence| Cronofy::Sequence.new(sequence) }
      end

      let(:args) do
        {
          sequence: [{
            sequence_id: 1234,
            ordinal: 1,
            participants: participants,
            required_duration: required_duration,
            start_interval: { minutes: 60 },
            buffer: {
              before: {
                minimum: { minutes: 30 },
                maximum: { minutes: 45 },
              },
              after: {
                minimum: { minutes: 45 },
                maximum: { minutes: 60 },
              },
            },
          },
          {
            sequence_id: 4567,
            ordinal: 2,
            participants: participants,
            required_duration: required_duration,
          }],
          available_periods: available_periods
        }
      end

      subject { client.sequenced_availability(args) }

      let(:participants) do
        [
          {
            members: [
              { sub: "acc_567236000909002" },
              { sub: "acc_678347111010113" },
            ],
            required: :all,
          }
        ]
      end

      let(:required_duration) do
        { minutes: 60 }
      end

      let(:available_periods) do
        [
          { start: Time.parse("2017-01-03T09:00:00Z"), end: Time.parse("2017-01-03T18:00:00Z") },
          { start: Time.parse("2017-01-04T09:00:00Z"), end: Time.parse("2017-01-04T18:00:00Z") },
        ]
      end

      it_behaves_like 'a Cronofy request'
      it_behaves_like 'a Cronofy request with mapped return value'

      context "when passing query_periods instead" do
        before do
          args[:query_periods] = args[:available_periods]
          args.delete(:available_periods)
          request_body["query_periods"] = request_body["available_periods"]
          request_body.delete("available_periods")
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "when trying to auth with access_token only" do
        let(:access_token) { "access_token_123"}
        let(:client) { Cronofy::Client.new(access_token: access_token) }
        let(:request_headers) do
          {
            "Authorization" => "Bearer #{access_token}",
            "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}",
            "Content-Type" => "application/json; charset=utf-8",
          }
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end

      context "when trying to auth with both access_token and client_secret provided" do
        let(:client_id) { 'example_id' }
        let(:client_secret) { 'example_secret' }
        let(:access_token) { "access_token_123"}

        let(:client) do
          Cronofy::Client.new(
            client_id: client_id,
            client_secret: client_secret,
            access_token: access_token,
          )
        end
        let(:request_headers) do
          {
            "Authorization" => "Bearer #{access_token}",
            "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}",
            "Content-Type" => "application/json; charset=utf-8",
          }
        end

        it_behaves_like 'a Cronofy request'
        it_behaves_like 'a Cronofy request with mapped return value'
      end
    end
  end

  describe "Add to calendar" do
    let(:request_url) { "https://api.cronofy.com/v1/add_to_calendar" }
    let(:url) { URI("https://example.com") }
    let(:method) { :post }
    let(:request_headers) { json_request_headers }

    let(:start_datetime) { Time.utc(2014, 8, 5, 15, 30, 0) }
    let(:end_datetime) { Time.utc(2014, 8, 5, 17, 0, 0) }
    let(:encoded_start_datetime) { "2014-08-05T15:30:00Z" }
    let(:encoded_end_datetime) { "2014-08-05T17:00:00Z" }
    let(:location) { { :description => "Board room" } }
    let(:transparency) { nil }
    let(:client_id) { 'example_id' }
    let(:client_secret) { 'example_secret' }
    let(:scope) { 'read_events delete_events' }
    let(:state) { 'example_state' }
    let(:redirect_uri) { 'http://example.com/redirect' }

    let(:client) do
      Cronofy::Client.new(
        client_id: client_id,
        client_secret: client_secret,
        access_token: token,
      )
    end

    let(:event) do
      {
        :event_id => "qTtZdczOccgaPncGJaCiLg",
        :summary => "Board meeting",
        :description => "Discuss plans for the next quarter.",
        :start => start_datetime,
        :end => end_datetime,
        :url => url,
        :location => location,
        :transparency => transparency,
        :reminders => [
          { :minutes => 60 },
          { :minutes => 0 },
          { :minutes => 10 },
        ],
      }
    end

    let(:oauth_body) do
      {
        scope: scope,
        redirect_uri: redirect_uri,
        state: state,
      }
    end

    let(:args) do
      {
        oauth: oauth_body,
        event: event,
        target_calendars: target_calendars,
      }
    end

    let(:target_calendars) do
      [
        {
          sub: "acc_567236000909002",
          calendar_id: "cal_n23kjnwrw2_jsdfjksn234",
        }
      ]
    end

    let(:request_body) do
      {
        client_id: client_id,
        client_secret: client_secret,
        oauth: oauth_body,
        event: {
          :event_id => "qTtZdczOccgaPncGJaCiLg",
          :summary => "Board meeting",
          :description => "Discuss plans for the next quarter.",
          :start => encoded_start_datetime,
          :end => encoded_end_datetime,
          :url => url.to_s,
          :location => location,
          :transparency => transparency,
          :reminders => [
            { :minutes => 60 },
            { :minutes => 0 },
            { :minutes => 10 },
          ],
        },
        target_calendars: target_calendars,
      }
    end
    let(:correct_response_code) { 202 }
    let(:correct_response_body) do
      {
        oauth_url: "http://www.example.com/oauth?token=example"
      }
    end

    subject { client.add_to_calendar(args) }

    context 'when start/end are Times' do
      it_behaves_like 'a Cronofy request'
    end

  end

  describe "Real time scheduling" do
    let(:request_url) { "https://api.cronofy.com/v1/real_time_scheduling" }
    let(:url) { URI("https://example.com") }
    let(:method) { :post }

    let(:request_headers) do
      {
        "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}",
        "Content-Type" => "application/json; charset=utf-8",
      }
    end

    let(:location) { { :description => "Board room" } }
    let(:transparency) { nil }
    let(:client_id) { 'example_id' }
    let(:client_secret) { 'example_secret' }
    let(:scope) { 'read_events delete_events' }
    let(:state) { 'example_state' }
    let(:redirect_uri) { 'http://example.com/redirect' }

    let(:client) do
      Cronofy::Client.new(
        client_id: client_id,
        client_secret: client_secret,
      )
    end

    let(:event) do
      {
        :event_id => "qTtZdczOccgaPncGJaCiLg",
        :summary => "Board meeting",
        :description => "Discuss plans for the next quarter.",
        :url => url,
        :location => location,
        :transparency => transparency,
        :reminders => [
          { :minutes => 60 },
          { :minutes => 0 },
          { :minutes => 10 },
        ],
      }
    end

    let(:oauth_body) do
      {
        scope: scope,
        redirect_uri: redirect_uri,
        state: state,
      }
    end

    let(:target_calendars) do
      [
        {
          sub: "acc_567236000909002",
          calendar_id: "cal_n23kjnwrw2_jsdfjksn234",
        }
      ]
    end

    let(:availability) do
      {
        participants: [
          {
            members: [{
              sub: "acc_567236000909002",
              calendar_ids: ["cal_n23kjnwrw2_jsdfjksn234"]
            }],
            required: 'all'
          }
        ],
        required_duration: { minutes: 60 },
        available_periods: [{
          start: Time.utc(2017, 1, 1, 9, 00),
          end:   Time.utc(2017, 1, 1, 17, 00),
        }],
        start_interval: { minutes: 60 },
        buffer: {
          before: { minutes: 30 },
          after: { minutes: 45 },
        }
      }
    end

    let(:mapped_availability) do
      {
        participants: [
          {
            members: [{
              sub: "acc_567236000909002",
              calendar_ids: ["cal_n23kjnwrw2_jsdfjksn234"]
            }],
            required: 'all'
          }
        ],
        required_duration: { minutes: 60 },
        start_interval: { minutes: 60 },
        buffer: {
          before: { minutes: 30 },
          after: { minutes: 45 },
        },
        available_periods: [{
          start: "2017-01-01T09:00:00Z",
          end:   "2017-01-01T17:00:00Z",
        }]
      }
    end

    let(:args) do
      {
        oauth: oauth_body,
        event: event,
        target_calendars: target_calendars,
        availability: availability,
      }
    end

    let(:request_body) do
      {
        client_id: client_id,
        client_secret: client_secret,
        oauth: oauth_body,
        event: {
          :event_id => "qTtZdczOccgaPncGJaCiLg",
          :summary => "Board meeting",
          :description => "Discuss plans for the next quarter.",
          :url => url.to_s,
          :location => location,
          :transparency => transparency,
          :reminders => [
            { :minutes => 60 },
            { :minutes => 0 },
            { :minutes => 10 },
          ],
        },
        target_calendars: target_calendars,
        availability: mapped_availability,
      }
    end
    let(:correct_response_code) { 202 }
    let(:correct_response_body) do
      {
        oauth_url: "http://www.example.com/oauth?token=example"
      }
    end

    subject { client.real_time_scheduling(args) }

    context 'when start/end are Times' do
      it_behaves_like 'a Cronofy request'
    end

  end

  describe "Real time sequencing" do
    let(:request_url) { "https://api.cronofy.com/v1/real_time_sequencing" }
    let(:url) { URI("https://example.com") }
    let(:method) { :post }

    let(:request_headers) do
      {
        "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}",
        "Content-Type" => "application/json; charset=utf-8",
      }
    end

    let(:location) { { :description => "Board room" } }
    let(:transparency) { nil }
    let(:client_id) { 'example_id' }
    let(:client_secret) { 'example_secret' }
    let(:scope) { 'read_events delete_events' }
    let(:state) { 'example_state' }
    let(:redirect_uri) { 'http://example.com/redirect' }

    let(:client) do
      Cronofy::Client.new(
        client_id: client_id,
        client_secret: client_secret,
      )
    end

    let(:event) do
      {
        :event_id => "qTtZdczOccgaPncGJaCiLg",
        :summary => "Board meeting",
        :description => "Discuss plans for the next quarter.",
        :url => url,
        :location => location,
        :transparency => transparency,
        :reminders => [
          { :minutes => 60 },
          { :minutes => 0 },
          { :minutes => 10 },
        ],
      }
    end

    let(:oauth_body) do
      {
        scope: scope,
        redirect_uri: redirect_uri,
        state: state,
      }
    end

    let(:target_calendars) do
      [
        {
          sub: "acc_567236000909002",
          calendar_id: "cal_n23kjnwrw2_jsdfjksn234",
        }
      ]
    end

    let(:availability) do
      {
        sequence: [
          {
            participants: [
              {
                members: [{
                  sub: "acc_567236000909002",
                  calendar_ids: ["cal_n23kjnwrw2_jsdfjksn234"]
                }],
                required: 'all'
              }
            ],
            required_duration: { minutes: 60 },
            start_interval: { minutes: 60 },
            available_periods: [{
              start: Time.utc(2017, 1, 1, 9, 00),
              end:   Time.utc(2017, 1, 1, 17, 00),
            }],
            event: event,
            buffer: {
              before: {
                minimum: { minutes: 30 },
                maximum: { minutes: 30 },
              },
              after: {
                minimum: { minutes: 30 },
                maximum: { minutes: 30 },
              }
            }
          }
        ],
        available_periods: [{
          start: Time.utc(2017, 1, 1, 9, 00),
          end:   Time.utc(2017, 1, 1, 17, 00),
        }],
      }
    end

    let(:mapped_availability) do
      {
        sequence: [
          {
            participants: [
              {
                members: [{
                  sub: "acc_567236000909002",
                  calendar_ids: ["cal_n23kjnwrw2_jsdfjksn234"]
                }],
                required: 'all'
              }
            ],
            required_duration: { minutes: 60 },
            start_interval: { minutes: 60 },
            available_periods: [{
              start: "2017-01-01T09:00:00Z",
              end:   "2017-01-01T17:00:00Z",
            }],
            event: mapped_event,
            buffer: {
              before: {
                minimum: { minutes: 30 },
                maximum: { minutes: 30 },
              },
              after: {
                minimum: { minutes: 30 },
                maximum: { minutes: 30 },
              }
            }
          }
        ],
        available_periods: [{
          start: "2017-01-01T09:00:00Z",
          end:   "2017-01-01T17:00:00Z",
        }]
      }
    end

    let(:mapped_event) do
      {
        :event_id => "qTtZdczOccgaPncGJaCiLg",
        :summary => "Board meeting",
        :description => "Discuss plans for the next quarter.",
        :url => url.to_s,
        :location => location,
        :transparency => transparency,
        :reminders => [
          { :minutes => 60 },
          { :minutes => 0 },
          { :minutes => 10 },
        ],
      }
    end

    let(:args) do
      {
        oauth: oauth_body,
        event: event,
        target_calendars: target_calendars,
        availability: availability,
      }
    end

    let(:request_body) do
      {
        client_id: client_id,
        client_secret: client_secret,
        oauth: oauth_body,
        event: mapped_event,
        target_calendars: target_calendars,
        availability: mapped_availability,
      }
    end
    let(:correct_response_code) { 202 }
    let(:correct_response_body) do
      {
        oauth_url: "http://www.example.com/oauth?token=example"
      }
    end

    subject { client.real_time_sequencing(args) }

    context 'when start/end are Times' do
      it_behaves_like 'a Cronofy request'
    end

  end

  describe "specifying data_centre" do
    let(:data_center) { :de }

    let(:client) do
      Cronofy::Client.new(
        client_id: 'client_id_123',
        client_secret: 'client_secret_456',
        access_token: token,
        refresh_token: 'refresh_token_456',
        data_centre: data_center,
      )
    end

    describe "Userinfo" do
      let(:request_url) { "https://api-#{data_center}.cronofy.com/v1/userinfo" }

      describe "#userinfo" do
        let(:method) { :get }

        let(:correct_response_code) { 200 }
        let(:correct_response_body) do
          {
            "sub" => "ser_5700a00eb0ccd07000000000",
            "cronofy.type" => "service_account",
            "cronofy.service_account.domain" => "example.com"
          }
        end

        let(:correct_mapped_result) do
          Cronofy::UserInfo.new(correct_response_body)
        end

        subject { client.userinfo }

        it_behaves_like "a Cronofy request"
        it_behaves_like "a Cronofy request with mapped return value"
      end
    end
  end

  describe "specifying data_center" do
    let(:data_center) { :au }

    let(:client) do
      Cronofy::Client.new(
        client_id: 'client_id_123',
        client_secret: 'client_secret_456',
        access_token: token,
        refresh_token: 'refresh_token_456',
        data_center: data_center,
      )
    end

    describe "Userinfo" do
      let(:request_url) { "https://api-#{data_center}.cronofy.com/v1/userinfo" }

      describe "#userinfo" do
        let(:method) { :get }

        let(:correct_response_code) { 200 }
        let(:correct_response_body) do
          {
            "sub" => "ser_5700a00eb0ccd07000000000",
            "cronofy.type" => "service_account",
            "cronofy.service_account.domain" => "example.com"
          }
        end

        let(:correct_mapped_result) do
          Cronofy::UserInfo.new(correct_response_body)
        end

        subject { client.userinfo }

        it_behaves_like "a Cronofy request"
        it_behaves_like "a Cronofy request with mapped return value"
      end
    end
  end

  describe "HMAC verification" do
    let(:client) do
      Cronofy::Client.new(
        client_secret: 'pDY0Oi7TJSP2hfNmZNkm5',
        access_token: token,
        refresh_token: 'refresh_token_456',
      )
    end

    let(:body) { "{\"example\":\"well-known\"}" }

    it "verifies the correct HMAC" do
      expect(client.hmac_valid?(body: body, hmac: "6r2/HjBkqymGegX0wOfifieeUXbbHwtV/LohHS+jv6c=")).to be true
    end

    it "rejects an incorrect HMAC" do
      expect(client.hmac_valid?(body: body, hmac: "something-else")).to be false
    end

    it "verifies the correct HMAC when one of the multiple HMACs splitted by ',' match" do
      expect(client.hmac_valid?(body: body, hmac: "6r2/HjBkqymGegX0wOfifieeUXbbHwtV/LohHS+jv6c=,something-else")).to be true
    end

    it "rejects incorrect when multiple HMACs splitted by ',' don't match" do
      expect(client.hmac_valid?(body: body, hmac: "something-else,something-else2")).to be false
    end

    it "rejects if empty HMAC" do
      expect(client.hmac_valid?(body: body, hmac: "")).to be false
    end

    it "rejects if nil HMAC" do
      expect(client.hmac_valid?(body: body, hmac: nil)).to be false
    end
  end

  describe "Smart Invite" do
    let(:request_url) { "https://api.cronofy.com/v1/smart_invites" }
    let(:url) { URI("https://example.com") }
    let(:method) { :post }

    let(:request_headers) do
      {
        "Authorization" => "Bearer #{client_secret}",
        "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}",
        "Content-Type" => "application/json; charset=utf-8",
      }
    end

    let(:location) { { :description => "Board room" } }
    let(:client_id) { 'example_id' }
    let(:client_secret) { 'example_secret' }

    let(:client) do
      Cronofy::Client.new(
        client_id: client_id,
        client_secret: client_secret,
      )
    end

    let(:start_datetime) { Time.utc(2014, 8, 5, 15, 30, 0) }
    let(:end_datetime) { Time.utc(2014, 8, 5, 17, 0, 0) }
    let(:encoded_start_datetime) { "2014-08-05T15:30:00Z" }
    let(:encoded_end_datetime) { "2014-08-05T17:00:00Z" }

    let(:args) do
      {
        smart_invite_id: "qTtZdczOccgaPncGJaCiLg",
        callback_url: url.to_s,
        event: {
          :summary => "Board meeting",
          :description => "Discuss plans for the next quarter.",
          :url => url.to_s,
          :start => start_datetime,
          :end => encoded_end_datetime,
          :location => location,
          :reminders => [
            { :minutes => 60 },
            { :minutes => 0 },
            { :minutes => 10 },
          ],
        },
        recipient: {
          email: "example@example.com"
        }
      }
    end

    let(:request_body) do
      {
        smart_invite_id: "qTtZdczOccgaPncGJaCiLg",
        callback_url: url.to_s,
        event: {
          :summary => "Board meeting",
          :description => "Discuss plans for the next quarter.",
          :url => url.to_s,
          :start => encoded_start_datetime,
          :end => encoded_end_datetime,
          :location => location,
          :reminders => [
            { :minutes => 60 },
            { :minutes => 0 },
            { :minutes => 10 },
          ],
        },
        recipient: {
          email: "example@example.com"
        }
      }
    end
    let(:correct_response_code) { 202 }
    let(:correct_response_body) do
      request_body.merge({
        attachments: []
      })
    end

    subject { client.upsert_smart_invite(request_body) }

    it_behaves_like 'a Cronofy request'

  end

  describe 'Read smart invite' do
    before do
      stub_request(method, request_url)
        .with(headers: request_headers)
        .to_return(status: correct_response_code,
                   headers: correct_response_headers,
                   body: correct_response_body.to_json)
    end

    let(:request_headers) do
      {
        "Authorization" => "Bearer #{client_secret}",
        "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}",
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      }
    end

    let(:client_id) { 'example_id' }
    let(:client_secret) { 'example_secret' }

    let(:client) do
      Cronofy::Client.new(
        client_id: client_id,
        client_secret: client_secret,
      )
    end

    let(:request_url_prefix) { 'https://api.cronofy.com/v1/smart_invites' }
    let(:method) { :get }
    let(:correct_response_code) { 200 }
    let(:smart_invite_id) { "smart_invite_id_1234" }
    let(:recipient_email) { "example@example.com" }
    let(:request_url) { request_url_prefix + "?recipient_email=#{recipient_email}&smart_invite_id=#{smart_invite_id}" }

    let(:correct_response_body) do
      {
        "recipient" => {
          "email" => recipient_email,
          "status" => "declined",
          "comment" => "example comment",
          "proposal" => {
            "start" => {
              "time" => "2014-09-13T23:00:00+02:00",
              "tzid" => "Europe/Paris"
            },
            "end" => {
              "time" => "2014-09-13T23:00:00+02:00",
              "tzid" => "Europe/Paris"
            }
          }
        },
        "replies" => [
          {
            "email" => "person1@example.com",
            "status" => "accepted"
          },
          {
            "email" => "person2@example.com",
            "status" => "declined",
            "comment" => "example comment",
            "proposal" => {
              "start" => {
                "time" => "2014-09-13T23:00:00+02:00",
                "tzid" => "Europe/Paris"
              },
              "end" => {
                "time" => "2014-09-13T23:00:00+02:00",
                "tzid" => "Europe/Paris"
              }
            }
          }
        ],
        "smart_invite_id" => smart_invite_id,
        "callback_url" => "https =>//example.yourapp.com/cronofy/smart_invite/notifications",
        "event" => {
          "summary" => "Board meeting",
          "description" => "Discuss plans for the next quarter.",
          "start" => {
            "time" => "2017-10-05T09:30:00Z",
            "tzid" => "Europe/London"
          },
          "end" => {
            "time" => "2017-10-05T10:00:00Z",
            "tzid" => "Europe/London"
          },
          "location" => {
            "description" => "Board room"
          }
        }
      }
    end

    let(:correct_mapped_result) do
      Cronofy::SmartInviteResponse.new(correct_response_body)
    end

    subject do
      client.get_smart_invite(smart_invite_id, recipient_email)
    end

    it_behaves_like 'a Cronofy request'
    it_behaves_like 'a Cronofy request with mapped return value'
  end

  describe "Cancel Smart Invite" do
    let(:request_url) { "https://api.cronofy.com/v1/smart_invites" }
    let(:method) { :post }

    let(:request_headers) do
      {
        "Authorization" => "Bearer #{client_secret}",
        "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}",
        "Content-Type" => "application/json; charset=utf-8",
      }
    end

    let(:client_id) { 'example_id' }
    let(:client_secret) { 'example_secret' }

    let(:client) do
      Cronofy::Client.new(
        client_id: client_id,
        client_secret: client_secret,
      )
    end

    let(:args) do
      {
        smart_invite_id: "qTtZdczOccgaPncGJaCiLg",
        recipient: {
          email: "example@example.com"
        }
      }
    end

    let(:request_body) do
      {
        method: 'cancel',
        smart_invite_id: "qTtZdczOccgaPncGJaCiLg",
        recipient: {
          email: "example@example.com"
        }
      }
    end
    let(:correct_response_code) { 202 }
    let(:correct_response_body) do
      request_body.merge({
        attachments: []
      })
    end

    subject { client.cancel_smart_invite(request_body) }

    it_behaves_like 'a Cronofy request'

  end

  describe "Remove Recipient Smart Invite", test: true do
    let(:request_url) { "https://api.cronofy.com/v1/smart_invites" }
    let(:method) { :post }

    let(:request_headers) do
      {
        "Authorization" => "Bearer #{client_secret}",
        "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}",
        "Content-Type" => "application/json; charset=utf-8",
      }
    end

    let(:client_id) { 'example_id' }
    let(:client_secret) { 'example_secret' }

    let(:client) do
      Cronofy::Client.new(
        client_id: client_id,
        client_secret: client_secret,
      )
    end

    let(:args) do
      {
        smart_invite_id: "qTtZdczOccgaPncGJaCiLg",
        recipient: {
          email: "example@example.com"
        }
      }
    end

    let(:request_body) do
      {
        method: 'remove',
        smart_invite_id: "qTtZdczOccgaPncGJaCiLg",
        recipient: {
          email: "example@example.com"
        }
      }
    end
    let(:correct_response_code) { 202 }
    let(:correct_response_body) do
      request_body.merge({
        attachments: {
          removed: {
            email: "example@example.com"
          }
        }
      })
    end

    let(:correct_mapped_result) do
      Cronofy::SmartInviteResponse.new(correct_response_body)
    end

    subject { client.remove_recipient_smart_invite(request_body) }

    it_behaves_like 'a Cronofy request'
    it_behaves_like 'a Cronofy request with mapped return value'
  end

  describe "Batch requests" do
    context "upserting an event" do
      let(:calendar_id) { 'calendar_id_123'}
      let(:request_url) { "https://api.cronofy.com/v1/batch" }
      let(:url) { URI("https://example.com") }
      let(:method) { :post }
      let(:request_headers) { json_request_headers }

      let(:start_datetime) { Time.utc(2014, 8, 5, 15, 30, 0) }
      let(:end_datetime) { Time.utc(2014, 8, 5, 17, 0, 0) }
      let(:encoded_start_datetime) { "2014-08-05T15:30:00Z" }
      let(:encoded_end_datetime) { "2014-08-05T17:00:00Z" }
      let(:location) { { :description => "Board room" } }

      let(:event) do
        {
          :event_id => "qTtZdczOccgaPncGJaCiLg",
          :summary => "Board meeting",
          :description => "Discuss plans for the next quarter.",
          :start => start_datetime,
          :end => end_datetime,
          :url => url,
          :location => location,
          :reminders => [
            { :minutes => 60 },
            { :minutes => 0 },
            { :minutes => 10 },
          ],
        }
      end

      let(:request_body) do
        {
          :batch => [
            {
              :method => "POST",
              :relative_url => "/v1/calendars/#{calendar_id}/events",
              :data => {
                :event_id => "qTtZdczOccgaPncGJaCiLg",
                :summary => "Board meeting",
                :description => "Discuss plans for the next quarter.",
                :start => encoded_start_datetime,
                :end => encoded_end_datetime,
                :url => url.to_s,
                :location => location,
                :reminders => [
                  { :minutes => 60 },
                  { :minutes => 0 },
                  { :minutes => 10 },
                ],
              }
            }
          ]
        }
      end

      let(:correct_response_code) { 207 }
      let(:correct_response_body) do
        {
          "batch" => [
            { "status" => 202 }
          ]
        }
      end

      subject do
        client.batch do |batch|
          batch.upsert_event(calendar_id, event)
        end
      end

      it_behaves_like "a Cronofy request"
    end

    context "deleting an event" do
      let(:calendar_id) { 'calendar_id_123'}
      let(:method) { :post }
      let(:request_url) { "https://api.cronofy.com/v1/batch" }
      let(:request_headers) { json_request_headers }

      let(:event_id) { "asd1knkjsndk123123" }

      let(:request_body) do
        {
          :batch => [
            {
              :method => "DELETE",
              :relative_url => "/v1/calendars/#{calendar_id}/events",
              :data => {
                :event_id => event_id,
              }
            }
          ]
        }
      end

      let(:correct_response_code) { 207 }
      let(:correct_response_body) do
        {
          "batch" => [
            { "status" => 202 }
          ]
        }
      end

      subject do
        client.batch do |batch|
          batch.delete_event(calendar_id, event_id)
        end
      end

      it_behaves_like "a Cronofy request"
    end

    context "deleting an external event" do
      let(:calendar_id) { 'calendar_id_123'}
      let(:method) { :post }
      let(:request_url) { "https://api.cronofy.com/v1/batch" }
      let(:request_headers) { json_request_headers }

      let(:event_uid) { "evt_external_12345abcde" }

      let(:request_body) do
        {
          :batch => [
            {
              :method => "DELETE",
              :relative_url => "/v1/calendars/#{calendar_id}/events",
              :data => {
                :event_uid => event_uid,
              }
            }
          ]
        }
      end

      let(:correct_response_code) { 207 }
      let(:correct_response_body) do
        {
          "batch" => [
            { "status" => 202 }
          ]
        }
      end

      subject do
        client.batch do |batch|
          batch.delete_external_event(calendar_id, event_uid)
        end
      end

      it_behaves_like "a Cronofy request"
    end

    context "partial success" do
      let(:method) { :post }
      let(:request_url) { "https://api.cronofy.com/v1/batch" }
      let(:request_headers) { json_request_headers }

      let(:request_body) do
        {
          :batch => [
            {
              :method => "DELETE",
              :relative_url => "/v1/calendars/cal_123_abc/events",
              :data => {
                :event_id => "123",
              }
            },
            {
              :method => "DELETE",
              :relative_url => "/v1/calendars/cal_123_def/events",
              :data => {
                :event_id => "456",
              }
            }
          ]
        }
      end

      let(:correct_response_code) { 207 }
      let(:correct_response_body) do
        {
          "batch" => [
            { "status" => 202 },
            { "status" => 404 },
          ]
        }
      end

      subject do
        client.batch do |batch|
          batch.delete_event("cal_123_abc", "123")
          batch.delete_event("cal_123_def", "456")
        end
      end

      it "raises an error" do
        stub_request(method, request_url)
          .with(headers: request_headers,
                body: request_body)
          .to_return(status: correct_response_code,
                     headers: correct_response_headers,
                     body: correct_response_body.to_json)

        expect { subject }.to raise_error(Cronofy::BatchResponse::PartialSuccessError) do |error|
          expect(error.batch_response.errors?).to be true
        end
      end
    end
  end

  describe '#create_scheduling_conversation' do
    let(:request_url) { 'https://api.cronofy.com/v1/scheduling_conversations' }
    let(:method) { :post }
    let(:request_body) do
      {
        "participants" => [
          {
            "participant_id" => "@grace",
            "sub" => "acc_567236000909002",
            "slots" => {
              "choice_method" => "auto"
            }
          },
          {
            "participant_id" => "@karl"
          }
        ],
        "required_duration" => { "minutes" => 60 },
        "available_periods" => [
          {
            "start" => "2018-05-01T00:00:00Z",
            "end" => "2018-05-08T23:59:59Z"
          }
        ]
      }
    end

    let(:correct_response_code) { 200 }
    let(:correct_response_body) do
      {
        "scheduling_conversation" => {
          "scheduling_conversation_id" => "abcd1234"
        }
      }
    end

    let(:correct_mapped_result) do
      Cronofy::SchedulingConversation.new(scheduling_conversation_id: "abcd1234")
    end

    subject { client.create_scheduling_conversation(request_body) }

    it_behaves_like 'a Cronofy request'
    it_behaves_like 'a Cronofy request with mapped return value'
  end

  describe '#lookup_scheduling_conversation' do
    let(:token) { "hagsdau7g3d" }
    let(:request_url) { "https://api.cronofy.com/v1/scheduling_conversations?token=#{token}" }
    let(:method) { :get }

    let(:correct_response_code) { 200 }
    let(:correct_response_body) do
      {
        "participant" => {
          "participant_id" => "83o38hoa"
        },
        "scheduling_conversation" => {
          "scheduling_conversation_id" => "abcd1234"
        },
      }
    end

    let(:correct_mapped_result) do
      Cronofy::SchedulingConversationResponse.new(
        participant: Cronofy::Participant.new(participant_id: "83o38hoa"),
        scheduling_conversation: Cronofy::SchedulingConversation.new(scheduling_conversation_id: "abcd1234"),
        )
    end

    subject { client.lookup_scheduling_conversation(token) }

    it_behaves_like 'a Cronofy request'
    it_behaves_like 'a Cronofy request with mapped return value'
  end

  describe '#upsert_availability_rule' do
    let(:request_url) { 'https://api.cronofy.com/v1/availability_rules' }
    let(:method) { :post }
    let(:request_body) do
      {
        "availability_rule_id" => "default",
        "tzid" => "America/Chicago",
        "calendar_ids" => [
          "cal_n23kjnwrw2_jsdfjksn234"
        ],
        "weekly_periods" => [
          {
            "day" => "monday",
            "start_time" => "09:30",
            "end_time" => "16:30"
          },
          {
            "day" => "wednesday",
            "start_time" => "09:30",
            "end_time" => "16:30"
          }
        ]
      }
    end

    let(:correct_response_code) { 200 }
    let(:correct_response_body) do
      {
        "availability_rule" => {
          "availability_rule_id" => "default",
          "tzid" => "America/Chicago",
          "calendar_ids" => [
            "cal_n23kjnwrw2_jsdfjksn234"
          ],
          "weekly_periods" => [
            {
              "day" => "monday",
              "start_time" => "09:30",
              "end_time" => "16:30"
            },
            {
              "day" => "wednesday",
              "start_time" => "09:30",
              "end_time" => "16:30"
            }
          ]
        }
      }
    end

    let(:correct_mapped_result) do
      Cronofy::AvailabilityRule.new(
        availability_rule_id: request_body['availability_rule_id'],
        tzid: request_body['tzid'],
        calendar_ids: request_body['calendar_ids'],
        weekly_periods: request_body['weekly_periods'].map { |wp| Cronofy::WeeklyPeriod.new(wp) },
        )
    end

    subject { client.upsert_availability_rule(request_body) }

    it_behaves_like 'a Cronofy request'
    it_behaves_like 'a Cronofy request with mapped return value'
  end

  describe "#get_availability_rule" do
    let(:availability_rule_id) { 'default'}
    let(:request_url) { "https://api.cronofy.com/v1/availability_rules/#{availability_rule_id}" }
    let(:method) { :get }

    let(:correct_response_code) { 200 }
    let(:correct_response_body) do
      {
        "availability_rule" => {
          "availability_rule_id" => "default",
          "tzid" => "America/Chicago",
          "calendar_ids" => [
            "cal_n23kjnwrw2_jsdfjksn234"
          ],
          "weekly_periods" => [
            {
              "day" => "monday",
              "start_time" => "09:30",
              "end_time" => "16:30"
            },
            {
              "day" => "wednesday",
              "start_time" => "09:30",
              "end_time" => "16:30"
            }
          ]
        }
      }
    end

    let(:correct_mapped_result) do
      rule = correct_response_body['availability_rule']
      Cronofy::AvailabilityRule.new(
        availability_rule_id: rule['availability_rule_id'],
        tzid: rule['tzid'],
        calendar_ids: rule['calendar_ids'],
        weekly_periods: rule['weekly_periods'].map { |wp| Cronofy::WeeklyPeriod.new(wp) },
        )
    end

    subject { client.get_availability_rule(availability_rule_id) }

    it_behaves_like 'a Cronofy request'
    it_behaves_like 'a Cronofy request with mapped return value'
  end

  describe "#get_availability_rules" do
    let(:request_url) { "https://api.cronofy.com/v1/availability_rules" }
    let(:method) { :get }

    let(:correct_response_code) { 200 }
    let(:correct_response_body) do
      {
        "availability_rules" => [
          {
            "availability_rule_id" => "default",
            "tzid" => "America/Chicago",
            "calendar_ids" => [
              "cal_n23kjnwrw2_jsdfjksn234"
            ],
            "weekly_periods" => [
              {
                "day" => "monday",
                "start_time" => "09:30",
                "end_time" => "16:30"
              },
              {
                "day" => "wednesday",
                "start_time" => "09:30",
                "end_time" => "16:30"
              }
            ]
          }
        ]
      }
    end

    let(:correct_mapped_result) do
      rule = correct_response_body['availability_rules'][0]

      [
        Cronofy::AvailabilityRule.new(
          availability_rule_id: rule['availability_rule_id'],
          tzid: rule['tzid'],
          calendar_ids: rule['calendar_ids'],
          weekly_periods: rule['weekly_periods'].map { |wp| Cronofy::WeeklyPeriod.new(wp) },
          )
      ]
    end

    subject { client.get_availability_rules }

    it_behaves_like 'a Cronofy request'
    it_behaves_like 'a Cronofy request with mapped return value'
  end

  describe '#delete_availability_rule' do
    let(:availability_rule_id) { 'default'}
    let(:request_url) { "https://api.cronofy.com/v1/availability_rules/#{availability_rule_id}" }
    let(:method) { :delete }
    let(:request_body) { nil }
    let(:correct_response_code) { 202 }
    let(:correct_response_body) { nil }

    subject { client.delete_availability_rule(availability_rule_id) }

    it_behaves_like 'a Cronofy request'
  end

  describe "#upsert_available_period" do
    let(:request_url) { 'https://api.cronofy.com/v1/available_periods' }
    let(:method) { :post }
    let(:available_period_id) { "test" }
    let(:request_body) do
      {
        available_period_id: available_period_id,
        start: "2020-07-26T15:30:00Z",
        end: "2020-07-26T17:00:00Z"
      }
    end

    let(:correct_response_code) { 202 }
    let(:correct_response_body) { "" }
    let(:correct_mapped_result) { nil }

    subject {
      client.upsert_available_period(available_period_id,
        start: request_body[:start],
        end: request_body[:end]
      )
    }

    it_behaves_like 'a Cronofy request'
    it_behaves_like 'a Cronofy request with mapped return value'
  end

  describe "#get_available_periods" do
    context "unfiltered" do
      let(:request_url) { "https://api.cronofy.com/v1/available_periods" }
      let(:method) { :get }

      let(:correct_response_code) { 200 }
      let(:correct_response_body) do
        {
          "available_periods" => [
            {
              "available_period_id" => "qTtZdczOccgaPncGJaCiLg",
              "start" => "2020-07-26T15:30:00Z",
              "end" => "2020-07-26T17:00:00Z"
            }
          ]
        }
      end

      let(:correct_mapped_result) do
        period = correct_response_body['available_periods'][0]

        [
          Cronofy::AvailablePeriod.new(
            available_period_id: period['available_period_id'],
            start: period['start'],
            end: period['end']
          )
        ]
      end

      subject { client.get_available_periods }

      it_behaves_like 'a Cronofy request'
      it_behaves_like 'a Cronofy request with mapped return value'
    end

    context "filterd by date range" do
      let(:tzid) { "America/New_York" }
      let(:from) { "2020-07-01" }
      let(:to) { "2020-07-31" }
      let(:request_url) { "https://api.cronofy.com/v1/available_periods?from=#{from}&to=#{to}&tzid=#{tzid}" }
      let(:method) { :get }

      let(:correct_response_code) { 200 }
      let(:correct_response_body) do
        {
          "available_periods" => [
            {
              "available_period_id" => "qTtZdczOccgaPncGJaCiLg",
              "start" => "2020-07-26T15:30:00Z",
              "end" => "2020-07-26T17:00:00Z"
            }
          ]
        }
      end

      let(:correct_mapped_result) do
        period = correct_response_body['available_periods'][0]

        [
          Cronofy::AvailablePeriod.new(
            available_period_id: period['available_period_id'],
            start: period['start'],
            end: period['end']
          )
        ]
      end

      subject { client.get_available_periods(from: from, to: to, tzid: tzid) }

      it_behaves_like 'a Cronofy request'
      it_behaves_like 'a Cronofy request with mapped return value'
    end

    context "requesting localized times" do
      let(:tzid) { "America/New_York" }
      let(:localized_times) { true }
      let(:request_url) { "https://api.cronofy.com/v1/available_periods?tzid=#{tzid}&localized_times=true" }
      let(:method) { :get }

      let(:correct_response_code) { 200 }
      let(:correct_response_body) do
        {
          "available_periods" => [
            {
              "available_period_id" => "qTtZdczOccgaPncGJaCiLg",
              "start" => "2020-07-26T15:30:00Z",
              "end" => "2020-07-26T17:00:00Z"
            }
          ]
        }
      end

      let(:correct_mapped_result) do
        period = correct_response_body['available_periods'][0]

        [
          Cronofy::AvailablePeriod.new(
            available_period_id: period['available_period_id'],
            start: period['start'],
            end: period['end']
          )
        ]
      end

      subject { client.get_available_periods(tzid: tzid, localized_times: true) }

      it_behaves_like 'a Cronofy request'
      it_behaves_like 'a Cronofy request with mapped return value'
    end
  end

  describe '#delete_available_period' do
    let(:available_period_id) { 'default'}
    let(:request_url) { "https://api.cronofy.com/v1/available_periods" }
    let(:method) { :delete }
    let(:request_body) {
      { available_period_id: available_period_id}
    }
    let(:correct_response_code) { 202 }
    let(:correct_response_body) { "" }
    let(:correct_mapped_result) { nil }

    subject { client.delete_available_period(available_period_id) }

    it_behaves_like 'a Cronofy request'
    it_behaves_like 'a Cronofy request with mapped return value'
  end
end

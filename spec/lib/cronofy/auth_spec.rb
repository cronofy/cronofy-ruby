require_relative '../../spec_helper'

describe Cronofy::Auth do
  let(:client_id) { 'client_id_123' }
  let(:client_secret) { 'client_secret_456' }

  let(:code) { 'code_789' }
  let(:redirect_uri) { 'http://red.ire.ct/Uri' }
  let(:access_token) { 'access_token_123' }
  let(:refresh_token) { 'refresh_token_456' }

  let(:new_access_token) { "new_access_token_2342" }
  let(:new_refresh_token) { "new_refresh_token_7898" }
  let(:expires_in) { 10000 }
  let(:scope) { 'read_events list_calendars create_event' }

  before(:all) do
    WebMock.reset!
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  let(:response_status) { 200 }

  before(:each) do
    stub_request(:post, "https://api.cronofy.com/oauth/token")
      .with(
        body: {
          client_id: client_id,
          client_secret: client_secret,
          grant_type: "refresh_token",
          refresh_token: refresh_token,
        },
        headers: {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => "Cronofy Ruby #{Cronofy::VERSION}",
        }
      )
      .to_return(
        status: response_status,
        body: {
          access_token: new_access_token,
          token_type: 'bearer',
          expires_in: expires_in,
          refresh_token: new_refresh_token,
          scope: scope,
        }.to_json,
        headers: {
          "Content-Type" => "application/json; charset=utf-8"
        }
      )

    stub_request(:post, "https://app.cronofy.com/oauth/token")
      .with(
        body: {
          client_id: client_id,
          client_secret: client_secret,
          code: code,
          grant_type: "authorization_code",
          redirect_uri: redirect_uri,
        },
        headers: {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => "Cronofy Ruby #{Cronofy::VERSION}",
        }
      )
      .to_return(
        status: response_status,
        body: {
          access_token: new_access_token,
          token_type: 'bearer',
          expires_in: expires_in,
          refresh_token: new_refresh_token,
          scope: scope,
        }.to_json,
        headers: {
          "Content-Type" => "application/json; charset=utf-8"
        }
      )
  end

  describe '#user_auth_link' do
    let(:scope_array) { %w{read_events list_calendars create_event} }
    let(:scheme) { 'https' }
    let(:host) { 'app.cronofy.com' }
    let(:path) { '/oauth/authorize' }
    let(:default_params) do
      {
        'client_id' => client_id,
        'redirect_uri' => redirect_uri,
        'response_type' => 'code',
        'scope' => scope
      }
    end
    
    subject do
      url = Cronofy::Auth.new(client_id, client_secret).user_auth_link(redirect_uri,
                                                                       scope_array,
                                                                       state)
      URI.parse(url)
    end

    shared_examples 'a user auth link provider' do
      it 'contains the correct scheme' do
        expect(subject.scheme).to eq scheme
      end

      it 'contains the correct host' do
        expect(subject.host).to eq host
      end

      it 'contains the correct path' do
        expect(subject.path).to eq path
      end

      it 'contains the correct query params' do
        expect(Rack::Utils.parse_query(subject.query)).to eq params
      end
    end
    
    context 'when no state' do
      let(:state) { nil }
      let(:params) { default_params }

      it_behaves_like 'a user auth link provider'
    end

    context 'when state is passed' do
      let(:state) { SecureRandom.hex }
      let(:params) do
        default_params['state'] = state
        default_params
      end

      it_behaves_like 'a user auth link provider'      
    end
  end

  shared_examples 'an authorization request' do
    context 'when succeeds' do
      it 'returns a correct Credentials object' do
        expect(subject.access_token).to eq new_access_token
        expect(subject.expires_in).to eq expires_in
        expect(subject.refresh_token).to eq new_refresh_token
        expect(subject.scope).to eq scope
      end
    end

    context 'when fails' do
      context 'with 400' do
        let(:response_status) { 400 }

        it 'throws BadRequestError' do
          expect{ subject }.to raise_error(Cronofy::BadRequestError)
        end
      end

      context 'with unrecognized code' do
        let(:response_status) { 418 }

        it 'throws Unknown error' do
          expect{ subject }.to raise_error(Cronofy::UnknownError)
        end
      end
    end
  end

  describe '#get_token_from_code' do
    subject { Cronofy::Auth.new(client_id, client_secret).get_token_from_code(code, redirect_uri) }

    it_behaves_like 'an authorization request'
  end

  describe '#refresh!' do
    subject do
      Cronofy::Auth.new(client_id, client_secret, access_token, refresh_token).refresh!
    end

    it_behaves_like 'an authorization request'
  end

  describe "#revoke!" do
    let(:auth) do
      Cronofy::Auth.new(client_id, client_secret, access_token, refresh_token)
    end

    let!(:revocation_request) do
      stub_request(:post, "https://api.cronofy.com/oauth/token/revoke")
        .with(
          body: {
            client_id: client_id,
            client_secret: client_secret,
            token: refresh_token,
          },
          headers: {
            'Content-Type' => 'application/x-www-form-urlencoded',
            'User-Agent' => "Cronofy Ruby #{Cronofy::VERSION}",
          }
        )
        .to_return(
          status: response_status,
        )
    end

    before do
      auth.revoke!
    end

    it "unsets the access token" do
      expect(auth.access_token).to be_nil
    end

    it "makes the revocation request" do
      expect(revocation_request).to have_been_requested
    end
  end
end

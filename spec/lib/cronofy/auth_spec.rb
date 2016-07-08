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

  let(:linking_profile_hash) { nil }
  let(:account_id) { nil }

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
          account_id: account_id,
          linking_profile: linking_profile_hash,
        }.to_json,
        headers: {
          "Content-Type" => "application/json; charset=utf-8"
        }
      )
  end

  describe '#user_auth_link' do
    let(:input_scope) { %w{read_events list_calendars create_event} }
    let(:state) { nil }
    let(:scheme) { 'https' }
    let(:host) { 'app.cronofy.com' }
    let(:path) { '/oauth/authorize' }
    let(:default_params) do
      {
        'client_id' => client_id,
        'redirect_uri' => redirect_uri,
        'response_type' => 'code',
        'scope' => scope,
      }
    end

    let(:auth) do
      Cronofy::Auth.new(client_id, client_secret)
    end

    subject do
      url = auth.user_auth_link(redirect_uri, scope: input_scope, state: state)
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
        default_params.merge('state' => state)
      end

      it_behaves_like 'a user auth link provider'
    end

    context 'when scope is a string' do
      let(:input_scope) { scope }
      let(:params) { default_params }

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

      context "client_id and client_secret not set" do
        let(:client_id) { " " }
        let(:client_secret) { " " }

        it "throws a credentials missing error" do
          expect { subject }.to raise_error(Cronofy::CredentialsMissingError, "OAuth client_id and client_secret must be set")
        end
      end
    end
  end

  describe '#get_token_from_code' do
    subject { Cronofy::Auth.new(client_id, client_secret).get_token_from_code(code, redirect_uri) }

    context "with account_id" do
      let(:account_id) { "acc_0123456789abc" }

      it 'exposes the account_id' do
        expect(subject.account_id).to eq account_id
      end

      it "includes the account_id in its hash" do
        expected = {
          :access_token => subject.access_token,
          :expires_at => subject.expires_at,
          :expires_in => subject.expires_in,
          :refresh_token => subject.refresh_token,
          :scope => subject.scope,
          :account_id => account_id,
        }

        expect(subject.to_h).to eq(expected)
      end
    end

    context "with linking profile" do
      let(:linking_profile_hash) do
        {
          provider_name: "google",
          profile_id: "pro_VmrZnDitjScsAAAG",
          profile_name: "bob@example.com",
        }
      end

      it "exposes the linking profile" do
        expected = Cronofy::Credentials::LinkingProfile.new(linking_profile_hash)
        expect(subject.linking_profile).to eq expected
      end

      it "includes the linking profile in its hash" do
        expected = {
          :access_token => subject.access_token,
          :expires_at => subject.expires_at,
          :expires_in => subject.expires_in,
          :refresh_token => subject.refresh_token,
          :scope => subject.scope,
          :linking_profile => linking_profile_hash,
        }

        expect(subject.to_h).to eq(expected)
      end
    end

    it_behaves_like 'an authorization request'
  end

  describe '#refresh!' do
    context "access_token and refresh_token present" do
      subject do
        Cronofy::Auth.new(client_id, client_secret, access_token, refresh_token).refresh!
      end

      it_behaves_like 'an authorization request'
    end

    context "no refresh_token" do
      subject do
        Cronofy::Auth.new(client_id, client_secret, access_token, nil).refresh!
      end

      it "raises a credentials missing error" do
        expect { subject }.to raise_error(Cronofy::CredentialsMissingError)
      end
    end

    context "no access_token or refresh_token" do
      subject do
        Cronofy::Auth.new(client_id, client_secret, nil, nil).refresh!
      end

      it "raises a credentials missing error" do
        expect { subject }.to raise_error(Cronofy::CredentialsMissingError)
      end
    end
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

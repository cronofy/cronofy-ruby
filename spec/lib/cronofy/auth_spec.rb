
require_relative '../../spec_helper'

describe Cronofy::Auth do
  let(:client_id) { 'client_id_123' }
  let(:client_secret) { 'client_secret_456' }
  
  before(:all) do
    WebMock.reset!
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  shared_examples 'an authorization request' do
    context 'when succeeds' do
      let(:access_token) { 'access_token_123' }
      let(:refresh_token) { 'refresh_token_456' }
      let(:expires_in) { 10000 }
      let(:scope) { 'read_events list_calendars create_event' }
      let(:oauth_token) do
        OAuth2::AccessToken.new(nil, access_token, {
                                  'expires_in' => expires_in,
                                  'refresh_token' => refresh_token,
                                  'scope' => scope
                                })
      end
      
      before(:each) do
        allow_any_instance_of(OAuth2::Client)
          .to receive(:get_token).and_return(oauth_token)
        end

      it 'returns a correct Credentials object' do
        expect(subject.access_token).to eq access_token
        expect(subject.expires_in).to eq expires_in
        expect(subject.refresh_token).to eq refresh_token
        expect(subject.scope).to eq scope
      end
    end
    
    context 'when fails' do
      let(:oauth_error) do
        OAuth2::Error.new(response)
      end
      
      before(:each) do
        allow_any_instance_of(OAuth2::Client)
          .to receive(:get_token).and_raise(oauth_error)
      end 
      
      context 'with 400' do
        let(:response) do
          double('response',
                 :status => 400,
                 :headers => {
                   'status' => 'Bad request'
                 }).as_null_object
        end
        
        it 'throws AuthorizationFailureError' do
          expect{ subject }.to raise_error(Cronofy::AuthorizationFailureError)
        end
      end

      context 'with code other than 400' do
        let(:response) do
          double('response',
                 :status => 401,
                 :headers => {
                   'status' => 'Unauthorized'
                 }).as_null_object
        end
        
        it 'throws Unknown error' do
          expect{ subject }.to raise_error(Cronofy::UnknownError)
        end
      end
    end
  end

  describe '#get_token_from_code' do
    let(:code) { 'code_789' }
    let(:redirect_uri) { 'http://red.ire.ct/Uri' }
    
    subject { Cronofy::Auth.new(client_id, client_secret).get_token_from_code(code, redirect_uri) }
    
    it_behaves_like 'an authorization request'
  end

  describe '#refresh!' do
    let(:access_token) { 'access_token_123' }
    let(:refresh_token) { 'refresh_token_456' }
    
    subject do
      Cronofy::Auth.new(client_id, client_secret, access_token, refresh_token)
        .refresh!
    end
    
    it_behaves_like 'an authorization request'
  end

end

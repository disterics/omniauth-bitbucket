require 'spec_helper'

describe OmniAuth::Strategies::Bitbucket2 do
  let(:access_token) { double('AccessToken', :options => {}) }
  let(:parsed_response) { double('ParsedResponse') }
  let(:response) { double('Response', :parsed => parsed_response) }

  subject do
    OmniAuth::Strategies::Bitbucket2.new({})
  end

  before(:each) do
    subject.stub!(:access_token).and_return(access_token)
  end

  context "client options" do
    it 'should have correct site' do
      subject.options.client_options.site.should eq("https://api.bitbucket.org/2.0")
    end

    it 'should have correct authorize url' do
      subject.options.client_options.authorize_url.should eq('https://bitbucket.org/site/oauth2/authorize')
    end

    it 'should have correct token url' do
      subject.options.client_options.token_url.should eq('https://bitbucket.org/site/oauth2/access_token')
    end

    it 'should have the correct callback path' do
      expect(subject.callback_path).to eq('/auth/bitbucket/callback')
    end
  end
end

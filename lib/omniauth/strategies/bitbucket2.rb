require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Bitbucket2 < OmniAuth::Strategies::OAuth2
      DEFAULT_RESPONSE_TYPE = 'token'
      DEFAULT_GRANT = 'authorization_code'

      option :name, 'bitbucket'

      option :client_options, {
        :site => 'https://bitbucket.org',
        :authorize_url => 'https://bitbucket.org/site/oauth2/authorize',
        :token_url => 'https://bitbucket.org/site/oauth2/access_token'
      }

      def request_phase
        super
      end

      def authorize_params
        super.tap do |params|
          params[:response_type] ||= DEFAULT_RESPONSE_TYPE
          params[:client_id] = client.id
        end
      end

      def token_params
        super.tap do |params|
          params[:grant_type] ||= DEFAULT_GRANT
          params[:client_id] = client.id
          params[:client_secret] = client.secret
        end
      end

      uid { raw_info['uuid'].to_s }

      info do
        {
          'nickname' => raw_info['username'],
          'email' => primary_email,
          'name' => raw_info['display_name'],
          'image' => raw_info['links']['avatar']['href'],
        }
      end

      extra do
        {:raw_info => raw_info, :all_emails => emails}
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('user').parsed
      end

      def primary_email
        primary = emails.find{ |i| i['is_primary'] && i['is_confirmed'] }
        primary && primary['email'] || nil
      end

      def emails
        access_token.options[:mode] = :query
        email_response = access_token.get('user/emails').parsed
        @emails ||= email_response && email_response['values'] || nil
      end
    end
  end
end

OmniAuth.config.add_camelization 'bitbucket', 'Bitbucket2'

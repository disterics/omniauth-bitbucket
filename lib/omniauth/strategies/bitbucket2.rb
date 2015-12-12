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
          'name' => raw_info['display_name'],
        }
      end

      extra do
        {:raw_info => raw_info}
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('user').parsed
      end
    end
  end
end

OmniAuth.config.add_camelization 'bitbucket', 'Bitbucket2'

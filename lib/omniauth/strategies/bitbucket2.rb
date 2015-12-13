require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Bitbucket2 < OmniAuth::Strategies::OAuth2
      option :name, 'bitbucket'

      option :client_options, {
        :site => 'https://api.bitbucket.org/2.0',
        :authorize_url => 'https://bitbucket.org/site/oauth2/authorize',
        :token_url => 'https://bitbucket.org/site/oauth2/access_token'
      }

      def authorize_params
        super.tap do |params|
          %w[client_options].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end
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
        @raw_info ||= access_token.get('user').parsed
      end

      def primary_email
        primary = emails.find{ |i| i['is_primary'] && i['is_confirmed'] }
        primary && primary['email'] || nil
      end

      def emails
        email_response = access_token.get('user/emails').parsed
        @emails ||= email_response && email_response['values'] || nil
      end
    end
  end
end

OmniAuth.config.add_camelization 'bitbucket', 'Bitbucket2'

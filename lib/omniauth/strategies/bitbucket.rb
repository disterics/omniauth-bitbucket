require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Bitbucket < OmniAuth::Strategies::OAuth2
      option :name, 'bitbucket'

      option :client_options, {
        :site => 'https://api.bitbucket.org/2.0',
        :authorize_url => 'https://bitbucket.org/site/oauth2/authorize',
        :token_url => 'https://bitbucket.org/site/oauth2/access_token'
      }

      def request_phase
        super
      end

      def authorize_params
        super.tap do |params|
          %w[client_options].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end
        end
      end

      # Override callback URL for compatibility with omniauth-oauth2 >= 1.4,
      #   which by default passes the entire URL of the callback, including
      #   query parameters. Bitbucket fails validation because that doesn't match the
      #   registered callback as required in the Oauth 2.0 spec.
      # Refs:
      # https://tools.ietf.org/html/rfc6749#section-4.1.3
      # https://github.com/omniauth/omniauth-oauth2/commit/26152673224aca5c3e918bcc83075dbb0659717f
      # https://github.com/omniauth/omniauth-oauth2/pull/70
      def callback_url
        full_host + script_name + callback_path
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

OmniAuth.config.add_camelization 'bitbucket', 'Bitbucket'

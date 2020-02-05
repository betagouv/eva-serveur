# frozen_string_literal: true

module Admin
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def github
      unless fait_partie_de_equipe_github?
        return github_erreur('Vous ne faites pas partie de la bonne équipe dans GitHub')
      end

      compte = Compte.from_omniauth(auth)

      if compte.persisted?
        sign_in_and_redirect compte
      else
        github_erreur(compte.errors.full_messages.to_sentence)
      end
    end

    private

    def github_erreur(erreur)
      flash.notice = erreur
      redirect_to new_compte_session_path
    end

    def auth
      request.env['omniauth.auth']
    end

    def fait_partie_de_equipe_github?
      response = access_token.get(github_equipe_url)
      response.status == 200 && response.parsed['state'] == 'active'
    end

    def github_equipe_url
      "/orgs/#{ENV['GITHUB_ORG']}/teams/#{ENV['GITHUB_TEAM']}/memberships/#{auth.info.nickname}"
    end

    def github_oauth_client
      OAuth2::Client.new(ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], site: 'https://api.github.com')
    end

    def access_token
      OAuth2::AccessToken.from_hash(github_oauth_client,
                                    access_token: auth.credentials.token)
    end
  end
end

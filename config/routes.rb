Rails.application.routes.draw do
  scope '(pro)' do
    active_admin_devise_config = ActiveAdmin::Devise.config.deep_merge(
      controllers: {
        registrations: 'eva/devise/registrations',
        sessions: 'eva/devise/sessions',
        passwords: 'eva/devise/passwords'
      }
    )
    devise_for :comptes, active_admin_devise_config
    devise_scope :compte do
      post '/admin/login/connexion_espace_jeu', to: 'eva/devise/sessions#connexion_espace_jeu', as: 'connexion_espace_jeu'
    end
    get '/admin', to: redirect('/pro/admin/dashboard')

    get "inclusion_connect/logout" => "inclusion_connect#logout"
    get "inclusion_connect/auth" => "inclusion_connect#auth"
    get "inclusion_connect/callback" => "inclusion_connect#callback"
    get "demo" => "demo#show"
    post "demo/connect" => "demo#connect"

    ActiveAdmin.routes(self)
    get '/admin/structures/:id', to: 'structures#show'

    authenticate :compte, ->(o) { o.superadmin? } do
      mount Sidekiq::Web => '/sidekiq'
    end

    root to: redirect('/pro/admin/dashboard')

    resource :nouvelle_structure, only: [:create, :show]
    resources :structures, only: :index

    namespace :admin do
      resources :controle_syntheses_restitutions, only: :index
      resources :parties do
        namespace :cafe_de_la_place do
          resource :reponses, only: [:show], defaults: { format: 'xls' }
        end
      end
    end

    namespace :api do
      resources :campagnes, only: :show, param: :code_campagne
      resources :evaluations, only: [:create, :update] do
        resource :fin, only: [:create], controller: 'evaluations/fins'
        resource :collections_evenements, only: [:create],
          controller: 'evaluations/collections_evenements'
      end
      resources :questionnaires, only: [:show]
      resources :evenements
    end
  end
end

Rails.application.routes.draw do
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
  get '/admin', to: redirect('/admin/dashboard')

  get "pro_connect/logout" => "pro_connect#logout"
  get "pro_connect/auth" => "pro_connect#auth"
  get "pro_connect/callback" => "pro_connect#callback"
  get "demo" => "demo#show"
  post "demo/connect" => "demo#connect"

  ActiveAdmin.routes(self)
  get '/admin/structures/:id', to: 'structures#show'

  authenticate :compte, ->(o) { o.superadmin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: redirect('/admin/dashboard')

  resource :nouvelle_structure, only: [:create, :show]
  resources :structures, only: :index

  namespace :admin do
    resources :controle_syntheses_restitutions, only: :index
    get "/ui_kit/mise_en_avant", to: "ui_kit#mise_en_avant"
    namespace :positionnement do
      resources :parties do
        resource :reponses, only: [:show], defaults: { format: 'xls' }
      end
    end
    resources :questions do
      collection do
        post 'import_xls'
      end
      resource :export_xls, only: [:show], defaults: { format: 'xls' }, controller: 'questions/export_xls'
    end
    resources :questionnaires do
      member do
        get :export_questions, only: [:show], defaults: { format: 'xls' }
      end
    end
  end

  match '404', via: :all, to: 'erreurs#not_found'
  match '500', via: :all, to: 'erreurs#internal_serveur_error'
  match '422', via: :all, to: 'erreurs#unprocessable_entity'

  scope '(pro)' do
    namespace :api do
      resources :beneficiaires, only: :show, param: :code_personnel
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

  # Configuration avec préfixe /pro (pour compatibilité avec les anciennes URLs)
  get '/pro', to: redirect('/admin/dashboard')
  scope 'pro' do
    get '/admin', to: redirect('/admin/dashboard')
    get '/admin/*path', to: redirect { |params, request| "/admin/#{params[:path]}" }
    get '/*path', to: redirect { |params, request| "/#{params[:path]}" }
  end
end

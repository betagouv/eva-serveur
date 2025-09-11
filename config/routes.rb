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
    
    # UI Kit routes
    get '/ui_kit', to: 'ui_kit#index'
    get '/ui_kit/mise_en_avant', to: 'ui_kit#mise_en_avant'
    get '/ui_kit/badge', to: 'ui_kit#badge'
    get '/ui_kit/bouton', to: 'ui_kit#bouton'
    # get '/ui_kit/bouton_ajouter_une_structure', to: 'ui_kit#bouton_ajouter_une_structure'
    get '/ui_kit/bouton_copier', to: 'ui_kit#bouton_copier'
    get '/ui_kit/barre_segmentee', to: 'ui_kit#barre_segmentee'
    get '/ui_kit/carte', to: 'ui_kit#carte'
    # get '/ui_kit/carte_mise_en_action', to: 'ui_kit#carte_mise_en_action'
    get '/ui_kit/carte_partage_code', to: 'ui_kit#carte_partage_code'
    get '/ui_kit/code', to: 'ui_kit#code'
    get '/ui_kit/ellipse', to: 'ui_kit#ellipse'
    get '/ui_kit/lien', to: 'ui_kit#lien'
    get '/ui_kit/menu_actions', to: 'ui_kit#menu_actions'
    get '/ui_kit/nom_anonymisable', to: 'ui_kit#nom_anonymisable'
    get '/ui_kit/panel', to: 'ui_kit#panel'
    get '/ui_kit/pastille', to: 'ui_kit#pastille'
    # get '/ui_kit/qcm', to: 'ui_kit#qcm'
    get '/ui_kit/recherche_structure', to: 'ui_kit#recherche_structure'
    get '/ui_kit/referentiel_anlci', to: 'ui_kit#referentiel_anlci'
    get '/ui_kit/rejoindre_structure', to: 'ui_kit#rejoindre_structure'
    # get '/ui_kit/sous_competence', to: 'ui_kit#sous_competence'
    get '/ui_kit/statut_campagne', to: 'ui_kit#statut_campagne'
    get '/ui_kit/tableau', to: 'ui_kit#tableau'
    get '/ui_kit/tag', to: 'ui_kit#tag'
    get '/ui_kit/toggle', to: 'ui_kit#toggle'
    
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
      resources :beneficiaires, only: :show, param: :code_beneficiaire
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

Rails.application.routes.draw do
  devise_for :comptes, ActiveAdmin::Devise.config.deep_merge(controllers: {registrations: 'eva/devise/registrations'})
  get '/admin', to: redirect('/admin/dashboard')

  ActiveAdmin.routes(self)

  authenticate :compte, ->(o) { o.superadmin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: redirect('/admin/dashboard')

  resource :nouvelle_structure, only: [:create, :show]
  resources :structures, only: :index

  namespace :api do
    resources :campagnes, only: :show, param: :code_campagne
    resources :evaluations, only: [:create, :show, :update] do
      resource :fin, only: [:create], controller: 'evaluations/fins'
    end
    resources :questionnaires, only: [:show]
    resources :evenements
  end
end

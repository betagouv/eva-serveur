Rails.application.routes.draw do
  devise_for :comptes, ActiveAdmin::Devise.config.deep_merge(controllers: {registrations: 'eva/devise/registrations'})
  get '/admin', to: redirect('/admin/dashboard')

  ActiveAdmin.routes(self)

  root to: redirect('/admin/dashboard')

  resource :nouvelle_structure, only: [:create, :show]
  resources :structures, only: :index

  namespace :api do
    resources :evaluations, only: [:create, :show, :update] do
      resource :fin, only: [:create], controller: 'evaluations/fins'
    end
    resources :questionnaires, only: [:show]
    resources :evenements
  end
end

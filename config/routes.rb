Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'site#menu'
  resources :events, only: [:show]
  get '/updates', to: 'site#update'
  get 'events/:id/updates', to: 'events#update'
  
end

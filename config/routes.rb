Rails.application.routes.draw do

  match '/contact', to: 'welcome#contact', via: 'get'
  match '/about', to: 'welcome#about', via: 'get'

  resources :users, only: [:new, :show, :create]
  match '/signup', to: 'users#new', via: 'get'
  match '/export', to: 'users#export', via: 'get'
  match '/api/user/study_new_word', to: 'users#api_study_new_word', via: 'patch'
  match '/api/user/study_card', to: 'users#api_study_card', via: 'patch'
  
  resources :sessions, only: [:new, :create, :destroy]
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'
  
  resources :words, only: [:new, :show]
  match '/search', to: 'words#search', via: 'get'
  match '/update_content', to: 'words#update_content', via: 'get'
  match '/api/words/get', to: 'words#api_get', via: 'get'
  
  resources :new_words, only: [:new, :index]
  match '/new_words/play', to: 'new_words#play', via: 'get'
  match '/api/new_words/add', to: 'new_words#api_add', via: 'post'
  match '/api/new_words/delete', to: 'new_words#api_delete', via: 'delete'
  
  resources :cards, only: [:index]
  match '/cards/play', to: 'cards#play', via: 'get'
  match '/api/cards/batch', to: 'cards#api_get_batch', via: 'get'
  match '/api/cards/get', to: 'cards#api_get', via: 'get'
  match '/api/cards/add', to: 'cards#api_add_word', via: 'post'
  match '/api/cards/schedule', to: 'cards#api_new_schedule', via: 'patch'
  match '/api/cards/delete', to: 'cards#api_delete', via: 'delete'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#home'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

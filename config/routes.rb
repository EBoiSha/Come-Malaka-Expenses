Rails.application.routes.draw do
  #get 'home/index'

  devise_for :users, controllers: { invitations: :event_invitations }

  devise_scope :user do 
    match 'events/:event_id/invite', :to => 'event_invitations#new', :via => :get, :as => :invite_to_event
  end  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  #root 'welcome#index'
  root to: "home#index"

  resources :events do
    resources :items, shallow: true
  end
  get 'event_items/:event_id' => 'events#event_all_items', as: :event_all_items
  get 'expense_report/:event_id' => 'events#expense_report', as: :expense_report
  get 'who_owes_you/:event_id' => 'events#who_owes_you', as: :who_owes_you
  get 'you_owe_whom/:event_id' => 'events#you_owe_whom', as: :you_owe_whom

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

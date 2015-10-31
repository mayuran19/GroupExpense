Rails.application.routes.draw do
  resources :sessions
  resources :registrations
  resources :users
  resources :expenses_summary

  resources :expense_cycles do
      member do
          get :send_email
      end
  end
  
  resources :fixed_expenses do
      member do
          get :new_expense
          post :create_expense
      end
  end

  resources :expenses do
      member do
          get :edit_division_factor
          post :update_division_factor
      end
      resources :expenses_per_user
  end

  get "log_out" => "sessions#destroy", :as => "log_out"

  #Error routing
  get "/404" => "errors#not_found"
  get "/500" => "errors#internal_server_error"

  root 'home#index'
  
  #get "expenses/fixed_expense/:id/edit" => "expenses#fixed_expense", :as => "edit_fixed_expense"
  #delete "expenses/fixed_expense/:id" => "expenses#delete_fixed_expense", :as => "delete_fixed_expense"
  #get "expenses/fixed_expenses" => "expenses#fixed_expenses"

  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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

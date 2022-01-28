Rails.application.routes.draw do
  root "static_pages#workshop"

  controller :sessions do
    get "login" => :new
    post "login" => :create
    delete "logout" => :destroy
  end

  controller :static_pages do
    get "pages/privacy-policy" => :privacy
    get "pages/terms" => :terms
    get "pages/about" => :about
    get "workshop" => :workshop
  end

  post "/workshop_users", to: "users#create_workshop_users"

  get "/unsubscribe", to: "users#unsubscribe", as: :unsubscribe
  resources :users, only: [:index, :new, :create, :destroy] do
    collection do
      get :export
      get :download
    end
  end
  resources :blogs, except: [:delete, :destroy]
  resources :tags, only: [:destroy]
  resources :emails, except: [:delete] do
    collection do
      post :send_daily_email
    end
  end
  get "/emails/:id/send_test_email", to: "emails#test_email", as: :test_email

  get "/blog", to: "blogs#index" # old path from kajabi app
  post "/blogs/search", to: "blogs#index", as: :blog_search
end

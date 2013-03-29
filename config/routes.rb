Txlogic::Application.routes.draw do
  devise_for :users
  
  resources :alerts do
    member do
      get 'accept'
      get 'stop'
    end
  end
  post 'launch/(:id)' => "alerts#create", :as => :launch, :constraints => { :protocol => 'https' }

  resources :a, :controller => :alert_deliveries, :only => :show

  resources :process_definitions, :as => 'processes' do
    member do
      get 'invoke'
      post 'pause'
      post 'resume'
    end
  end

  resources :replies do
    collection do
      post 'tropo'
      post 'mailgun'
    end
  end
  
  resources :members, :only => [ :index, :create, :destroy ]
  
  #root :to => "alerts#index"
  root :to => "pages#index"
end

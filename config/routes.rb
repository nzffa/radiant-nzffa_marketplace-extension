ActionController::Routing::Routes.draw do |map|
  map.resources :adverts,
    :collection => {
      :edit_company_listing => :get,
      :index_table => :get,
      :my_adverts => :get,
    },
    :member => {
      :renew => :put,
      :email => [:get]
    }
  map.namespace :admin do |admin|
    admin.resources :adverts
  end
end

Rails.application.routes.draw do
  mount RailsEventStore::Browser => "/res" if Rails.env.development?
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "posts#index"

  post "table/create", to: "tables#create"
  post "table/delete", to: "tables#delete"
  post "table/column", to: "tables#column"
  post "table/show", to: "tables#show"
end

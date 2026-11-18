Rails.application.routes.draw do
  get "/up", to: "health#show"
  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"
    end
  end
end

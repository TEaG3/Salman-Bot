Rails.application.routes.draw do
  get "/up", to: "health#show"
  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"
      post "assistant/plan", to: "assistant#plan"
      post "automations/preview", to: "automations#preview"
      resources :automations, only: %i[index show create update destroy] do
        post :run, on: :member
      end
    end
  end
end

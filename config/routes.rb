Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/activity/all', to: 'activity_stream#collection'
  get '/activity/page/:page_number', to: 'activity_stream#page'

  post '/resource', to: 'resource#create'
  post '/resource/refresh', to: 'resource#refresh'
end

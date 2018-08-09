Rails.application.routes.draw do

	resources :admin

	devise_scope :user do
		get '/login' => 'sessions#new', as: 'login'
		get '/logout' => 'sessions#destroy', as: 'logout'
		get '/register' => 'registrations#new', as: 'register'
	end
	devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'sessions' }

	mount SwellId::Engine, at: '/'

end
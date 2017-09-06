# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

require 'sidekiq/web'
mount Sidekiq::Web => '/sidekiq', constraints: lambda { |request| User.current.admin? }

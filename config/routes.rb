Rails.application.routes.draw do
  get '/v1/users/:id/billing' => 'subscriptions#index', as: :billing
  patch '/v1/users/:id/billing' => 'subscriptions#edit_subscription', as: :edit_subscription
  get '/v1/users/:id/billing/history' => 'subscriptions#billing_history', as: :billing_history
  get '/v1/subscriptions/new' =>'subscriptions#new', as: :new_subscription
  delete '/v1/users/:id/billing' => 'subscriptions#destroy', as: :subscription
  get '/v1/users/:id/billing/sub_data' => 'subscriptions#subscription_data', as: :sub_data

  get '/v1/users/:id/billing/invoices' => 'invoices#index', as: :invoices
  get '/v1/users/:id/billing/invoices/:invoice_id' => 'invoices#show', as: :invoice_show
  get '/v1/users/:id/billing/invoices/:invoice_id/pdf' => 'invoices#create_pdf', as: :create_invoice_pdf
  get '/v1/users/:id/billing/invoices/:invoice_id/send' => 'invoices#send_customer_invoice_email', as: :send_invoic_email
  get '/v1/users/:id/billing/invoices/:custom_id/custom' => 'invoices#custom_user_invoices', as: :custom_show

  delete '/v1/users/:id/billing/add-ons/:add_ons_id' => 'subscriptions#delete_add_ons', as: :delete_add_ons

  get '/pay' => 'payments#pay', as: :pay
  get '/thank-for-payment' => 'payments#thank', as: :thank_payment
  post '/pay' => 'payments#make_payment', as: :make_payment
  get '/v1/payments' => 'payments#new', as: :new_checkout
  post '/v1/payments' => 'payments#create', as: :new_charge
  post '/v1/users/:id/billing/plans/change' => 'payments#upgrade_downgrade_plan'

  # These routes are for managing customer cards on Stripe
  resources :stripe_customers, only: [:create, :update]
  resources :credit_cards, only: [:create, :destroy]

  resources :line_items, only: [:destroy]
  post 'line_items/create_subscription' => 'line_items#create_subscription', as: :line_item_subscription
  post 'line_items/create_add_on' => 'line_items#create_add_on', as: :line_item_add_on

  mount StripeEvent::Engine => '/stripe-events'

  root to: redirect('/v1/cameras'), as: :root
  get '/v1/cameras' => 'cameras#index', as: :cameras_index
  get '/v1/cameras/new' => 'cameras#new', as: :cameras_new
  get '/v1/cameras/new-test' => 'cameras#addcam_test', as: :cameras_new_test
  post '/v1/cameras/new' => 'cameras#create'
  get '/cameras/transfer' => 'cameras#transfer'
  get '/status' => 'cameras#online_offline'
  get '/map' => 'cameras#map', as: :map_view
  get '/cameras_table' => 'cameras#cameras_table'
  get '/v1/cameras/:id' => 'cameras#single', as: :cameras_single
  get '/v1/cameras/:id/clone' => 'cameras#new', as: :cameras_clone
  get '/v1/cameras/:id/404' => 'cameras#camera_not_found', as: :cameras_not_found
  patch '/v1/cameras/:id' => 'cameras#update'
  delete '/cameras/:id' => 'cameras#delete'
  post 'cameras/:id/request_clip' => 'cameras#request_clip', as: :request_clip
  delete 'cameras/clip/delete' => 'cameras#delete_clip', as: :delete_clip
  get '/v1/cameras/:id/clip/:clip_id/play' => 'pages#play', as: :play_clip
  get '/v1/cameras/:id/share/request' => 'pages#revoke_request'
  post '/log_intercom' => 'cameras#log_intercom'

  get '/v1/cameras/:id/*subpath' => 'cameras#single'
  get '/v1/users/:id/billing/*subpath' => 'subscriptions#index'

  get '/v1/snapmails' => 'snapmails#index', as: :snapmails_index
  get '/v1/snapmails/:id/unsubscribe' => 'pages#unsubscribe'
  post '/v1/snapmails/:id/unsubscribe' => 'pages#unsubscribed', as: :unsubscribed_snapmail

  get '/timelapses' => 'timelapses#index', as: :timelapses_index

  get '/v1/public/cameras' => redirect('https://evercam.io/public/cameras/')
  get '/v1/public/cameras/:id' => redirect('https://evercam.io/public/cameras/')

  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create, :edit]
  get '/sessions' => redirect('/')

  get '/v1/users/signup' => 'users#new', as: :signup
  post '/v1/users/signup' => 'users#create'
  get '/v1/users/password-reset' => 'users#password_reset_request', as: :password_reset
  post '/v1/users/password-reset' => 'users#password_reset_request'
  get '/v1/users/password-new' => 'users#password_update_form', as: :password_new
  post '/v1/users/password-new' => 'users#password_update'
  get '/v1/users/:id/resend' => 'users#resend_confirmation_email', as: :user_email_resend
  get '/confirm' => 'users#confirm'
  get '/v1/users/signin' => 'sessions#new', as: :signin
  get '/widget_signin' => 'sessions#widget_new', as: :widget_signin
  delete '/v1/users/signout' => 'sessions#destroy', as: :signout
  get '/v1/users/:id' => 'users#user_account', as: :user_account
  get '/v1/users/:id/password' => 'users#password_change', as: :password_change
  get '/v1/users/:id/settings' => 'users#settings', as: :user_settings
  delete '/v1/users/:id' => 'users#delete'
  post '/v1/users/:id' => 'users#settings_update'
  put '/v1/users/:id/password/change' => 'users#change_password', as: :user_change_password

  get '/widgets-new' => 'widgets#widgets_new', as: :widget_live_view
  get '/live.view.widget' => 'widgets#live_view_widget'
  get '/live.view.private.widget' => 'widgets#live_view_private_widget'
  get '/widgets-hikvision' => 'widgets#widgets_hikvision', as: :widget_hikvision
  get '/hikvision.local.storage' => 'widgets#hikvision_local_storage'
  get '/hikvision.private.widget' => 'widgets#hikvision_private_widget'

  get '/widgets-snapshot-navigator' => 'widgets#widget_snapshot_navigator', as: :widget_snapshot_navigator
  get '/snapshot.navigator.widget' => 'widgets#snapshot_navigator_widget'
  get '/snapshot.navigator' => 'widgets#snapshot_navigator'
  get '/widget' => 'widgets#widget', as: :widget

  namespace :widgets do
    resources :widget_cameras_add, path: :widget_cameras_add
    get '/cameras/add' => 'widget_cameras_add#widget_add_camera', as: :widget_camera_add
    get '/cameras/public/add' => 'widget_cameras_add#add_public_camera'
    get '/add.camera' => 'widget_cameras_add#add_camera'
  end

  get '/live/:id' => 'pages#live'
  get '/good_bye' => 'pages#good_bye', as: :good_bye

  post '/share' => 'sharing#create'
  delete '/share' => 'sharing#delete'
  post '/share/camera/:id' => 'sharing#update_camera'
  delete '/share/request' => 'sharing#cancel_share_request'
  post '/share/request/resend' => 'sharing#resend_share_request'
  patch '/share/request' => 'sharing#update_share_request'
  patch '/share/:id' => 'sharing#update_share'

  get '*path' => 'pages#log_and_redirect'

end

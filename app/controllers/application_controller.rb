class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  prepend_before_filter :authenticate_user!, :set_cache_buster,

  def authenticate_user!
    if current_user.nil? or (params.has_key?(:api_id) and params.has_key?(:api_key))
      user = nil
      redirect_url = request.original_url
      if params.has_key?(:api_id) and params.has_key?(:api_key)
        user = User.where(api_id: params[:api_id], api_key: params[:api_key]).first
        redirect_url = remove_param_credentials(redirect_url)
      end

      if user.nil?
        session[:redirect_url] = redirect_url
        redirect_to signin_path
      else
        sign_in user
        update_user_intercom(user)
        redirect_to redirect_url
      end
    end
  end

  def update_user_intercom(user)
    if Evercam::Config.env == :development
      intercom = Intercom::Client.new(
        app_id: Evercam::Config[:intercom][:app_id],
        api_key: Evercam::Config[:intercom][:api_key]
      )
      begin
        ic_user = intercom.users.find(:email => user.email)
      rescue
        #Intercom::ResourceNotFound
        # Ignore it
      end
      unless ic_user.nil?
        begin
          ic_user.last_request_at = Time.now.to_i
          ic_user.new_session = true
          ic_user.last_seen_ip = request.remote_ip
          intercom.users.save(ic_user)
        rescue => error
          # Ignore it
        end
      end
    end
  end

  def owns_data!
    if current_user.username != params[:id]
      sign_out
      redirect_to signin_path
    end
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def load_user_cameras(shared, thumbnail)
    api = get_evercam_api
    begin
      api.get_user_cameras(current_user.username, shared, thumbnail) if @cameras.blank?
    rescue => error
      Rails.logger.error "Exception caught fetching user cameras.\nCause: #{error}"
      []
    end
  end

  def remove_param_credentials(original_url)
    require 'uri'

    uri = URI original_url
    params = Rack::Utils.parse_query uri.query
    params.delete('api_id')
    params.delete('api_key')
    uri.query = params.to_param
    uri.to_s
  end

  # Added before_action to decouple @cameras from users controller
  def ensure_cameras_loaded
    if @cameras.nil?
      load_user_cameras(true, false)
    end
  end

  def set_prices
    @prices = Prices.new
  end

  def is_stripe_customer?
    current_user.stripe_customer_id.present?
  rescue
    return false
  end
  helper_method :is_stripe_customer?

  # Started to move some methods from helper to application controller because
  # helpers should not make calls to db/API calls
  def retrieve_stripe_subscriptions
    if is_stripe_customer?
      @subscriptions = Stripe::Customer.retrieve(current_user.stripe_customer_id).subscriptions.all
    end
  end

  def current_subscription
    if current_user.stripe_customer_id.present?
      customer = StripeCustomer.new(current_user.stripe_customer_id)
      subscription = customer.current_plan ? customer.current_plan : false
    else
      false
    end
  end

  def retrieve_add_ons
    @add_ons = AddOn.where(:user_id => current_user.id)
    @add_ons = @add_ons.nil? ? false : @add_ons
    @snapmail = 0
    @timelapse = 0
    @seven_days_recording = 0
    @restream = 0
    @thirty_days_recording = 0
    @ninety_days_recording = 0
    @add_ons.each do |add_on|
      case add_on.exid
        when "snapmail", "snapmail-annual"
          @snapmail += 1
        when "timelapse", "timelapse-annual"
          @timelapse += 1
        when "7-days-recording", "7-days-recording-annual"
          @seven_days_recording += 1
        when "30-days-recording", "30-days-recording-annual"
          @thirty_days_recording += 1
        when "90-days-recording", "90-days-recording-annual"
          @ninety_days_recording += 1
        when "restream", "restream-annual"
          @restream += 1
      end
    end
  end

end

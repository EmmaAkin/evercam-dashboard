class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!, :set_cache_buster

  def authenticate_user!
    if current_user.nil?
      session[:redirect_url] = request.original_url
      redirect_to signin_path
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
    end
  end
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate

  helper_method :current_user

  rescue_from GrpExp::Exception::AuthorizationError, with: :access_denied

  def authenticate
    redirect_to new_session_path unless current_user
  end

  private

  def current_user
      user_id_in_session = session[:user_id]
      if user_id_in_session && User.where(:id => user_id_in_session).count > 0
          @current_user = User.find(user_id_in_session)
      end
  end

  def set_tab_name(active_tab)
    @active_tab = active_tab
  end

  def access_denied(exception)
    logger.error(exception)
    render 'errors/access_denied', layout: 'errors'
  end
  
end

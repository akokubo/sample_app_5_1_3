class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

    # Confirms a logged-in user.
    def logged_in_user
      # ログインしていなければ
      unless logged_in?
        # 現在のURLを記録
        store_location
        # ログインURLにリダイレクトし、ログインするように促して
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
      # ログインしていれば何もしない
    end
end

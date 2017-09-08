class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  before_action :set_locale

  private

    # Confirms a logged-in user.
    def logged_in_user
      # ログインしていなければ
      unless logged_in?
        # 現在のURLを記録
        store_location
        # ログインURLにリダイレクトし、ログインするように促して
        flash[:danger] = t(:please_log_in)
        redirect_to login_url
      end
      # ログインしていれば何もしない
    end

  # 全リンクにlocale情報をセットする
  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  # リンクの多言語化に対応する
  def set_locale
    # I18n.locale = params[:locale] if params[:locale].present?
    I18n.locale = params[:locale] || I18n.default_locale
  end
end

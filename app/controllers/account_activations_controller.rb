class AccountActivationsController < ApplicationController

  # ユーザーの有効化を行うアクション
  def edit
    user = User.find_by(email: params[:email])
    # メールアドレスに対応したユーザーが存在し、未有効化で、有効化トークンで認証できるか？
    # URLがprotocol://host/account_activations/有効化トークン/edit?email=メールアドレス
    # なので、params[:id]には有効化トークンが入る
    # 未有効化をチェックしないと、後から有効化トークンを入手したものが悪用し、
    # ログインされる可能性がある(ここでログインさせているから)
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = t(:account_activated)
      redirect_to user
    else
      flash[:danger] = t(:invalid_activation_link)
      redirect_to root_url
    end
  end
end

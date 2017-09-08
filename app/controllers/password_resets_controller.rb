class PasswordResetsController < ApplicationController
  # 実際のパスワード変更の処理には以下のコールバックでユーザーの状態のチェックを実施
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update] # Case (1) # 再設定トークンの有効期限検証

  # パスワード再設定エントリーのためのフォームを表示
  def new
  end

  # パスワード再設定エントリーの処理
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    # 指定したメールアドレスに相当するユーザーがいたら
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t(:email_sent_with_password_reset_instructions)
      redirect_to root_url
    # 指定したメールアドレスに相当するユーザーがいなかったら
    else
      flash.now[:danger] = t(:email_address_not_found)
      render 'new'
    end
  end

  # パスワード再設定実行のためのフォームを表示
  def edit
  end

  # パスワード再設定実行のための処理
  def update
    if params[:user][:password].empty?                    # Case (3) # パスワードが空。検証では空でも通るから(パスワードを変更しないとき)、ここでチェック
      # ActiveRecordがエラーメッセージを追加しないタイプのエラーなので、自分で追加する
      @user.errors.add(:password, t(:cannot_be_empty))
      render 'edit'
    elsif @user.update_attributes(user_params)            # Case (4) # パスワード再設定を試みる
      log_in @user
      # パスワードが再設定されたら、リセットトークン(のダイジェスト)を空に
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = t(:password_has_been_reset)
      redirect_to @user 
    else
      render 'edit'                                       # Case (2) # パスワードが検証にひっかかる
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # Confirms a valid user.
    def valid_user
      # ユーザーが存在し、有効化され、再設定トークンで認証できなければはじいて、
      # トップページに
      # idにはリセットトークンが入っている
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # Checks expiration of reset token.
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = t(:password_reset_has_expired)
        redirect_to new_password_reset_url
      end
    end
end

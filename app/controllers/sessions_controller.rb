class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user
        # remember_meのチェックに応じた処理
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        # 転送元があればそこに、なければユーザーのページにリダイレクトさせる
        redirect_back_or @user
      else
        message  = t(:account_not_activated)
        message += t(:check_your_email_for_the_activation_link)
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = t(:invalid_email_password_combination) # Not quite right!
      render 'new'
    end
  end

  def destroy
    # あるウィンドウでログアウトし、別ウィンドウで二重ログアウトしたときは
    # ログアウト処理を行わない
    log_out if logged_in?
    redirect_to root_url
  end
end

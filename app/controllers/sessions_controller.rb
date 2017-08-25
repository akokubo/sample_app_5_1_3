class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        # remember_meのチェックに応じた処理
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        # 転送元があればそこに、なければユーザーのページにリダイレクトさせる
        redirect_back_or user
      else
        message  = "Account not activated."
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination' # Not quite right!
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

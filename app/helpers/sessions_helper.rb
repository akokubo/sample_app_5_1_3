module SessionsHelper

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Remembers a user in a persistent session.
  def remember(user)
    # 新しくremember_tokenを生成し、ハッシュ化して、バリデーションなしで
    # データベースのremember_digestに保存
    user.remember
    # user_idを署名付きcookiesで暗号化して永続保存
    cookies.permanent.signed[:user_id] = user.id
    # remember_tokenを通常のcookiesに永続保存
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    # セッションにuser_idが保存されていれば※比較でなく代入
    if (user_id = session[:user_id])
      # @current_userが空なら、データベースからuser_idに相当する
      # ユーザーを取り出して代入
      @current_user ||= User.find_by(id: user_id)
    # 署名付きcookiesにuser_idが保存されていれば※比較でなく代入
    elsif (user_id = cookies.signed[:user_id])
      # データベースからuser_idに相当するユーザーを取り出しuserに代入
      user = User.find_by(id: user_id)
      # ユーザーが存在し、cookiesに保存されたremember_tokenで認証できれば
      if user && user.authenticated?(:remember, cookies[:remember_token])
        # ログイン処理を実行
        log_in user
        # @current_userにユーザーを代入
        @current_user = user
      end
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    # データベースのremember_digestを空にする
    forget(current_user)
    # セッションからuser_idを削除
    session.delete(:user_id)
    # @current_userを空に
    @current_user = nil
  end
  
  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    # フォーワード﨑が設定されていれば、そこにリダイレクト。そうでなければデフォルトにリダイレクト
    # Sessionsコントローラーのcreateアクションでは、デフォルトはユーザーのページになっている
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    # 元のURLがあれば、それを記憶
    session[:forwarding_url] = request.original_url if request.get?
  end
end

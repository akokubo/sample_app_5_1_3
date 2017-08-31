require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    # 他のテストのメール送信と競合しないようにクリア
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'

    # Invalid email
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # Valid email
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    # パスワード再設定トークンが更新された
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    # メールが1通送信された
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    # Password reset form
    # コントローラー(password_resers)の対応したアクション(create)のインスタンス変数(@user)の値を取得
    user = assigns(:user)

    # Wrong email
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url

    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)

    # Right email, wrong token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url

    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # Invalid password & confirmation
    # パスワードとその確認が一致しない
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'

    # Empty password
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'

    # Valid password & confirmation
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
    assert_nil user.reload.reset_digest
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path,
         params: { password_reset: { email: @user.email } }

    @user = assigns(:user)
    # 期限後の3時間後にリセット
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
    # たぶんトップページに転送される
    assert_response :redirect
    follow_redirect!
    # 本文中にexpiredの文字列がある
    assert_match /expired/i, response.body
  end
end

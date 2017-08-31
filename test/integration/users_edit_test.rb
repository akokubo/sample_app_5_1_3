require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end
  
  # バリデーションに失敗するデータを送ると、再び編集フォームが表示される
  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    # バリデーションに失敗するデータ(名前が空)を送る
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }
    assert_template 'users/edit'
    assert_select 'div.alert', 'The form contains 4 errors.'
  end
  
  # 適切なデータを送ると更新される
  test 'successful edit with friendly forwarding' do
    # ログインしていない状況でユーザー情報を編集しようとした
    get edit_user_path(@user)

    # セッションに(元の)URLが入った
    assert_not_nil session[:forwarding_url]

    # ここでログインページに飛ばされているはず
    # そしてログインしたら
    log_in_as(@user)
    # 編集しようとしていたページに戻る(フレンドリー・フォーワーディングされている)
    assert_redirected_to edit_user_url(@user)

    # 名前とメールアドレスを変更
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }

    assert_not flash.empty?
    # 元のページに転送
    assert_redirected_to @user
    # セッションに(元の)URLが空になっている
    assert_nil session[:forwarding_url]
    
    # 再読み込みして更新されたデータを取得
    @user.reload
    # 変更されていることを確認
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
end

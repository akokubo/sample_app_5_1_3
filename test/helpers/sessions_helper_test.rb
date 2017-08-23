require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    remember(@user)
  end

  # ユーザーをcookiesで永続化しておけば、明示的にログインを実行していなくて、
  # セッションが空でもcurrent_userが有効で、ログイン状態が維持されている。
  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  # ログイン処理などでremember_digestが更新されると、current_userが無効になる
  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end

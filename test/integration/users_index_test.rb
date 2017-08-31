require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    # indexアクションのテスト
    log_in_as(@admin)

    # 最初の1人のアカウントを無効にする
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.first.toggle!(:activated)

    get users_path
    assert_template 'users/index'

    # ページネーションのテスト
    assert_select 'div.pagination'

    # users#indexの@usersの値(ここには無効なユーザーは含まれないはず)を参照
    assigns(:users).each do |user|
      # 個々のユーザーが有効
      assert user.activated?
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end

    # deleteリクエストのテスト
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  # 管理者でなければdeleteリンクが表示されない
  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end

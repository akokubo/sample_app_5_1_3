ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper

  # Add more helper methods to be used by all tests here...

  # Returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end

  # 指定したユーザーでログイン※コントローラーの単体テスト用
  # Log in as a particular user.
  def log_in_as(user)
    # セッションにuser_idが入っていさえすれば、ログインは永続化されて
    # いないが、ログインしたことになる
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest

  # 指定したユーザーでログイン※統合テスト用
  # Log in as a particular user.
  def log_in_as(user, password: 'password', remember_me: '1')
    # 統合テストでは、sessionに値を直接書き込めないので、login_pathに
    # postしてログインする
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
end

class ActionDispatch::Routing::RouteSet
  def default_url_options(options={})
    { :locale => I18n.default_locale }
  end
end

class ActionView::TestCase::TestController
  def default_url_options(options={})
    { :locale => I18n.default_locale }
  end
end

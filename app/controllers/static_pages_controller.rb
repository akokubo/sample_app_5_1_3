class StaticPagesController < ApplicationController
  def home
    if logged_in?
      # マイクロポストの投稿フォームのために必要
      @micropost  = current_user.microposts.build
      # フィードの表示
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end

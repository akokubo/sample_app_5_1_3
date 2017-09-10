class StaticPagesController < ApplicationController
  def home
    if logged_in?
      # マイクロポストの投稿フォームのために必要
      @micropost  = current_user.microposts.build
      # フィードの表示
      @feed_items = current_user.feed.paginate(page: params[:page])

      # infinite scrollの表示
      @objects = @feed_items
      @target = "#feed"
      respond_to do |format|
        format.html
        format.js { render 'shared/_next_page' }
      end
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end

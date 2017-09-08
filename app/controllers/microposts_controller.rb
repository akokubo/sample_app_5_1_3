class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  # 自分で投稿したマイクロポストだけ削除可能
  before_action :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = t(:micropost_created)
      redirect_to root_url
    else
      # homeを表示させるのに、@feed_itemsが必要なため
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = t(:micropost_deleted)
    # 削除を実行したページ(なければトップページ)にリダイレクト
    # redirect_to request.referrer || root_url
    # 上記と同じ
    redirect_back(fallback_location: root_url)
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end

    def correct_user
      # 自分が投稿したマイクロポストからidを検索
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end

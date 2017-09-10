class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    # 有効なユーザーだけを取り出す
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])

    # infinite scrollの表示
    @objects = @microposts
    @target = "#microposts"
    respond_to do |format|
      format.html
      format.js { render 'shared/_next_page' }
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # アカウント有効化メールを送る
      @user.send_activation_email
      flash[:info] = t(:please_check_your_email_to_activate_your_account)
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = t(:profile_updated)
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:notice] = t(:user_deleted)
    redirect_to users_url
  end

  def following
    @title = t(:following)
    @user = User.find(params[:id])
    # フォローしているユーザーたち
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = t(:followers)
    @user = User.find(params[:id])
    # フォローされているユーザーたち
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # Before filters

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # Confirm an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end

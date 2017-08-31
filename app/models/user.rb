class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  # フォローする関係
  # ActiveRelationshipモデルは存在せず、実態はRelationshipモデル
  # RelationshipモデルからUserモデルを参照するにはuser_idでなくfollower_idを使用
  has_many :active_relationships,  class_name: "Relationship",
                                   foreign_key: "follower_id",
                                   dependent: :destroy
  # フォローされる関係
  # PassiveRelationshipモデルは存在せず、実態はRelationshipモデル
  # RelationshipモデルからUserモデルを参照するにはuser_idでなくfollowed_idを使用
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy
  # 以下のように記述すると、active_relationshipsを経由して、
  # followedsフォローしている人たちを参照できる
  # 具体的には@user.followeds
  # has_many :followeds, through: :active_relationships
  # しかし、@user.followedsだと英語としておかしく、@user.followingにしたいので
  # 以下のように記述する
  has_many :following, through: :active_relationships,  source: :followed
  # source: :followerは不要だが、上記と同じ形式で書きたかったので指定
  has_many :followers, through: :passive_relationships, source: :follower
  # データベースに存在しないremember_token、activation_token、reset_token属性を用意

  attr_accessor :remember_token, :activation_token, :reset_token

  # 保存する前にメールアドレスを小文字化
  before_save   :downcase_email
  # ユーザーを作る前にだけ有効化ダイジェストを生成
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # 連続した..を含んだメールアドレスを許容しない場合
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  # パスワードが空でも更新を可能にする。新規作成時に空だとhas_secure_passwordではねられる
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # この場合、selfはUserオブジェクトではなく、Userクラスを表す
  class << self
    # Returns the hash digest of the given string.
    # def User.digest(string)
    # この場合、selfはUserオブジェクトではなく、Userクラスを表す
    # def self.digest(string)
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
  
    # Returns a random token.
    # def User.new_token
    # この場合、selfはUserオブジェクトではなく、Userクラスを表す
    # def self.new_token
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    # 新しくトークンを生成
    self.remember_token = User.new_token
    # ハッシュ化し、データベースにバリデーションをスルーして保存
    # バリデーションをスルーしないとパスワードが必要になる
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  # attributeに何のトークンかを入れ、tokenにトークンそのものを入れて呼び出す
  def authenticated?(attribute, token)
    # digest変数に指定した種類のトークンのダイジェストを代入
    # sendメソッドは、オブジェクトにメッセージを送る
    # このコードでは、引数を使いメッセージの内容を動的に指定し、
    # データベースに保存された指定した種類のトークンのダイジェストを取得している
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    # トークンをダイジェスト化して、保存されたダイジェストと比較
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    # バリデーションをスルーしてremember_digestを空にする
    # バリデーションをスルーしないとパスワードが必要になる
    update_attribute(:remember_digest, nil)
  end

  # Activates an account
  def activate
    # update_attribute(:activated,    true)
    # update_attribute(:activated_at, Time.zone.now)
    # 以上の2行を1行で
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    # update_attribute(:reset_digest,  User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
    update_columns(reset_digest:  User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    # パスワード再設定トークンの有効期限を2時間に設定
    reset_sent_at < 2.hours.ago
  end

  # Returns a user's status feed.
  def feed
    # フォローしているユーザーと自身のユーザーIDでマイクロポストを検索
    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
    #                  following_ids: following_ids, user_id: user_id)
    # 上記のコードだと、following_idsを求め、次にマイクロポストを検索する
    # 下記のようにSQLにSQLを埋め込むと検索が1回で済む
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end

  # Follows a user.
  def follow(other_user)
    following << other_user
  end

  # Unfollows a user.
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Return true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private

    # Converts email to all lower-case.
    def downcase_email
      # self.email = email.downcase
      email.downcase!
    end

    # Creates and assigns the activation token and digest
    # 有効化トークンとそのダイジェストを生成
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end

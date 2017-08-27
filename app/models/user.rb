class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  # データベースに存在しないremember_token、activation_token、reset_token属性を用意
  attr_accessor :remember_token, :activation_token, :reset_token
  # 保存する前にメールアドレスを小文字化
  before_save   :downcase_email
  # ユーザーを作る前にだけ有効化ダイジェストを生成
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i 
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  # パスワードが空でも更新を可能にする。新規作成時に空だとhas_secure_passwordではねられる
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true


  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
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
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
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

  # Defines a proto-feed.
  # See "Following users" for the full implementation.
  def feed
    Micropost.where("user_id = ?", id)
  end

  private

    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    # Creates and assigns the activation token and digest
    # 有効化トークンとそのダイジェストを生成
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end

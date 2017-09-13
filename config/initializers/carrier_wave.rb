if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Configuration for Amazon S3
      :provider              => 'AWS',
      :region                => ENV['S3_REGION'],
      :aws_access_key_id     => ENV['S3_ACCESS_KEY'],
      :aws_secret_access_key => ENV['S3_SECRET_KEY']
    }
    config.fog_directory     =  ENV['S3_BUCKET']

    # for access restrict
    # config.fog_public = false
    # config.fog_authenticated_url_expiration = 60
  end
end

# for Filenames and unicode chars
CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

module CarrierWave
  module MiniMagick
    # Rotates the image based on the EXIF Orientation
    # https://gist.github.com/jcsrb/1510601
    # http://qiita.com/ppworks/items/ae479c036d25b3e7b120
    def fix_exif_rotation
      manipulate! do |img|
        img.auto_orient
        yield(img) if block_given?
        img
      end
    end
  end
end

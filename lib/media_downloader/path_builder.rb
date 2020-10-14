# frozen_string_literal: true

module MediaDownloader
  class PathBuilder

    # @return [String]
    attr_reader :download_to

    # @return [MediaDownloader::MediaWrapper]
    attr_reader :media_wrapper

    # @return [Twitter::Tweet]
    attr_reader :tweet

    # @param [String] download_to
    # @param [MediaDownloader::MediaWrapper] media_wrapper
    def initialize(download_to, media_wrapper)
      @download_to = download_to
      @media_wrapper = media_wrapper
      @tweet = @media_wrapper.tweet
    end

    # パスをビルド
    # ダウンロード先のベースディレクトリ, メディア種別, 作成年, 作成月, 作成日, ツイートID, ファイル名 の順
    #
    # @return [String]
    def build
      year, month = created_at.strftime('%Y:%m').split(':')

      File.join(@download_to, media_type, year, month, tweet_id, filename)
    end

    private

    # メディアのタイプからディレクトリ名を取得
    #
    # @return [String]
    def media_type
      case @media_wrapper.media
      when Twitter::Media::Photo
        'photo'
      when Twitter::Media::Video
        'video'
      else
        'undefined'
      end
    end

    # ツイートの作成日を Asia/Tokyo で取得
    #
    # @return [ActiveSupport::TimeWithZone]
    def created_at
      @tweet.created_at.in_time_zone('Asia/Tokyo')
    end

    # ツイートの日付を文字列で取得 (ISO 8601)
    #
    # @return [String]
    def date
      created_at.strftime('%F')
    end

    # ツイートのIDを取得
    #
    # @return [String]
    def tweet_id
      @tweet.id.to_s
    end

    # ファイル名を作成
    #
    # @return [String]
    def filename
      "#{date}_#{tweet_id}_#{index}#{ext_name}"
    end

    # ファイル名に使うメディアのインデックスを取得
    # プログラム上の index ではなく, display_index を使う
    #
    # @return [String]
    def index
      @media_wrapper.display_index.to_s
    end

    # ファイルの拡張子を取得
    #
    # @return [String]
    def ext_name
      picker = MediaURIPicker.new(@media_wrapper)
      uri = picker.pick.dup
      uri.query_values = nil
      File.extname(uri.to_s)
    end
  end
end

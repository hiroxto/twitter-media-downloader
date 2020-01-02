# frozen_string_literal: true

module MediaDownloader
  class Downloader

    # Twitterのクライアント
    #
    # @return [Twitter::REST::Client]
    attr_reader :client

    # ダウンロード対象のツイートのID
    #
    # @return [String]
    attr_reader :tweet_id

    # ダウンロード対象のツイート
    #
    # @return [Twitter::Tweet]
    attr_reader :tweet

    # ダウンロード先のベースディレクトリ
    #
    # @return [String]
    attr_reader :base_dir

    # フォルダの選択に使うクラス
    #
    # @return [MediaDownloader::FolderSelector]
    attr_reader :folder_selector

    # ダウンロード先のフォルダ
    #
    # @return [String]
    attr_reader :download_to

    # ダウンロードするメディアの選択に使うクラス
    #
    # @return [MediaDownloader::TargetMediasSelector]
    attr_reader :target_medias_selector

    # ダウンロードするメディア
    #
    # @return [Array<MediaDownloader::MediaWrapper>]
    attr_reader :target_medias

    # @param [Twitter::REST::Client] client APIのコールに使うTwitterのクライアント
    # @param [String] tweet_id ダウンロード対象のツイートのID
    # @param [String] base_dir ダウンロード先のベースディレクトリ
    def initialize(client, tweet_id, base_dir)
      @client = client
      @tweet_id = tweet_id
      @base_dir = base_dir
      @cli = HighLine.new
      @tweet = @client.status(@tweet_id, tweet_mode: 'extended')

      validate_tweet(@tweet)

      @cli.say("ツイート #{build_tweet_url(tweet)} をダウンロードします")
      @folder_selector = FolderSelector.new(tweet, @base_dir)
      @download_to = @folder_selector.select
      @target_medias_selector = TargetMediasSelector.new(tweet)
      @target_medias = @target_medias_selector.select
    end

    # ファイルを保存する
    def download
      @target_medias.each do |target_media|
        fullpath = build_save_to_fullpath(target_media)
        uri = pick_uri(target_media)

        file_saver = FileSaver.new(uri, fullpath)
        file_saver.save
      end
    end

    private

    # @param [Twitter::Tweet]
    def validate_tweet(tweet)
      raise MediaDownloader::Error::AnyMediaMissingError, 'ツイートにメディアが添付されていません。' unless tweet.media?
    end

    # @param [Twitter::Tweet]
    # @return [String]
    def build_tweet_url(tweet)
      "https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}"
    end

    # ダウンロード先のファイルをフルパスで取得
    #
    # @param [MediaDownloader::MediaWrapper] media_wrapper
    # @return [String]
    def build_save_to_fullpath(media_wrapper)
      path_builder = PathBuilder.new(@download_to, media_wrapper)
      path_builder.build
    end

    # URLを抽出
    #
    # @param [MediaDownloader::MediaWrapper] media_wrapper
    # @return [Addressable::URI]
    def pick_uri(media_wrapper)
      uri_picker = MediaURIPicker.new(media_wrapper)
      uri = uri_picker.pick.dup
      transform_to_orig_size(uri) if media_wrapper.photo?

      uri
    end

    # 写真のURIをorigサイズのURIに変換
    #
    # @param [Addressable::URI] uri
    # @return [Addressable::URI]
    def transform_to_orig_size(uri)
      queries = uri.query_values.nil? ? {} : uri.query_values
      queries['name'] = 'orig'
      uri.query_values = queries
      uri
    end
  end
end

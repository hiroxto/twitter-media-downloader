# frozen_string_literal: true

require File.expand_path('utils.rb', __dir__)

module MediaDownloader
  class Downloader

    include Utils

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

    # ダウンロード先のフォルダ
    #
    # @return [String]
    attr_reader :download_to

    # ダウンロードするメディア
    #
    # @return [Array<MediaDownloader::MediaWrapper>]
    attr_reader :target_medias

    # @param [Twitter::REST::Client] client APIのコールに使うTwitterのクライアント
    # @param [String] tweet_id ダウンロード対象のツイートのID
    # @param [String] base_dir ダウンロード先のベースディレクトリ
    def initialize(client, tweet_id, base_dir)
      @client = client
      @tweet_id, target_numbers = parse_tweet_id(tweet_id)
      @base_dir = base_dir
      @cli = HighLine.new
      @tweet = @client.status(@tweet_id, tweet_mode: 'extended')

      validate_tweet(@tweet)

      @cli.say("ツイート #{build_tweet_url(tweet)} をダウンロードします")
      @folder_selector = FolderSelector.new(tweet, @base_dir)
      @download_to = @folder_selector.select
      @target_medias = gets_target_medias(target_numbers)
    end

    # ファイルを保存する
    def download
      @target_medias.each do |target_media|
        fullpath = build_save_to_fullpath(target_media)
        uri = pick_uri(target_media)
        created_at = tweet_id_to_time(@tweet_id)

        file_saver = FileSaver.new(uri, fullpath, created_at)
        file_saver.save
      end
    end

    private

    # IDと番号オプションをパースする
    #
    # @param [String] id
    # @return [Array] 0番目にStringのID, 1番目にArray<Integer>の配列
    def parse_tweet_id(id)
      parser = IDParser.new(id)
      parser.parse
    end

    # @param [Twitter::Tweet]
    def validate_tweet(tweet)
      raise MediaDownloader::Error::AnyMediaMissingError, 'ツイートにメディアが添付されていません。' unless tweet.media?
    end

    # @param [Twitter::Tweet]
    # @return [String]
    def build_tweet_url(tweet)
      "https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}"
    end

    # ダウンロード対象のメディアを取得する
    #
    # @param [Array<Integer>|NilClass]
    # @return [Array<MediaDownloader::MediaWrapper>]
    def gets_target_medias(target_numbers)
      return select_target_medias if target_numbers.nil?

      begin
        valid_target_numbers(target_numbers)
        transform_to_medias(target_numbers)
      rescue MediaDownloader::Error::OptionNumberValidatorError => e
        @cli.say("番号オプションのエラー : #{e.message}")
        @cli.say('番号オプションは使用出来ないため, 手動での選択')
        select_target_medias
      end
    end

    # 番号をバリデーションする
    #
    # @param [Array<Integer>]
    # @return [Boolean]
    def valid_target_numbers(target_numbers)
      validator = OptionNumberValidator.new(@tweet, target_numbers)
      validator.validate
    end

    # 対象のメディアを MediaWrapper へ変更する
    #
    # @param [Array<Integer>]
    # @return [Array<MediaDownloader::MediaWrapper>]
    def transform_to_medias(target_numbers)
      return all_media_transform_to_media_wrapper(@tweet) if target_numbers.include?(0)

      target_numbers.sort.map { |number| create_media_wrapper(@tweet, number - 1) }
    end

    # 手動でダウンロード対象のメディアを選択する
    #
    # @return [Array<MediaDownloader::MediaWrapper>]
    def select_target_medias
      @target_medias_selector = TargetMediasSelector.new(tweet)
      @target_medias = @target_medias_selector.select
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

    # ツイートのIDを時刻に変換する
    #
    # @param [String] id
    # @return [Time]
    def tweet_id_to_time(id)
      Time.at(((id.to_i >> 22) + 1_288_834_974_657) / 1000.0)
    end
  end
end

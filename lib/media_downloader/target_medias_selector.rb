# frozen_string_literal: true

require File.expand_path('utils.rb', __dir__)

module MediaDownloader
  class TargetMediasSelector

    include Utils

    # ダウンロード対象のツイート
    #
    # @return [Twitter::Tweet]
    attr_reader :tweet

    # ツイートのメディアのリスト
    #
    # @return [Array<Twitter::Media>]
    attr_reader :medias

    # @param [Twitter::Tweet] tweet ダウンロード対象のツイート
    def initialize(tweet)
      @tweet = tweet
      @medias = tweet.media
      @cli = HighLine.new

      validate_tweet
    end

    # @return [Array<MediaDownloader::MediaWrapper>]
    def select
      return medias_count_is_one if @tweet.media.length == 1
      return set_target_all_env if ENV['TARGET_ALL']

      select_medias
    end

    private

    def validate_tweet
      raise MediaDownloader::Error::AnyMediaMissingError, 'ツイートにメディアが添付されていません。' unless tweet.media?
    end

    # メディアの数が 1 の時, 1 のみ選択
    #
    # @return [Array<MediaDownloader::MediaWrapper>]
    def medias_count_is_one
      @cli.say("ツイート #{@tweet.id} のメディア数が1のため, 1のみ選択")
      all_media_transform_to_media_wrapper(@tweet)
    end

    # 環境変数 TARGET_ALL がセットされている時, 全選択
    #
    # @return [Array<MediaDownloader::MediaWrapper>]
    def set_target_all_env
      @cli.say('環境変数 TARGET_ALL がセットされているため, 全て選択')
      all_media_transform_to_media_wrapper(@tweet)
    end

    # @return [Array<MediaDownloader::MediaWrapper>]
    def select_medias
      targets = []
      max_range = @medias.length
      @cli.say("ダウンロードする画像を選択\n0で全選択, -1で終了")

      loop do
        number = @cli.ask("-1から#{max_range} で選択 : ", Integer) { |q| q.in = -1..max_range }

        break if number == -1

        return all_media_transform_to_media_wrapper(@tweet) if number.zero?

        index = (number - 1).to_i
        wrapper = create_media_wrapper(@tweet, index)
        targets.push(wrapper)
      end

      targets
    end
  end
end

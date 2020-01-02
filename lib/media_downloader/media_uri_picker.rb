# frozen_string_literal: true

module MediaDownloader
  class MediaURIPicker

    # @return [MediaDownloader::MediaWrapper]
    attr_reader :media_wrapper

    # @param [MediaDownloader::MediaWrapper] media_wrapper
    def initialize(media_wrapper)
      @media_wrapper = media_wrapper
      @media = @media_wrapper.media
    end

    # URLを抽出
    #
    # @return [Addressable::URI]
    def pick
      return pick_photo_url if @media_wrapper.photo?

      pick_video_url if @media_wrapper.video?
    end

    private

    # 写真のURLを抽出
    #
    # @return [Addressable::URI]
    def pick_photo_url
      @media.media_url_https
    end

    # ビデオのURLを抽出
    # 最高ビットレートのURLを取得
    #
    # @return [Addressable::URI]
    def pick_video_url
      variants = @media.video_info.variants
      max_variant = select_high_bitrate_video(variants)
      max_variant.url
    end

    # 一番ビットレートの高いビデオを取得
    #
    # @param [Array<Twitter::Variant>] variants
    # @return [Twitter::Variant]
    def select_high_bitrate_video(variants)
      variants
        .reject { |variant| variant.bitrate.nil? }
        .max_by(&:bitrate)
    end
  end
end

# frozen_string_literal: true

require 'fileutils'

module MediaDownloader
  class FileSaver

    # 保存対象のURI
    #
    # @return [Addressable::URI]
    attr_reader :uri

    # URIの保存先
    #
    # @return [String]
    attr_reader :save_to

    # @param [Addressable::URI] uri 保存対象のURI
    # @param [String] save_to URIの保存先
    def initialize(uri, save_to)
      @uri = uri
      @save_to = save_to
      @cli = HighLine.new
    end

    # URIをファイルへ保存する
    #
    # @return [Integer] ファイルへ書き込んだ長さ
    def save
      if exist?
        status = already_file_exist
        return 0 unless status
      end

      response = Faraday.get(@uri.to_s)

      raise FileSaverError, 'ダウンロード時にエラーが発生しました' unless response.success?

      @cli.say("#{@uri} を #{@save_to} へ保存します.")
      length = write_to_file(response)
      @cli.say("保存が完了しました.\n\n")

      length
    end

    private

    # 保存先のファイルが存在するか確認
    #
    # @return [Boolean]
    def exist?
      File.exist?(@save_to)
    end

    # ファイルが既に存在した場合の処理
    #
    # @return [Boolean] ファイルをリネームした場合true, リネームしなかった場合false
    def already_file_exist
      dirname = File.dirname(@save_to)
      basename = File.basename(@save_to)
      time = Time.now.to_i
      rename_to = "#{dirname}/backup-#{time}-#{basename}"

      answer = @cli.agree("ファイル #{@save_to} は既に存在します.\n#{rename_to} へリネームしますか? (y)es or (n)o")

      unless answer
        @cli.say("ファイル #{@save_to} をリネームしません. ダウンロードをスキップします.")
        return false
      end

      @cli.say("ファイル #{@save_to} を #{rename_to} へリネームします.")
      FileUtils.move(@save_to)

      true
    end

    # 保存先のディレクトリを作成する
    def create_save_to_dir
      FileUtils.mkdir_p(File.dirname(@save_to))
    end

    # レスポンスをファイルへ保存
    #
    # @param [Faraday::Response] response
    # @return [Integer]
    def write_to_file(response)
      create_save_to_dir
      File.write(@save_to, response.body)
    end
  end
end

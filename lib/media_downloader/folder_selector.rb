# frozen_string_literal: true

module MediaDownloader
  class FolderSelector

    # ダウンロード対象のツイート
    #
    # @return [Twitter::Tweet]
    attr_reader :tweet

    # ダウンロード先のベースディレクトリ
    #
    # @return [String]
    attr_reader :base_dir

    # @param [Twitter::Tweet] tweet ダウンロード対象のツイート
    # @param [String] base_dir ダウンロード先のベースディレクトリ
    def initialize(tweet, base_dir)
      @tweet = tweet
      @base_dir = base_dir
      @cli = HighLine.new
    end

    # ダウンロード先のフォルダを選択する
    #
    # @return [String] ダウンロード先のフォルダのフルパス
    def select
      folder = if ENV['SAVE_FOLDER'] && File.exist?(File.join(@base_dir, ENV['SAVE_FOLDER']))
                 @cli.say("環境変数 SAVE_FOLDER より #{ENV['SAVE_FOLDER']} を保存先に設定")
                 ENV['SAVE_FOLDER']
               else
                 choose_download_to_folder
               end

      File.join(@base_dir, folder)
    end

    private

    # ダウンロード先のフォルダを選択する
    #
    # @return [String] ダウンロード先のフォルダ名
    def choose_download_to_folder
      @cli.choose do |menu|
        menu.prompt = "ダウンロードするフォルダを選択 (base : #{@base_dir})"
        folder_list.each do |folder|
          menu.choice(folder) { folder }
        end
      end
    end

    # ダウンロード先のフォルダの選択肢を返す
    #
    # @return [Array<String>] フォルダ名
    def folder_list
      Dir
        .glob(File.join(@base_dir, '/*'))
        .select { |path| File.directory?(path) }
        .map { |dir| File.basename(dir) }
    end
  end
end

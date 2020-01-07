# twitter-media-downloader

Twitterの画像,動画などをダウンロードするツール

`ruby downloader.rb id:number`

全数ダウンロード

`12345:0`

番号指定

`12345:1 12345:1,3`

使用できる環境変数

|環境変数|説明|
|:---:|:---:|
|`SAVE_FOLDER`|ダウンロード先のフォルダ名|
|`TARGET_ALL`|標準で全数ダウンロード。セットされた上で番号オプションがあると番号オプションが優先される|

`SAVE_FOLDER=test ruby downloader.rb id`
`TARGET_ALL=true SAVE_FOLDER="test" ruby downloader.rb id`

## License

MIT License
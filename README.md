# RasMENU
RaSCSIでイメージをマウントするシェルスクリプトです。

## 特徴
raspi-configのような画面でRaSCSIのイメージファイルの操作を行うことが出来ます。

## 使い方
### シェルスクリプトを特定のディレクトリに保存しパーミッションを設定
  chmod 775 RaMENU.sh

### 起動オプション(フルパスで指定)
  RaMENU.sh /home/pi/image_dir/

### デフォルトのイメージファイル保存場所を指定(10行目を修正)
  IMAGE_PATH="/home/pi/hdd/"

## 連絡
改善アイディアがありましたら、twitter:@taneken2000 までお願いします。

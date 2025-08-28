#!/bin/bash
# scripts/entrypoint.sh

# ==========================================================
# ▼▼▼ ここからが追加箇所です ▼▼▼
# ==========================================================
# /app/plugin-src が空の場合、テンプレートをコピーする
# `ls -A` は隠しファイル以外のリストを返すので、空かどうかをチェックできる
if [ -d "/app/plugin-src" ] && [ ! "$(ls -A /app/plugin-src)" ]; then
  echo ">>> 'plugin-src' is empty. Copying plugin template..."
  # cp -r /app/plugin-template/. は、plugin-templateの中身だけをコピーするコマンド
  cp -r /app/plugin-template/. /app/plugin-src/
fi
# ==========================================================
# ▲▲▲ 追加箇所はここまで ▲▲▲
# ==========================================================


# /app/plugin-src ディレクトリと pom.xml が存在する場合のみビルドを実行します
if [ -d "/app/plugin-src" ] && [ -f "/app/plugin-src/pom.xml" ]; then
  echo ">>> Mavenプロジェクトを検出しました。プラグインをビルドします..."
  
  # Mavenでプラグインをビルドします
  mvn -f /app/plugin-src/pom.xml clean package
  
  # ビルドの成功を確認
  if [ $? -eq 0 ]; then
    echo ">>> ビルドに成功しました。"
    # pluginsディレクトリが存在しない場合は作成
    mkdir -p /app/plugins
    # ビルドされたjarファイルをpluginsディレクトリにコピーします
    find /app/plugin-src/target -name "*.jar" -exec cp {} /app/plugins/ \;
    echo ">>> プラグインを'plugins'フォルダにコピーしました。"
  else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo ">>> プラグインのビルドに失敗しました。Mavenのログを確認してください。"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  fi
else
  echo ">>> プラグインのソースが見つかりません。ビルドをスキップします。"
fi

# 'paper'で始まるjarファイル名を変数に格納
SERVER_JAR=$(find . -maxdepth 1 -name "paper*.jar")

# jarファイルが見つからない場合はエラーで終了
if [ -z "$SERVER_JAR" ]; then
    echo "!! エラー: サーバーのjarファイルが見つかりません。"
    exit 1
fi

echo ">>> ${SERVER_JAR} を使用してPaperMCサーバーを起動します..."

# 変数に格納したjarファイル名でサーバーを起動します
java -Xms2G -Xmx2G -jar "${SERVER_JAR}" --nogui

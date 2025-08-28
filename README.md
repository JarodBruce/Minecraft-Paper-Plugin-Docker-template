# Minecraft-Paper-Plugin-Docker-template (1.16.5)

これは、Minecraft Paper サーバー (v1.16.5) で動作するプラグインを開発するための、Docker を使用した開発環境です。
`docker-compose up`コマンド一つで、プラグインのビルドからサーバーの起動までを自動で行います。

---

## 📝 概要

この環境は、プラグイン開発における面倒な環境構築の手間を省き、すぐにコーディングを開始できるように設計されています。

- **自動ビルド**: コンテナ起動時に、`plugin-src`内の Maven プロジェクトを自動でビルドします。
- **テンプレート生成**: `plugin-src`が空の場合、最小構成のプラグインテンプレートを自動で生成します。
- **ホットリロード**: コードを編集した後に`docker-compose restart`を実行するだけで、変更がサーバーに反映されます。
- **データ永続化**: ワールドデータやプラグイン、ログなどはホスト PC の`server-data`フォルダに保存され、コンテナを停止しても消えません。

---

## 🚀 始め方

### 必要なもの

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/) (Docker Desktop には同梱されています)

### プラグイン設定のカスタマイズ

プラグインの名前や製作者情報は、`.env`ファイルで自由に変更できます。

1. **設定ファイルの編集**
   プロジェクトルートの`.env`ファイルを編集します：

   ```env
   PLUGIN_NAME=YourPluginName
   PLUGIN_AUTHOR=com.yourname
   PLUGIN_VERSION=1.0-SNAPSHOT
   PLUGIN_MAIN_CLASS=YourMainClass
   ```

2. **設定例**
   ```env
   PLUGIN_NAME=DeathMode
   PLUGIN_AUTHOR=com.vreba
   PLUGIN_VERSION=2.0-SNAPSHOT
   PLUGIN_MAIN_CLASS=DeathModePlugin
   ```

### ディレクトリ構成

```
.
├── docker-compose.yml  # Docker Compose設定ファイル
├── Dockerfile          # Dockerイメージの設計図
├── .env               # プラグイン設定ファイル
├── plugin-src/         # ★ここにプラグインのソースコードを配置します
├── scripts/
│   └── entrypoint.sh   # コンテナ起動時に実行されるスクリプト
└── server-data/        # サーバーデータが永続化されるフォルダ
```

### 手順

1. **初回起動**
   ターミナルでこのプロジェクトのルートディレクトリに移動し、以下のコマンドを実行します。

   ```bash
   docker-compose up --build
   ```

   初回起動時、`plugin-src`フォルダが空であれば、自動でプラグインのテンプレートが生成されます。ビルドが成功すると、Minecraft サーバーが起動します。

2. **サーバーへの接続**

   - Minecraft Java 版 (バージョン **1.16.5**) を起動します。
   - マルチプレイからサーバーを追加し、アドレスに `localhost` を入力して接続します。

3. **開発**

   - ホスト PC の`plugin-src`フォルダ内のソースコードを、お好みのエディタ（VSCode など）で編集します。
   - コードを編集したら、ターミナルで以下のコマンドを実行してコンテナを再起動します。プラグインが自動で再ビルドされ、サーバーに反映されます。
     ```bash
     docker-compose restart
     ```

4. **停止**
   サーバーを停止するには、ターミナルで`Ctrl + C`を押すか、別のターミナルから以下のコマンドを実行します。
   ```bash
   docker-compose down
   ```
   ワールドデータなどを完全に削除したい場合は、`-v`オプションを付けてください。
   ```bash
   docker-compose down -v
   ```

---

## ✨ VSCode での開発 (推奨)

VSCode の拡張機能「**Dev Containers**」を使用すると、コンテナ内に直接接続して開発ができ、非常に快適です。

1.  VSCode に「Dev Containers」拡張機能をインストールします。
2.  コンテナが起動している状態で、VSCode の左下にある緑色のアイコン `><` をクリックします。
3.  「Attach to Running Container...」を選択し、「`/paper-dev-server-1.16.5`」を選びます。
4.  新しく開いた VSCode ウィンドウで、`/app/plugin-src`フォルダを開けば、コンテナ内で直接コーディングとデバッグができます。

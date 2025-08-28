# Dockerfile
# ベースイメージとしてMavenとOpenJDK 11が含まれるものを選択します
FROM maven:3.8.4-openjdk-11

# 作業ディレクトリを設定
WORKDIR /app

# wgetとjq(JSONパーサー)をインストール
RUN apt-get update && apt-get install -y wget jq && rm -rf /var/lib/apt/lists/*

# PaperMCサーバー(v1.16.5, build 794)をダウンロードします
ARG PAPER_VERSION=1.16.5
ARG PAPER_BUILD=794

# プラグイン設定用の変数（.envファイルから受け取る）
ARG PLUGIN_NAME
ARG PLUGIN_AUTHOR
ARG PLUGIN_VERSION
ARG PLUGIN_MAIN_CLASS

RUN wget -O paper.jar https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}/builds/${PAPER_BUILD}/downloads/paper-${PAPER_VERSION}-${PAPER_BUILD}.jar

# EULA(サーバー利用規約)に同意するファイルを作成します
RUN echo "eula=true" > eula.txt

# プラグイン名を小文字に変換
RUN PLUGIN_NAME_LOWER=$(echo ${PLUGIN_NAME} | tr '[:upper:]' '[:lower:]') && \
    echo "Plugin name lower: ${PLUGIN_NAME_LOWER}"

# テンプレート用のディレクトリ構造を作成
RUN PLUGIN_NAME_LOWER=$(echo ${PLUGIN_NAME} | tr '[:upper:]' '[:lower:]') && \
    mkdir -p /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER} && \
    mkdir -p /app/plugin-template/src/main/resources

# pom.xml の作成 (変数を適切に展開)
RUN PLUGIN_NAME_LOWER=$(echo ${PLUGIN_NAME} | tr '[:upper:]' '[:lower:]') && \
    printf '<?xml version="1.0" encoding="UTF-8"?>\n<project xmlns="http://maven.apache.org/POM/4.0.0"\n         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\n         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">\n    <modelVersion>4.0.0</modelVersion>\n    \n    <groupId>%s</groupId>\n    <artifactId>%s</artifactId>\n    <version>%s</version>\n    <packaging>jar</packaging>\n    \n    <properties>\n        <java.version>11</java.version>\n        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>\n    </properties>\n    \n    <repositories>\n        <repository>\n            <id>spigotmc-repo</id>\n            <url>https://hub.spigotmc.org/nexus/content/repositories/snapshots/</url>\n        </repository>\n    </repositories>\n    \n    <dependencies>\n        <dependency>\n            <groupId>org.spigotmc</groupId>\n            <artifactId>spigot-api</artifactId>\n            <version>1.16.5-R0.1-SNAPSHOT</version>\n            <scope>provided</scope>\n        </dependency>\n    </dependencies>\n    \n    <build>\n        <defaultGoal>clean package</defaultGoal>\n        <plugins>\n            <plugin>\n                <groupId>org.apache.maven.plugins</groupId>\n                <artifactId>maven-compiler-plugin</artifactId>\n                <version>3.8.1</version>\n                <configuration>\n                    <source>${java.version}</source>\n                    <target>${java.version}</target>\n                </configuration>\n            </plugin>\n        </plugins>\n    </build>\n</project>' "${PLUGIN_AUTHOR}" "${PLUGIN_NAME_LOWER}" "${PLUGIN_VERSION}" > /app/plugin-template/pom.xml

# plugin.yml の作成
RUN PLUGIN_NAME_LOWER=$(echo ${PLUGIN_NAME} | tr '[:upper:]' '[:lower:]') && \
    echo "name: ${PLUGIN_NAME}" > /app/plugin-template/src/main/resources/plugin.yml && \
    echo "version: ${PLUGIN_VERSION}" >> /app/plugin-template/src/main/resources/plugin.yml && \
    echo "main: ${PLUGIN_AUTHOR}.${PLUGIN_NAME_LOWER}.${PLUGIN_MAIN_CLASS}" >> /app/plugin-template/src/main/resources/plugin.yml && \
    echo "api-version: 1.16" >> /app/plugin-template/src/main/resources/plugin.yml

# Javaクラスファイルの作成
RUN PLUGIN_NAME_LOWER=$(echo ${PLUGIN_NAME} | tr '[:upper:]' '[:lower:]') && \
    echo "package ${PLUGIN_AUTHOR}.${PLUGIN_NAME_LOWER};" > /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "import org.bukkit.plugin.java.JavaPlugin;" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "public final class ${PLUGIN_MAIN_CLASS} extends JavaPlugin {" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "    @Override" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "    public void onEnable() {" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "        getLogger().info(\"${PLUGIN_NAME} Template Enabled!\");" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "    }" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "    @Override" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "    public void onDisable() {" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "        getLogger().info(\"${PLUGIN_NAME} Template Disabled!\");" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "    }" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java && \
    echo "}" >> /app/plugin-template/src/main/java/${PLUGIN_AUTHOR}/${PLUGIN_NAME_LOWER}/${PLUGIN_MAIN_CLASS}.java

# ポートを開放
EXPOSE 25565
EXPOSE 5005

# 起動スクリプトをコンテナ内にコピーし、実行権限を付与します
COPY ./scripts/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# コンテナ起動時にこのスクリプトが実行されます
ENTRYPOINT ["/app/entrypoint.sh"]


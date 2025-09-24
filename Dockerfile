FROM golang:1.23.0 AS build
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN mkdir build
# tesla-http-proxy をビルド
RUN go build -o ./build/tesla-http-proxy ./cmd/tesla-http-proxy

# 実行ステージ
FROM gcr.io/distroless/base-debian12:nonroot AS runtime

# ビルドしたバイナリをコピー
COPY --from=build /app/build/tesla-http-proxy /usr/local/bin/tesla-http-proxy

# バイナリを ENTRYPOINT に指定
ENTRYPOINT ["/usr/local/bin/tesla-http-proxy"]

# CMD は TESLA_KEY_FILE を使うため --key-file 指定不要
# -host 0.0.0.0 で Render からアクセス可能にする
# -port は任意の固定値か、Render の環境変数 $PORT を使用
CMD ["-port", "10000", "-host", "0.0.0.0", "-verbose"]

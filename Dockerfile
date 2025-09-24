FROM golang:1.23.0 AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN mkdir build
# vehicle-command バイナリをビルド
RUN go build -o ./build/tesla-http-proxy ./cmd/tesla-http-proxy

FROM gcr.io/distroless/base-debian12:nonroot AS runtime

# ビルドしたバイナリをコピー
COPY --from=build /app/build/tesla-http-proxy /usr/local/bin/tesla-http-proxy

# 実行バイナリをエントリポイントに指定
ENTRYPOINT ["/usr/local/bin/tesla-http-proxy"]

CMD ["--key-file=/etc/secrets/private.pem", "--endpoint=https://fleet-api.prd.na.vn.cloud.tesla.com", "--issuer=https://fleet-api.prd.na.vn.cloud.tesla.com"]

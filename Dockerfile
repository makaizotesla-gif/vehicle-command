FROM golang:1.23.0 AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN mkdir build
# vehicle-command バイナリをビルド
RUN go build -o ./build/vehicle-command ./cmd/vehicle-command

FROM gcr.io/distroless/base-debian12:nonroot AS runtime

# ビルドしたバイナリをコピー
COPY --from=build /app/build/vehicle-command /usr/local/bin/vehicle-command

# vehicle-command を直接エントリポイントに設定
ENTRYPOINT ["/usr/local/bin/vehicle-command"]

CMD ["--key-file=/etc/secrets/private.pem",
     "--endpoint=https://fleet-api.prd.na.vn.cloud.tesla.com",
     "--issuer=https://fleet-api.prd.na.vn.cloud.tesla.com"]

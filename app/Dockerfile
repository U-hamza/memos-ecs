# FrontEnd builder stage
FROM node:24 AS frontend-builder

WORKDIR /app

COPY . .

WORKDIR /app/web

RUN npm install -g pnpm

RUN pnpm install

RUN pnpm release



# BackEnd builder stage
FROM golang:1.26.2 AS backend-builder

WORKDIR /app

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

COPY --from=frontend-builder \
    /app/server/router/frontend/dist \
    /app/server/router/frontend/dist

RUN CGO_ENABLED=0 GOOS=linux \
    go build \
    -trimpath \
    -ldflags="-s -w -extldflags '-static'" \
    -tags netgo,osusergo \
    -o build/memos \
    ./cmd/memos


#Runtime
FROM alpine:3.22

WORKDIR /app

COPY --from=backend-builder /app/build/memos .

RUN adduser -D memos
RUN chown -R memos:memos /app

USER memos

EXPOSE 8081

CMD ["./memos"]
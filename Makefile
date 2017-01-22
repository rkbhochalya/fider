BUILD_TIME="$(shell date +"%Y.%m.%d.%H%M%S")"

test:
	go test $$(go list ./... | grep -v /vendor/) -cover

lint:
	golint -set_exit_status

setup:
	go get -u github.com/kardianos/govendor
	go get -u github.com/golang/lint/golint
	govendor sync

ci: lint test build

migrate:
ifeq ($(ENV), local)
	migrate -url postgres://wchy:wchy-pw@localhost:5555/wchy?sslmode=disable -path ./migrations up
else
	migrate -url ${DATABASE_URL} -path ./migrations up
endif

build:
	go build -ldflags='-X main.buildtime=${BUILD_TIME}'

watch:
	gin --buildArgs "-ldflags='-X main.buildtime=${BUILD_TIME}'"

run:
	wchy-api

.DEFAULT_GOAL := build
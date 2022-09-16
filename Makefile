SHELL := /bin/bash

MODULE_NAME = $(shell go list -m)
VERSION = $(shell git describe --tags 2>/dev/null | sed 's/^v//')
RELEASE_LDFLAGS := -s -w
WINDOWS_GUI_LDFLAG := -H windowsgui

.PHONY: build
# If GOOS is windows or if on Windows and building with no GOOS
build: LDFLAGS += $(if $(or $(findstring windows,$(GOOS)),$(and $(findstring Windows_NT,$(OS)),!$(value $(GOOS)))),$(WINDOWS_GUI_LDFLAG))
# build: LDFLAGS += -X 'main.version=$(VERSION)'
build: OUTPUT = $(if $(EXE_NAME),$(EXE_NAME),$(MODULE_NAME))$(if $(SUFFIX),_$(SUFFIX),)$(EXT)
build:
	go build$(if $(LDFLAGS), -ldflags='$(strip $(LDFLAGS))',) -trimpath -o "$(OUTPUT)"

.PHONY: release
release: LDFLAGS += $(RELEASE_LDFLAGS)
release: build

.PHONY: release-all
release-all:
	$(MAKE) wasm; \
	$(MAKE) windows-amd64; \
	$(MAKE) windows-i386; \
	# macOS and Linux depend on cgo and can't easily be cross-compiled: https://github.com/golang/go/issues/18296
	# $(MAKE) darwin-amd64; \
	# $(MAKE) darwin-i386; \
	# $(MAKE) darwin-arm64; \
	# $(MAKE) linux-amd64; \
	# $(MAKE) linux-i386;

.PHONY: wasm-debug
wasm-debug: export GOOS = js
wasm-debug: export GOARCH = wasm
wasm-debug: EXT := .wasm
wasm-debug: build

.PHONY: wasm
wasm: LDFLAGS += $(RELEASE_LDFLAGS)
wasm: wasm-debug

.PHONY: windows-amd64
windows-amd64: export GOOS = windows
windows-amd64: export GOARCH = $(if $(ARCH_OVERRIDE),$(ARCH_OVERRIDE),amd64)
windows-amd64: SUFFIX = $(if $(SUFFIX_OVERRIDE),$(SUFFIX_OVERRIDE),windows_amd64)
windows-amd64: EXT = .exe
windows-amd64: release

.PHONY: windows-i386
windows-i386: ARCH_OVERRIDE = 386
windows-i386: SUFFIX_OVERRIDE = windows
windows-i386: windows-amd64

.PHONY: darwin-amd64
darwin-amd64: export GOOS = darwin
darwin-amd64: export GOARCH = $(if $(ARCH_OVERRIDE),$(ARCH_OVERRIDE),amd64)
darwin-amd64: SUFFIX = $(if $(SUFFIX_OVERRIDE),$(SUFFIX_OVERRIDE),macos_amd64)
darwin-amd64: release

.PHONY: darwin-i386
darwin-i386: ARCH_OVERRIDE = 386
darwin-i386: SUFFIX_OVERRIDE = macos
darwin-i386: darwin-amd64

.PHONY: darwin-arm64
darwin-arm64: ARCH_OVERRIDE = arm64
darwin-arm64: SUFFIX_OVERRIDE = macos_arm64
darwin-arm64: darwin-amd64

.PHONY: linux-amd64
linux-amd64: export GOOS = linux
linux-amd64: export GOARCH = $(if $(ARCH_OVERRIDE),$(ARCH_OVERRIDE),amd64)
linux-amd64: SUFFIX = $(if $(SUFFIX_OVERRIDE),$(SUFFIX_OVERRIDE),linux_amd64)
linux-amd64: release

.PHONY: linux-i386
linux-i386: ARCH_OVERRIDE = 386
linux-i386: SUFFIX_OVERRIDE = linux
linux-i386: linux-amd64

.PHONY: mobile-android-debug
# mobile-android-debug: LDFLAGS += -X 'main.version=$(VERSION)'
mobile-android-debug:
	ebitenmobile bind$(if $(LDFLAGS), -ldflags='$(LDFLAGS)',) -target android -androidapi 21 -javapkg com.example.game -o ./mobile/android/mobile/mobile.aar ./mobile

.PHONY: mobile-android-release
mobile-android-release: LDFLAGS += $(RELEASE_LDFLAGS)
mobile-android-release: mobile-android-debug

.PHONY: mobile-ios-debug
# mobile-ios-debug: LDFLAGS += -X 'main.version=$(VERSION)'
mobile-ios-debug:
	ebitenmobile bind$(if $(LDFLAGS), -ldflags='$(LDFLAGS)',) -target ios -o ./mobile/ios/Mobile.xcframework ./mobile

.PHONY: mobile-ios-release
mobile-ios-release: LDFLAGS += $(RELEASE_LDFLAGS)
mobile-ios-release: mobile-ios-debug

.PHONY: android
android: mobile-android-release
	cd ./mobile/android && ./gradlew assembleRelease
	@echo APK generated under ./mobile/android/app/build/outputs/apk/release/app-release-unsigned.apk

.PHONY: android-debug
android-debug: mobile-android-debug
	cd ./mobile/android && ./gradlew assembleDebug
	@echo APK generated under ./mobile/android/app/build/outputs/apk/debug/app-debug.apk

.PHONY: ios
ios: mobile-ios-release
	cd ./mobile/ios && xcodebuild -scheme Game build

.PHONY: test
test:
	@go test -v ./...

.PHONY: bench
bench:
	@go test -v -bench=. ./...

.PHONY: dep
dep:
	@go mod download

.PHONY: lint
lint:
	@golangci-lint run

.PHONY: serve
serve: PORT = 8080
serve:
	@wasmserve -h >/dev/null 2>&1 || go install github.com/hajimehoshi/wasmserve@latest
	@echo "Listening on http://localhost:$(PORT)/"
	@wasmserve -http=":$(PORT)" ./

.PHONY: doc
doc: PORT = 6060
doc:
	@godoc -h >/dev/null 2>&1 || go install golang.org/x/tools/cmd/godoc@v0.1.12
	@echo "Documentation is available at http://localhost:$(PORT)/pkg/$(MODULE_NAME)/?m=all"
	@godoc -http=":$(PORT)" -notes="BUG|TODO" >/dev/null

.PHONY: clean
clean:
	@go clean
	@rm -f "$(MODULE_NAME)" "$(MODULE_NAME).exe" "$(MODULE_NAME).wasm"

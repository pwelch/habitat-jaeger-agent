pkg_name=jaeger-agent
pkg_origin=pwelch
pkg_version="1.2.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Apache-2.0")
# Git clone is used instead
pkg_source="https://github.com/jaegertracing/jaeger/archive/v${pkg_version}.tar.gz"
pkg_shasum="1444f1bc08cae87a1c2df02c7ec33ce13c4ae17ebc45c6ee7417633b98c6661c"
pkg_upstream_url="http://jaegertracing.io/"
pkg_description="Jaeger Agent receives tracing information submitted by applications via Jaeger client libraries."
pkg_filename="v${pkg_version}.tar.gz"
pkg_build_deps=(
  core/scaffolding-go
  core/git
)
pkg_deps=(
  core/bash
)
pkg_bin_dirs=(bin)
pkg_svc_user=root
pkg_svc_group=root
pkg_exports=(
  [port-http_server]=ports.http_server-host-port
  [port-zipkin_compact_server]=ports.processor_zipkin_compact-server-host-port
  [port-jaeger_compact_server]=ports.processor_jaeger_compact-server-host-port
  [port-jaeger_binary_server]=ports.processor_jaeger_binary-server-host-port
)
pkg_exposes=(
  port-http_server
  port-zipkin_compact_server
  port-jaeger_compact_server
  port-jaeger_binary_server
)
pkg_binds_optional=(
  [collector]="host:port"
)

go_path="${HAB_CACHE_SRC_PATH}/go"
jaeger_git_repo="https://github.com/jaegertracing/jaeger.git"

do_before() {
  # Clean up from previous build
  rm -rf "$go_path"

  export GOPATH=$go_path
  mkdir -p "$GOPATH"
  export GOBIN=$GOPATH/bin
  export PATH=$GOBIN:$PATH
  export jaeger_local_path="$GOPATH/src/github.com/jaegertracing"
}

do_download() {
  build_line "Overriding Download process"
  return 0
}

do_verify() {
  build_line "Overriding Verify process"
  return 0
}

do_unpack() {
  mkdir -p "${jaeger_local_path}"
  pushd "${jaeger_local_path}"
  git clone --branch v${pkg_version} ${jaeger_git_repo}
  popd
  return $?
}

do_prepare() {
  go get github.com/Masterminds/glide
  go install github.com/Masterminds/glide
  return $?
}

do_build() {
  build_line "Overriding Build: building jaeger-agent"
  pushd "${jaeger_local_path}/jaeger"
  PATH=$PATH:$GOPATH/bin glide install
  CGO_ENABLED=0 GOOS=linux installsuffix=cgo \
    go build -o ./cmd/agent/jaeger-agent ./cmd/agent/main.go
  popd >/dev/null
}

do_install() {
  build_line "Overriding Install: installing generated binaries"
  cp -r "${jaeger_local_path}/jaeger/cmd/agent/jaeger-agent" "${pkg_prefix}/bin"
}

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
pkg_bin_dirs=(bin)
pkg_svc_user=root
pkg_svc_group=root
pkg_exports=(
  [port-jaeger_agent]=ports.jaeger_agent
)
pkg_exposes=(port-jaeger_agent)
# pkg_binds=(
#   [database]="port host"
# )
# pkg_binds_optional=(
#   [storage]="port host"
# )
jaeger_pkg_dir="$HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}"
jaeger_build_dir="${jaeger_pkg_dir}/src/${pkg_source}"

# do_prepare() {
#  export GOPATH=$HAB_CACHE_SRC_PATH/$pkg_dirname
# }

do_verify() {
  return 0
}

do_unpack() {
  mkdir -p "$jaeger_pkg_dir/src/github.com/jaeger"
  pushd "$jaeger_pkg_dir/src/github.com/jaeger"
  git clone --branch v${pkg_version} https://github.com/jaegertracing/jaeger.git
  popd
}

do_build() {
  export GOPATH=/root/go
  pushd "${jaeger_pkg_dir}/src/github.com/jaeger/jaeger"

  go get github.com/Masterminds/glide
  go install github.com/Masterminds/glide
  PATH=$PATH:$GOPATH/bin glide install

  CGO_ENABLED=0 GOOS=linux installsuffix=cgo go build -o ./cmd/agent/agent-linux ./cmd/agent/main.go

  popd
  return $?
}

do_install() {
	return 0
}

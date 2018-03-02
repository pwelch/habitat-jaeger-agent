pkg_name=jaeger-agent
pkg_origin=pwelch
pkg_version="1.2.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Apache-2.0")
pkg_source="https://github.com/jaegertracing/jaeger/archive/v1.2.0.zip"
pkg_upstream_url="http://jaegertracing.io/"
# pkg_description="Some description."
pkg_filename="v1.2.0.zip"
pkg_shasum="4a1429f797829c0e10be9b3f66f25c17e681d586a5be5c1dc78ce3b5b6d7d8d8"
# pkg_deps=(core/glibc)
pkg_build_deps=(core/scaffolding-go core/unzip core/git)
# pkg_lib_dirs=(lib)
# pkg_include_dirs=(include)
# pkg_bin_dirs=(bin)
# pkg_pconfig_dirs=(lib/pconfig)
# pkg_svc_run="haproxy -f $pkg_svc_config_path/haproxy.conf"
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
# pkg_interpreters=(bin/bash)
# pkg_svc_user="hab"
# pkg_svc_group="$pkg_svc_user"

do_unpack() {
  cd "${HAB_CACHE_SRC_PATH}" || exit
  unzip ${pkg_filename} -d "${pkg_name}-${pkg_version}"
}

do_build() {
  # https://github.com/jaegertracing/jaeger/blob/v1.2.0/Makefile#L141
  # TODO: Add version info at build time
  # cd "${HAB_CACHE_SRC_PATH}/${pkg_name}-${pkg_version}/jaeger-${pkg_version}" || exit

  go get github.com/jaegertracing/jaeger

  # Temp
  cd /root/go/src/github.com/jaegertracing/jaeger || exit

  go get github.com/Masterminds/glide
  go install github.com/Masterminds/glide
  export GOPATH=/root/go
  PATH=$PATH:$GOPATH/bin glide install 

  CGO_ENABLED=0 GOOS=linux installsuffix=cgo go build -o ./cmd/agent/agent-linux ./cmd/agent/main.go
  return 0
}

do_install() {
	return 0
}

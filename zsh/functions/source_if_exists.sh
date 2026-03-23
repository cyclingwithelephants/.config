source_if_exists() {
	source_path=$1
	if test -f "${source_path}"; then
		source "${source_path}"
	fi
}

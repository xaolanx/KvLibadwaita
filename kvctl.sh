#!/usr/bin/env bash

# INIT GLOBAL VARIABLES:
_VERSION="2.1"
_SCRIPT_NAME="$0"
_THEME_SRC_PATH="src"
_SYSTEM_CONF_PATH="/usr/share/Kvantum"
_USER_CONF_PATH="$HOME/.config/Kvantum"
_NO_ASK=false

help() {
	local script
	script=$_SCRIPT_NAME
	cat <<EOF
Usage: ${script} [options]

Options:
  --no-ask    | -na  don't ask for confirmation
  --build     | -b   {theme_name}
  --install   | -i   {theme_name}
  --uninstall | -u   uninstall theme
  --version   | -v   print version
  --help      | -h   print this message and exit

Examples:
  ${script} --build nord     the nord theme will be built
  ${script} --install        the default theme will be installed
  ${script} --install nord   the nord theme will be installed
  ${script} --install custom ~/my-base16.json
  ${script} --uninstall      the default theme will be uninstalled
EOF
}


abort() {
	local abort_message="$1"
	echo "${abort_message}"
	exit 1
}


continue_handler() {
	local message="$1"
	local abort_message="$2"
	local confirm

	echo "${message}"
	read -r -p "Continue? (Y/N): " confirm \
		&& [[ ${confirm} == [yY] || ${confirm} == [yY][eE][sS] ]] || abort "${abort_message}"
}


build() {
	local theme="$1"
	local custom_theme_path="$2"
	local abort_message="Installation aborted"

	if [[ "${theme}" == "custom" ]]; then
		echo "${custom_theme_path}"
		if ! python3 "gradience/gradience.py" "--custom" "${custom_theme_path}"; then
			abort "${abort_message}"
		fi
	else
		if ! python3 "gradience/gradience.py" "--theme" "${theme}"; then
			abort "${abort_message}"
		fi
	fi
}


install() {
	local theme="$1"
	local custom_theme_path="$2"
	local src_path="${_THEME_SRC_PATH}"  # default source path
	local dst_path="${_USER_CONF_PATH}"  # default destination path
	local abort_message="Installation aborted"
	local success_message="Installation complete"
	local gradience_message=""

	if [[ -n "${theme}" && ! "${theme}" == "adwaita" ]]; then
		src_path="gradience/result"
		gradience_message="with gradience ${theme} "
	else
		theme="adwaita"
	fi

	if [[ "$EUID" -eq 0 ]]; then
		dst_path="${_SYSTEM_CONF_PATH}"
	fi

	if ! $_NO_ASK; then
		local msg="Install KvLibadwaita ${gradience_message}in ${dst_path}?"
		continue_handler "${msg}" "${abort_message}"
	fi

	if [[ "${theme}" == "adwaita" ]]; then
		cp -r "${src_path}"/* "${dst_path}"
	else
		build "${theme}" "${custom_theme_path}"
		cp -r "${src_path}"/* "${dst_path}"
	fi
	echo "${success_message}"
}


uninstall() {
	local dst_path="${_USER_CONF_PATH}"  # default destination path
	local abort_message="Uninstallation aborted"
	local success_message="Uninstallation complete"

	if [[ "$EUID" -eq 0 ]]; then
		dst_path="${_SYSTEM_CONF_PATH}"
	fi

	if ! $_NO_ASK; then
		local msg="Uninstall KvLibadwaita from ${dst_path}?"
		continue_handler "${msg}" "${abort_message}"
	fi

	rm -r "${dst_path}"/KvLibadwaita
	echo "${success_message}"
}


# Parse user options
optparser() {
	# count user-passed options:
	local count_options=$#
	# run help if empty and exit:
	if [[ count_options -eq 0 ]]; then
		# help
		help
		exit 2
	fi
	# parse opts:
	while [[ -n "$1" ]]; do
		case "$1" in
			--no-ask|-na)
				_NO_ASK=true
				;;
			--build|-b)
				shift
				build "$1" "$2"
				exit 0
				;;
			--install|-i)
				shift
				install "$1" "$2"
				exit 0
				;;
			--uninstall|-u)
				uninstall
				;;
			--help|-h)
				help
				exit 0
				;;
			--version|-v)
				echo "${_VERSION}"
				exit 0
				;;
			*)
				help
				exit 1
				;;
		esac
		shift
	done
}


main() {
	optparser "$@"
}


# RUN IT:
main "$@"

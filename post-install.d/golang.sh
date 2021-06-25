# bash script to be sourced from popOS_setup.sh

# Add Golang configs every user's profile
[ ! -f /etc/profile.d/golang.sh ] && \
	printf "# Configure custom Golang folders

[ -d /usr/local/go/bin ] && \\
	export PATH=\"/usr/local/go/bin:\$PATH\"

GOPATH=\"\$HOME/.local/golang\"
PATH=\"\$GOPATH/bin:\$PATH\"

export GOPATH PATH\n" | sudo tee /etc/profile.d/golang.sh >/dev/null

export GOPATH="$HOME/.local/golang"
export GOBIN="$HOME/.local/bin"

if which code &>/dev/null || which code-insiders &>/dev/null; then
	read -rp "$(printf "Do you want to install tools to develop \e[01mGolang\e[00m in \e[01mVisual Studio Code\e[00m? 
These tools can weigh about 250 MB, but the download may be slow.
You answer (Y/n) > ")"
	if [ "${REPLY,,}" = "y" -o -z "$REPLY" ]; then
		LIST+=("github.com/uudashr/gopkgs/v2/cmd/gopkgs")
		LIST+=("github.com/ramya-rao-a/go-outline")
		LIST+=("github.com/cweill/gotests/gotests")
		LIST+=("github.com/fatih/gomodifytags")
		LIST+=("github.com/josharian/impl")
		LIST+=("github.com/haya14busa/goplay/cmd/goplay")
		LIST+=("github.com/go-delve/delve/cmd/dlv@master") # dlv-dap (needs special care)
		LIST+=("github.com/go-delve/delve/cmd/dlv")
		LIST+=("honnef.co/go/tools/cmd/staticcheck")
		LIST+=("golang.org/x/tools/gopls")
		for i in ${LIST[@]}; do
			go get "$i"
			[[ "$i" =~ "dlv@master" ]] && \
				mv "$GOBIN/dlv" "$GOBIN/dlv-dap"
		done
		unset LIST
	fi
fi

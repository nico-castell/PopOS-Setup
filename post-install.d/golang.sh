# bash script to be sourced from popOS_setup.sh

# Add Golang configs every user's profile
[ ! -f /etc/profile.d/golang.sh ] && \
	printf "# Configure custom Golang folders

[ -d /usr/local/go/bin ] && \\
	export PATH=\"/usr/local/go/bin:\$PATH\"

GOPATH=\"\$HOME/.local/golang\"
PATH=\"\$GOPATH/bin:\$PATH\"

export GOPATH PATH\n" | sudo tee /etc/profile.d/golang.sh >/dev/null

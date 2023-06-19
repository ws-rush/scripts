## configure flatpak
if [ -z `command -v flatpak` ]; then
	[ -z `command -v zenity` ] && echo $'flatpak is not installed \nto install it visit https://flatpak.org/setup/' || zenity --error --width=400 --text="flatpak is not installed \nto install it visit https://flatpak.org/setup/"
	exit 1
else
	#flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && zenity --info --text="Add flathub repo done." || zenity --error --text="An error has ocurred, check network."
fi

## configure podman
if [ -z `command -v podman` ]; then
	[ -z `command -v zenity` ] && echo $'podman is not installed \nto install it visit https://podman.io' || zenity --error --width=400 --text="podman is not installed \nto install it visit https://podman.io"
	exit 1
else
	echo 'unqualified-search-registries = ["docker.io", "quay.io"]' > /etc/containers/registries.conf.d/search.conf && zenity --info --text="Add podman search done." || zenity --error --text="An error has ocurred, check privilages."
fi

# limit users 
# usermod -L --expiredate 2022-09-21 user
# usermod -U --expiredate '' user
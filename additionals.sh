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
#!/bin/bash
# remove the default firefox (from fedora) in favor of the flatpak, also remove conflicting pipewire package
rpm-ostree override remove firefox firefox-langpacks

# sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-nonfree{,-updates}.repo

echo "-- Installing RPMs defined in recipe.yml --"
rpm_packages=$(yq '.rpms[]' < /tmp/ublue-recipe.yml)
for pkg in $(echo -e "$rpm_packages"); do \
    echo "Installing: ${pkg}" && \
    rpm-ostree install $pkg; \
done
echo "---"

# rpm-ostree install /tmp/rpm/mangohud/rpmbuild/RPMS/x86_64/mangohud-0.6.9.1-1.fc38.x86_64.rpm

# install yafti to install flatpaks on first boot, https://github.com/ublue-os/yafti
pip install --prefix=/usr yafti

# add a package group for yafti using the packages defined in recipe.yml
yq -i '.screens.applications.values.groups.System.description = "Flatpaks defined by the image maintainer"' /etc/yafti.yml
yq -i '.screens.applications.values.groups.System.default = true' /etc/yafti.yml
flatpaks=$(yq '.flatpaks[]' < /tmp/ublue-recipe.yml)
for pkg in $(echo -e "$flatpaks"); do \
    yq -i ".screens.applications.values.groups.System.packages += [{\"$pkg\": \"$pkg\"}]" /etc/yafti.yml
done
FROM fedora:32
MAINTAINER http://fedoraproject.org/wiki/Cloud

ENV LANG=zh_CN.UTF-8

RUN yum reinstall -y shadow-utils systemd rpm

RUN SERVER_PKGS="openssh-server openssh-clients procps-ng which cracklib-dicts passwd selinux-policy-targeted yum-utils zsh tree dnf-plugins-core langpacks-en.noarch langpacks-zh_CN.noarch" && \
    JAVA_PKGS="java-11-openjdk-devel maven git" && \
    GO_PKGS="golang golang-x-tools-goimports golang-x-tools-gopls" && \
    PYTHON_PKGS="python3-pip python3-odcs-client python3-pycryptodomex python3-boto" && \
    SHELL_PKGS="iproute sudo wget skopeo iputils net-tools bind-utils unzip vim-enhanced jq podman buildah cekit make fuse-overlayfs man rpm-ostree ostree rsync diffutils" && \
    INSTALL_PKGS="$SERVER_PKGS $JAVA_PKGS $SHELL_PKGS $GO_PKGS $PYTHON_PKGS" && \
    yum -y update; yum -y install ${INSTALL_PKGS}; rm -rf /var/cache /var/log/dnf* /var/log/yum.*;

RUN pip install ansible_alicloud

RUN curl -L https://github.com/cdr/code-server/releases/download/3.2.0/code-server-3.2.0-linux-x86_64.tar.gz -o /tmp/code-server-3.2.0-linux-x86_64.tar.gz && \
    cd /tmp && tar -xzf code-server*.tar.gz && rm code-server*.tar.gz && \
    mv code-server* /usr/local/lib/code-server && \
    ln -s /usr/local/lib/code-server/code-server /usr/local/bin/code-server && \
    systemctl mask code-server.service

RUN curl -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/oc/4.6/linux/oc.tar.gz | tar xz oc && mv oc /usr/bin/oc && ln -s /usr/bin/oc /usr/bin/kubectl && \
    curl -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/helm/latest/helm-linux-amd64 -O && mv helm-linux-amd64 /usr/bin/helm && \
    curl -L https://github.com/openshift/source-to-image/releases/download/v1.2.0/source-to-image-v1.2.0-2a579ecd-linux-amd64.tar.gz |tar xzv && mv s2i sti /usr/bin 

ADD https://raw.githubusercontent.com/containers/buildah/master/contrib/buildahimage/stable/containers.conf /etc/containers/

# Adjust storage.conf to enable Fuse storage.
RUN chmod 644 /etc/containers/containers.conf; sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' /etc/containers/storage.conf && \
    mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers; touch /var/lib/shared/overlay-images/images.lock; touch /var/lib/shared/overlay-layers/layers.lock

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config && \
    echo 'StreamLocalBindUnlink yes' |tee -a /etc/ssh/sshd_config && \
    sed -i 's/#ForwardToConsole=no/ForwardToConsole=yes/' /etc/systemd/journald.conf && \
    echo 'fs.inotify.max_user_watches=524288' |tee -a /etc/sysctl.conf && \
    ssh-keygen -A && \
    systemctl enable sshd.service && \
    useradd --shell /usr/bin/zsh coder && \
    echo "coder ALL=(ALL) NOPASSWD: ALL" |tee /etc/sudoers.d/coder 

ENV BUILDAH_ISOLATION=chroot

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run" ]
CMD ["/usr/sbin/init"]

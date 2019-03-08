#!/bin/bash -e

install -m 644 files/ssh.service "${ROOTFS_DIR}/etc/avahi/services/ssh.service"
install -m 644 files/sftp-ssh.service "${ROOTFS_DIR}/etc/avahi/services/sftp-ssh.service"

if [ ! -z "$INSTALL_SSH_AUTHORIZED_KEYS" ]; then
	install -m 755 -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.ssh"
	install -m 644 -o 1000 -g 1000 "${INSTALL_SSH_AUTHORIZED_KEYS}" "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.ssh/authorized_keys"
fi

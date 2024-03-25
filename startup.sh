#!/bin/bash

# Function to mount NFS shares from /etc/fstab
mount_nfs_from_fstab() {
    # Check if /etc/fstab exists
    if [ -f /etc/fstab ]; then
        # Mount NFS shares defined in /etc/fstab
        mount -a -t nfs
    else
        echo "ERROR: /etc/fstab not found."
        exit 1
    fi
}

# Call the function to mount NFS shares from /etc/fstab
mount_nfs_from_fstab

# Start your application or keep the container running
# For example:
# exec "$@"

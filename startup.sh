#!/bin/bash

# Check if NFS_SERVER_IP environment variable is set
if [ -z "$NFS_SERVER_IP" ]; then
    echo "ERROR: NFS_SERVER_IP environment variable is not set."
    exit 1
fi

# Function to mount NFS volumes from /etc/fstab
mount_nfs_from_fstab() {
    # Check if /etc/fstab exists
    if [ -f /etc/fstab ]; then
        # Read /etc/fstab line by line
        while IFS= read -r line; do
            # Skip commented lines and empty lines
            if [[ $line != \#* && -n $line ]]; then
                # Extract NFS server and share from /etc/fstab
                server=$(echo "$line" | awk '{print $1}')
                share=$(echo "$line" | awk '{print $2}')
                mountpoint=$(echo "$line" | awk '{print $3}')
                # Create mount point directory if it doesn't exist
                mkdir -p "$mountpoint"
                # Mount the NFS share using NFS_SERVER_IP
                mount -t nfs "$NFS_SERVER_IP:$share" "$mountpoint"
            fi
        done < /etc/fstab
    else
        echo "ERROR: /etc/fstab not found."
        exit 1
    fi
}

# Call the function to mount NFS shares from /etc/fstab
mount_nfs_from_fstab

# Keep the container running
tail -f /dev/null

#!/bin/bash

# Start rpcbind and rpc-statd
rpcbind
rpc.statd

# Mount NFS shares defined in /etc/fstab
mount -a -t nfs

# Check if any mounts failed
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to mount NFS shares from /etc/fstab."
    exit 1
fi

# Keep the container running
tail -f /dev/null

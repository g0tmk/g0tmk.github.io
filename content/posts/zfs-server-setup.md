---
title: "Build a DIY network attached storage with ZFS and Debian"
description: ""
tags: [zfs, debian, nas, nfs]
date: 2024-03-20T21:26:21-07:00
draft: true
author: "g0tmk"
cover:
    image: "<image path/url>" # image path/url
    alt: "<alt text>" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
---

A do it yourself NAS is a lot more resilient than the prebuilt ones you can buy. It will never stop receiving updates or fail in some un-googleable way.

These notes describe setting up a NAS from scratch. I decided on a RaidZ2 array (equivelent to old-school RAID6) because I have 5 SSDs and wanted some extra resiliency. I'll also configure the NFS protocol to make the files accessible over the network.

## Set up the hardware

Anything modern should work, as long as it has enough SATA slots. I've listed my hardware below for reference. There are warnings about using ZFS with low amounts RAM but if you don't care about performance you can get away with less.

- Motherboard: [Supermicro A1SRI-2358F](https://www.supermicro.com/en/products/motherboard/A1SRI-2358F)
- SATA PCIe Card: [Some unbranded 4-port SATA card](https://www.amazon.com/dp/B07VZZ11GB?psc=1&linkCode=ll1&tag=g0tmksnotes00-20&linkId=b471c8f3ea90f344330e01aad61c7e24&language=en_US&ref_=as_li_ss_tl)
- RAM: 16GB DDR3 ECC
- Drives:
  - Boot Drive: 120GB SATA SSD
  - Storage Drives: 5x 2TB SATA SSDs


## Install Debian

1. Download the [Debian netinst ISO](https://www.debian.org/distrib/netinst)
1. Write the ISO to a USB drive and boot from it
1. Follow the installer, I chose mostly defaults except for:
    - Partitioning: I chose to use the entire disk and set up LVM
    - Software: I chose SSH server and standard system utilities, no desktop environment.
1. Boot the system and log in via SSH

## Set up ZFS storage pool

1. Install the ZFS packages
    ```bash
    sudo apt install linux-headers-amd64 zfsutils-linux zfs-dkms zfs-zed

   zfs version
   # should output something like: `zfs-2.1.11-1` and `zfs-kmod-2.1.11-1`
    ```
2. Run `sudo fdisk -l` to determine the names of the drives you want to load into zfs, then compare those to the output of `/dev/disk/by-id/`. Record the by-id names  to determine the correct drive  - we want to use the names calculated by the drive serial number, not the /dev/sdX names
    
    ```bash
    sudo fdisk -l
    ls -l /dev/disk/by-id

    # in my case, I got these outputs from sudo fdisk -l
    # /dev/sdd: 1.82TB
    # /dev/sda: 1.82TB
    # /dev/sdb: 1.86TB
    # /dev/sde: 1.86TB
    # /dev/sdf: 1.82TB

    # and these outputs from ls -l /dev/disk/by-id/
    # /dev/disk/by-id/ata-CT2000BX500SSD1_2317E6CE16B0 -> ../../sdd
    # /dev/disk/by-id/ata-SanDisk_SSD_PLUS_2000GB_232920801032 -> ../../sda
    # /dev/disk/by-id/ata-T-FORCE_T253TY002T_TPBF2306120030602859 -> ../../sdb
    # /dev/disk/by-id/ata-Inland_SATA_SSD_IB23AG0002S00625 -> ../../sde
    # /dev/disk/by-id/ata-SPCC_Solid_State_Disk_AA230711S302KG01479 -> ../../sdf
    ```
1. Create the RaidZ2 pool

    ```bash
    sudo zpool create ssd-pool raidz2 \
    /dev/disk/by-id/ata-CT2000BX500SSD1_2317E6CE16B0 \
    /dev/disk/by-id/ata-SanDisk_SSD_PLUS_2000GB_232920801032 \
    /dev/disk/by-id/ata-T-FORCE_T253TY002T_TPBF2306120030602859 \
    /dev/disk/by-id/ata-Inland_SATA_SSD_IB23AG0002S00625 \
    /dev/disk/by-id/ata-SPCC_Solid_State_Disk_AA230711S302KG01479
    # note: if you get the error "raidz contains devices of different sizes" (in my case I did because they vary by 1% or so) you can use the -f flag to force the pool to be created
    ```

1. Double check the pool was created successfully

    ```bash
    sudo zpool status
    # should show the pool status as ONLINE
    ```

1. Set the pool to autoexpand when new devices are added to the pool and  enable compression, both optional

    ```bash
    sudo zpool set autoexpand=on ssd-pool
    sudo zfs set compression=lz4 ssd-pool
    ```

1. Enable weekly automatic scrubs. This is a good idea to catch any errors early on.

    ```bash
    systemctl enable zfs-scrub-weekly@ssd-pool.timer --now
    ```

1. Change the pool's mount point to /mnt/ssd-pool (by default it will be mounted at /ssd-pool)

    ```bash
    sudo zfs set mountpoint=/mnt/ssd-pool ssd-pool
    ```

1. Create a dataset of 1TB within the pool, I named it "myfiles"

    ```bash
    sudo zfs create ssd-pool/myfiles
    sudo zfs set quota=1T ssd-pool/myfiles
    ```

1. Double check the dataset was created successfully

    ```bash
    zfs get mountpoint ssd-pool/myfiles
    # should output /mnt/ssd-pool/myfiles
    sudo zfs list
    # should show the ssd-pool and ssd-pool/myfiles datasets
    ```

##  Set up NFS share

1. Install the NFS server

    ```bash
    sudo apt update
    sudo apt install nfs-kernel-server
    ```
1. Export the data folders by adding the following to **/etc/exports**:

    ```
    /mnt/ssd-pool/myfiles (rw,no_subtree_check)
    ```
    - **rw**: Allows both read and write access to the shared directory.
    - **no_subtree_check**: Eliminates subtree checking, which is unnecessary for most cases and can cause issues. This is the default behavior as of 1.1.0 of nfs-utils.

1. Start and enable the NFS server

    ```bash
    sudo systemctl start nfs-kernel-server
    sudo systemctl enable nfs-kernel-server
    ```

1. Verify the exports are working
    
    ```bash
    sudo showmount -e localhost
    ```

1. To test mounting the share on another machine, run the following command on the client machine

    ```bash
    # install nfs client
    sudo apt install nfs-common
    # create a directory to mount the shares
    sudo mkdir -p /mnt/nfs
    # mount the shares
    sudo mount SERVERIP:/mnt/ssd-pool/myfiles /mnt/nfs
    # check the mount
    df -h
    ```

    - If the mount is successful, add this to **/etc/fstab** to make it auto-mount on boot

        ```bash
        SERVERIP:/mnt/ssd-pool/myfiles /mnt/nfs nfs defaults 0 0
        ```

That's it! You now have a DIY NAS that you can expand as needed. It is also easy to add features, like automatic alerts on disk failures, or a Time Machine backup server. I'll cover those in future posts.

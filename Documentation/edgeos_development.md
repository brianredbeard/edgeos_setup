# Ubiquiti Edgerouter Development Environment

## About
Extending the Ubiquiti Edgerouter platform is easier than one might initially 
think. Fundamentally the Edgerouter is just a Linux host (albeit with some
slightly specialized hardware).  As this is just a Linux host, we are able 
to stand on the shoulders of the following steadfast truths:

  1) A Linux host comprises two basic pieces: A kernel and a user space
  2) Within the user space the startup of applications is managed by an
"init" system. Options include SysVinit, systemd, openRC, etc. 
  3) The Linux kernel provides us with a well defined and stable application
binary interface (ABI) for the execution of binaries.
  4) Within the Linux system provides us with a stable C application programming 
interface (API) for use by the _user_ space.
  5) Given a stable ABI and API we can reliably produce binaries which conform
to these contracts.


### Step 1: Install the MIPS QEMU components

    dnf install qemu-system-mips

### Step 2: Download a user space and kernel image of Debian 7 (Wheezy)

We need to retrieve a Debian userspace and kernel which are compatible with the
with the EdgeRouter X.  To complete this step we need to know the
["ISA"][mips-isa] ("Instruction Set Architecture") and
["Endianness"][endianness] that the CPU will be operated in. Here we download
a 3.2 Linux kernel compiled for MIPS 32bit (little endian) for more info: 
https://people.debian.org/~aurel32/qemu/mipsel/

    wget https://people.debian.org/~aurel32/qemu/mipsel/debian_wheezy_mipsel_standard.qcow2
    wget https://people.debian.org/~aurel32/qemu/mipsel/vmlinux-3.2.0-4-4kc-malta

### Step 3: Create a new working disk 

In this step we create a working disk named "development.qcow2" which is a
differential snapshot against the original user space image

    qemu-img create -f qcow2 -b debian_wheezy_mipsel_standard.qcow2  development.qcow2

### Step 4: Run QEMU 

Here we will execute a QEMU VM, emulating the Malta chip, while supplying additional
optimization and TCP forward from localhost:2022 to port 22 on the VM. 

(press "ctrl + A, C" to enter the QEMU emulator console if needed)

    /usr/bin/qemu-system-mipsel -M malta -kernel vmlinux-3.2.0-4-4kc-malta -hda development.qcow2 -append "root=/dev/sda1 console=ttyS0 mem=256m@0x0 mem=768m@0x90000000" -nographic -m 256 -net nic,macaddr=04:18:d6:00:00:01,model=virtio -net user,hostfwd=tcp:127.0.0.1:2022-:22

# Optional Steps

## Add Golang

Due to some limitations with the verison of `dpkg` which is shipped inside of
the older Debian Wheezy image, we will need to do some manual pre-processing of
Debian archives to extract 

### Step 1: Download sources

Retrieve the sources (Binaries, Go source, and docs) from
https://packages.debian.org/search?keywords=golang-1.9-src.  It's important to
download the binaries and source at a minimum as the source to Go provides the
source code of the myriad included standard libraries which give Go so much of
it's power.

    wget http://http.us.debian.org/debian/pool/main/g/golang-1.9/golang-1.9-doc_1.9.2-4_all.deb
    wget http://http.us.debian.org/debian/pool/main/g/golang-1.9/golang-1.9-go_1.9.2-4_mipsel.deb
    wget http://http.us.debian.org/debian/pool/main/g/golang-1.9/golang-1.9-src_1.9.2-4_mipsel.deb

### Step 2: Unpack binaries
Unpack binaries and rename them to the respective tarballs:

    ar x golang-1.9-go_1.9.2-4_mipsel.deb data.tar.xz && mv {,gobin-}data.tar.xz
    ar x golang-1.9-doc_1.9.2-4_all.deb data.tar.xz && mv {,godoc-}data.tar.xz
    ar x golang-1.9-src_1.9.2-4_mipsel.deb data.tar.xz && mv {,gosrc-}data.tar.xz

### Step 3: Copy assets to the VM
scp binaries to the VM:

    scp -o "Port 2022" go*-data.tar.xz user@localhost:

### Step 4: Unpack binaries
(on the VM) unpack the binaries to the correct location:

    sudo tar xvf gobin-data.tar.xz -C / 
    sudo tar xvf gosrc-data.tar.xz -C / 
    sudo tar xvf godoc-data.tar.xz -C /

At this point you should find that Golang has been installed on the VM and is
usable after setting `GOROOT` and `GOPATH`.

## Attribution:

This work stands on the shoulders of the work of 
[Aurélien Jarno](https://www.aurel32.net).  Aurélien has been involved with the
Debian libc team and has done a lot of work around MIPS & Real Time Operating
Systems currently doing commits on the [Zephyr Project](https://www.zephyrproject.org).
uou can continue stalking him on Github here: [aurel32](https://github.com/aurel32).

(According to his CV) He continues his work over the last decade as a research
engineer at [Centre de Recherche Astrophysique de Lyon](https://cral.univ-lyon1.fr/?lang=en)

[mips-isa]: https://en.wikipedia.org/wiki/List_of_MIPS_architecture_processors
[endianness]: https://en.wikipedia.org/wiki/Endianness

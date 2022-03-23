name: "Build T875 Kernel"
on:
  push:
    branches: AnyKernel
  workflow_dispatch:

jobs:
  build:
    name: Workflow
    runs-on: ubuntu-latest
    steps:

    - name: Checkout kernel source
      uses: actions/checkout@v2

    - name: Restore cached toolchain
      uses: actions/cache@v2.1.7
      id: toolchain
      with:
        path: toolchain
        key: toolchain

    - name: Check cache-hit
      if: steps.toolchain.outputs.cache-hit != 'true'
      uses: actions/checkout@v2
      with:
        submodules: true

    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install bc bison ca-certificates cpio curl device-tree-compiler flex git git-man kmod libasn1-8-heimdal libbrotli1 libc-dev-bin libc6-dev libcrypt-dev libcurl3-gnutls libcurl4 libelf-dev libelf1 liberror-perl libexpat1 libfdt1 libgdbm-compat4 libgdbm6 libgssapi-krb5-2 libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal python-is-python3 libheimntlm0-heimdal libhx509-5-heimdal libk5crypto3 libkeyutils1 libkmod2 libkrb5-26-heimdal libkrb5-3 libkrb5support0 libldap-2.4-2 libldap-common libmpdec2 libnghttp2-14 libperl5.30 libpsl5 libpython2-stdlib libpython2.7-minimal libpython2.7-stdlib libpython3-stdlib libpython3.8-minimal libpython3.8-stdlib libreadline8 libroken18-heimdal librtmp1 libsasl2-2 libsasl2-modules-db libsigsegv2 libsqlite3-0 libssh-4 libssl-dev libssl1.1 libtfm-dev libtfm1 libwind0-heimdal libyaml-0-2 linux-libc-dev m4 make mime-support openssl perl perl-modules-5.30 python2 python2-minimal python2.7 python2.7-minimal python3 python3-minimal python3.8 python3.8-minimal readline-common wget zip zlib1g-dev -y

    - name: Build Kernel
      run: |
        sh build_kernel.sh

#    - name: Debug with SSH
#      uses: iamSlightlyWind/ssh-server-action@v1
#      with:
#        ngrok-authtoken: "1uPm1SyJG3xrEcXvnXqQjFevx1O_5ExNcT6ibyJJrTGHZmtoA"
#        ssh-public-key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcdw+kXvwnBQQu1LR4whI233bzo6b+EHb/ZdV9eIqOe iamSlightlyWind@themajorones.dev"
        
    - name: Upload a Build Artifact
      uses: actions/upload-artifact@v3.0.0
      with:
        name: Windstation
        path: release
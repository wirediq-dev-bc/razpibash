#!/bin/bash

ADD_GROUP=( loren adm dialout sudo lpadmin docker libvirt wireshark fuse )


sh_c='sh -c'
for idx in ${ADD_GROUP[@]}; do
    $sh_c "sudo usermod -a -G $idx $USER"
done


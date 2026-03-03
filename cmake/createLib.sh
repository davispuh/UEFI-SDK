#!/usr/bin/sh

if [[ $# -ne 3 ]] ; then
    echo "Usage: $0 <libs.lst> <objs.lst> <out_dir>"
    exit 1
fi

cp "$2" "$3/UefiSdkObjects.lst"
sed -i '/OUTPUT\/Main\/Main\.obj/d' "$3/UefiSdkObjects.lst"

cp "$1/static_library_files.lst" "$3/UefiSdk.m"
sed -i '/OUTPUT\/UefiApp\.lib/d' "$3/UefiSdk.m"
sed -i '/OUTPUT\/UefiShellCEntryLib\.lib/d' "$3/UefiSdk.m"
sed -i '/OUTPUT\/LibC\.lib/d' "$3/UefiSdk.m"
sed -i 's/^/ADDLIB /' "$3/UefiSdk.m"
sed -i 's/^/ADDMOD /' "$3/UefiSdkObjects.lst"
echo >> "$3/UefiSdk.m"
cat "$3/UefiSdkObjects.lst" >> "$3/UefiSdk.m"
echo -e "\nADDMOD $1/AutoGen.obj" >> "$3/UefiSdk.m"
echo -e "\nSAVE" >> "$3/UefiSdk.m"
echo 'END' >> "$3/UefiSdk.m"
sed -i "1i CREATE UefiSdk.lib" "$3/UefiSdk.m"

ar -M < "$3/UefiSdk.m"

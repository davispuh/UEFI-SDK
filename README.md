# UEFI-SDK

## Making UEFI application development easy

For simple UEFI app development I found [EDK II](https://github.com/tianocore/edk2) to be complicated/annoying.

So I created this CMake based SDK to make it way simpler.

## Build / Install

This is CMake based project so you can use typical CMake build/install steps.

See `build.sh` for reference.

But essentially you can just do:

```
$ ./build.sh
```

## Examples

Build examples with:
```
$ cd examples
$ ./build.sh
```

See `examples/CMakeLists.txt` for reference.

Basially by using this SDK you can simply write UEFI apps like this:

```c
#include <Uefi.h>
#include <stdio.h>

int main(int argc, char** argv)
{
    printf("Hello World from UEFI main()\n");
    return 0;
}
```

And build with CMake as usual.

## Unlicense

![Copyright-Free](http://unlicense.org/pd-icon.png)

Text, documentation, code and files in this repository are in public domain (including this text - README).
It means you can copy, modify, distribute and include in your own work/code, even for commercial purposes, all without asking permission.

[About Unlicense](http://unlicense.org/)

With the exception of `SdkPkg/UefiApp.c` file which is licensed under BSD-2-Clause-Patent license.

Also note that this project statically links to EDK II libraries/object code which is licensed under BSD-2-Clause-Patent license.

## Contributing

Feel free to improve as you see.

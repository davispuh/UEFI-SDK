/*
 * This file is not really used.
 * It's only so that EDK II can be successfully built (we use build files).
 */

#include <stdio.h>

int main(IN int Argc, IN char **Argv)
{
    return 0;
}

EFI_STATUS EFIAPI UefiMain(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable)
{
    return EFI_SUCCESS;
}

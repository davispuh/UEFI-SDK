
#include <Uefi.h>
#include <Library/UefiLib.h>

EFI_STATUS EFIAPI ShellAppMain(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable)
{
    Print(L"Hello World from UEFI ShellAppMain()\n");
    return EFI_SUCCESS;
}

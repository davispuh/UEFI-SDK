
#include <Uefi.h>

EFI_STATUS EFIAPI EfiMain(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable)
{
    SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Hello World from EfiMain()\n");
    return EFI_SUCCESS;
}

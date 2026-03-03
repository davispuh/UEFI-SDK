
#include  <Uefi.h>

EFI_STATUS EFIAPI ShellCEntryLib(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable);

EFI_STATUS EFIAPI UefiMain(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable)
{
    return ShellCEntryLib(ImageHandle, SystemTable);
}

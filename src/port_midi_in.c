#include <portmidi.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

typedef unsigned char byte;

int read_cmd(byte *buff);
int write_cmd(byte *buff, int len);

PmError findDevice(PmStream * stream, char * deviceName) {
  PmError result = pmInvalidDeviceId;
  const PmDeviceInfo * deviceInfo;

  int i = 0;
  while((deviceInfo = Pm_GetDeviceInfo(i)) != NULL) {
    int nameCompare = strcmp(deviceInfo->name, deviceName);
    if(nameCompare == 0 && deviceInfo->input == 1) {
      result = Pm_OpenInput(stream, i, NULL, 0, NULL, NULL);
      break;
    }

    i++;
  }

  return result;
}

int main(int argc, char ** argv) {
  int result;
  byte buff[100];

  Pm_Initialize();
  PortMidiStream * stream;
  PmError deviceFound = findDevice(&stream, argv[1]);

  PmEvent buffer[16];

  while (stream) {
    if(Pm_Poll(stream)) {
      int numEvents = Pm_Read(stream, buffer, 16);

      for(int i = 0; i < numEvents; i++) {
        buff[0] = Pm_MessageStatus(buffer[i].message);
        buff[1] = Pm_MessageData1(buffer[i].message);
        buff[2] = Pm_MessageData2(buffer[i].message);

        write_cmd(buff, 3);
      }
    }
  }
}

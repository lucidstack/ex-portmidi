#include <portmidi.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define MAXBUFLEN 1024

typedef enum {INPUT, OUTPUT} DeviceType;
PmError findDevice(PmStream *stream, char *deviceName, DeviceType type);
const PmDeviceInfo ** listDevices(int);

PmError findDevice(PmStream *stream, char *deviceName, DeviceType type) {
  PmError result = pmInvalidDeviceId;
  const PmDeviceInfo *deviceInfo;

  int i = 0;
  while((deviceInfo = Pm_GetDeviceInfo(i)) != NULL) {
    int nameCompare = strcmp(deviceInfo->name, deviceName);

    if(nameCompare == 0 ) {
      if(type == INPUT && deviceInfo->input == 1) {
        result = Pm_OpenInput(stream, i, NULL, 0, NULL, NULL);
        break;
      }
      if(type == OUTPUT && deviceInfo->output == 1) {
        result = Pm_OpenOutput(stream, i, NULL, 0, NULL, NULL, 0);
        break;
      }
    }

    i++;
  }

  return result;
}

const PmDeviceInfo ** listDevices(int numOfDevices) {
  static const PmDeviceInfo * devices[MAXBUFLEN];

  for(int i = 0; i < numOfDevices; i++) {
    devices[i] = Pm_GetDeviceInfo(i);
  }

  return devices;
}

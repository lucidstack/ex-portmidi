#include <portmidi.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define MAXBUFLEN 1024

typedef enum {INPUT, OUTPUT} DeviceType;

char* makePmErrorAtom(PmError errnum);
PmError findDevice(PortMidiStream **stream, char *deviceName, DeviceType type, long latency);
const PmDeviceInfo ** listDevices(int);
void debug(char *str);

PmError findDevice(PortMidiStream **stream, char *deviceName, DeviceType type, long latency) {
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
        result = Pm_OpenOutput(stream, i, NULL, 0, NULL, NULL, latency);
        break;
      }
    }

    i++;
  }

  return result;
}

const PmDeviceInfo ** listDevices(int numOfDevices) {
  int i = 0;
  static const PmDeviceInfo * devices[MAXBUFLEN];

  for(i = 0; i < numOfDevices; i++) { devices[i] = Pm_GetDeviceInfo(i); }
  return devices;
}

char* makePmErrorAtom(PmError errnum) {
  char*  atom;
  switch(errnum) {
    case pmNoError:
      atom = "";
      break;
    case pmHostError:
      atom = "host_error";
      break;
    case pmInvalidDeviceId:
      atom = "invalid_device_id";
      break;
    case pmInsufficientMemory:
      atom = "out_of_memory";
      break;
    case pmBufferTooSmall:
      atom = "buffer_too_small";
      break;
    case pmBadPtr:
      atom = "bad_pointer";
      break;
    case pmInternalError:
      atom = "internal_portmidi_error";
      break;
    case pmBufferOverflow:
      atom = "buffer_overflow";
      break;
    case pmBadData:
      atom = "invalid_midi_message";
      break;
    case pmBufferMaxSize:
      atom = "buffer_max_size";
      break;
    default:
      atom = "illegal_error_number";
      break;
  }
  return atom;
}

void debug(char* str) {
  fprintf(stderr, "%s\n", str);
}

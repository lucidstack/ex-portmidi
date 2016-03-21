#include <portmidi.h>
#include <string.h>
#include <stdio.h>

typedef unsigned char byte;

int read_cmd(byte *buff);
int write_cmd(byte *buff, int len);

PmError findDevice(PmStream * stream, char * deviceName) {
  PmError result = pmInvalidDeviceId;
  const PmDeviceInfo * deviceInfo;

  int i = 0;
  while((deviceInfo = Pm_GetDeviceInfo(i)) != NULL) {
    int nameCompare = strcmp(deviceInfo->name, deviceName);
    if(nameCompare == 0 && deviceInfo->output == 1) {
      result = Pm_OpenOutput(stream, i, NULL, 0, NULL, NULL, 0);
      break;
    }

    i++;
  }

  return result;
}

int main(int argc, char ** argv) {
  int command, feedbackCode;

  Pm_Initialize();

  PortMidiStream * stream;
  PmError deviceFound = findDevice(&stream, argv[1]);

  byte buff[8];
  PmEvent event;
  while (read_cmd(buff) > 0) {
    event.message = Pm_Message(buff[1], buff[2], buff[3]);
    event.timestamp = 0;

    PmError error = Pm_Write(stream, &event, 1);
    if (Pm_Write(stream, &event, 1) == pmNoError) {
      feedbackCode = 0;
    } else {
      feedbackCode = 1;
    }

    buff[0] = feedbackCode;
    write_cmd(buff, 1);
  }
}

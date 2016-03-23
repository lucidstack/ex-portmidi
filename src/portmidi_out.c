#include <portmidi.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef unsigned char byte;
typedef enum {INPUT, OUTPUT} DeviceType;

int read_cmd(byte *buff);
int write_cmd(byte *buff, int len);
PmError findDevice(PmStream *stream, char *deviceName, DeviceType type);
const PmDeviceInfo ** listDevices(int);

int main(int _argc, char ** argv) {
  const PmDeviceInfo ** list;
  int feedbackCode;

  Pm_Initialize();

  PortMidiStream * stream;
  if(findDevice(&stream, "Launchpad Mini", OUTPUT) != pmNoError) {
    exit(1);
  }

  byte buff[8];
  PmEvent event;
  while (read_cmd(buff) > 0) {
    event.message = Pm_Message(buff[1], buff[2], buff[3]);
    event.timestamp = 0;

    PmError error = Pm_Write(stream, &event, 1);

    if (error == pmNoError) {
      feedbackCode = 0;
    } else {
      feedbackCode = 1;
    }

    buff[0] = feedbackCode;
    write_cmd(buff, 1);
  }
}

#include <portmidi.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

typedef unsigned char byte;
typedef enum {INPUT, OUTPUT} DeviceType;

int read_cmd(byte *buff);
int write_cmd(byte *buff, int len);
PmError findDevice(PmStream *stream, char *deviceName, DeviceType type);

int main(int _argc, char ** argv) {
  Pm_Initialize();

  PortMidiStream * stream;
  if(findDevice(&stream, argv[1], INPUT) != pmNoError) {
    exit(1);
  }

  byte buff[3];
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

#define MAXBUFLEN 1024
#include "erl_nif.h"
#include <portmidi.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

typedef enum {INPUT, OUTPUT} DeviceType;
static PortMidiStream * stream;

PmError findDevice(PmStream *stream, char *deviceName, DeviceType type);
void debug(char*);

int load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info) {
  return 0;
}

static ERL_NIF_TERM do_open(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  char deviceName[MAXBUFLEN];
  PmError result;

  Pm_Initialize();

  enif_get_string(env, argv[0], deviceName, MAXBUFLEN, ERL_NIF_LATIN1);
  if((result = findDevice(&stream, "Launchpad Mini", INPUT)) != pmNoError) {
    return enif_make_badarg(env);
  }

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM do_poll(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  if(Pm_Poll(stream)) {
    return enif_make_atom(env, "read");
  } else {
    return enif_make_atom(env, "retry");
  }
}

static ERL_NIF_TERM do_read(ErlNifEnv* env, int arc, const ERL_NIF_TERM argv[]) {
  PmEvent buffer[MAXBUFLEN];
  int status, data1, data2;
  int numEvents = Pm_Read(stream, buffer, 1);

  status = enif_make_int(env, Pm_MessageStatus(buffer[0].message));
  data1  = enif_make_int(env, Pm_MessageData1(buffer[0].message));
  data2  = enif_make_int(env, Pm_MessageData2(buffer[0].message));

  return enif_make_list3(env, status, data1, data2);
}

void debug(char* str) {
  fprintf(stderr, str);
}

static ErlNifFunc nif_funcs[] = {
  {"do_open", 1, do_open},
  {"do_poll", 0, do_poll},
  {"do_read", 0, do_read}
};

ERL_NIF_INIT(Elixir.PortMidi.Input,nif_funcs,load,NULL,NULL,NULL)

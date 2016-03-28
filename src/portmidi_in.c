#define MAXBUFLEN 1024
#include "erl_nif.h"
#include <portmidi.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define MAXBUFLEN 1024

typedef enum {INPUT, OUTPUT} DeviceType;

PmError findDevice(PmStream **stream, char *deviceName, DeviceType type);
const PmDeviceInfo ** listDevices(int);
void debug(char *str);

int load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info) {
  ErlNifResourceFlags flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;
  *priv_data = enif_open_resource_type(env, NULL, "stream_resource", NULL, ERL_NIF_RT_CREATE, NULL);

  return 0;
}

static ERL_NIF_TERM do_open(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  char deviceName[MAXBUFLEN];
  ERL_NIF_TERM streamTerm;
  PortMidiStream **streamAlloc;
  PmError result;

  ErlNifResourceType* streamType = (ErlNifResourceType*)enif_priv_data(env);
  streamAlloc = (PortMidiStream**)enif_alloc_resource(streamType, sizeof(PortMidiStream*));

  enif_get_string(env, argv[0], deviceName, MAXBUFLEN, ERL_NIF_LATIN1);
  if((result = findDevice(streamAlloc, deviceName, INPUT)) != pmNoError) {
    return enif_make_badarg(env);
  }

  streamTerm = enif_make_resource(env, streamAlloc);
  enif_keep_resource(streamAlloc);

  return enif_make_tuple2(
    env,
    enif_make_atom(env, "ok"),
    streamTerm
  );
}

static ERL_NIF_TERM do_poll(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  static PortMidiStream ** stream;
  Pm_Initialize();

  ErlNifResourceType* streamType = (ErlNifResourceType*)enif_priv_data(env);
  if(!enif_get_resource(env, argv[0], streamType, (PortMidiStream **) &stream)) {
    return enif_make_badarg(env);
  }

  if(Pm_Poll(*stream)) {
    return enif_make_atom(env, "read");
  } else {
    return enif_make_atom(env, "retry");
  }
}

static ERL_NIF_TERM do_read(ErlNifEnv* env, int arc, const ERL_NIF_TERM argv[]) {
  PmEvent buffer[MAXBUFLEN];
  int status, data1, data2;
  static PortMidiStream ** stream;

  Pm_Initialize();

  ErlNifResourceType* streamType = (ErlNifResourceType*)enif_priv_data(env);
  if(!enif_get_resource(env, argv[0], streamType, (PortMidiStream **) &stream)) {
    return enif_make_badarg(env);
  }

  int numEvents = Pm_Read(*stream, buffer, 1);
  status = enif_make_int(env, Pm_MessageStatus(buffer[0].message));
  data1  = enif_make_int(env, Pm_MessageData1(buffer[0].message));
  data2  = enif_make_int(env, Pm_MessageData2(buffer[0].message));

  return enif_make_list3(env, status, data1, data2);
}

static ErlNifFunc nif_funcs[] = {
  {"do_open", 1, do_open},
  {"do_poll", 1, do_poll},
  {"do_read", 1, do_read}
};

ERL_NIF_INIT(Elixir.PortMidi.Nifs.Input,nif_funcs,load,NULL,NULL,NULL)

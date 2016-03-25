#include "erl_nif.h"
#include <portmidi.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

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
  if((result = findDevice(streamAlloc, deviceName, OUTPUT)) != pmNoError) {
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

static ERL_NIF_TERM do_message(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  static PortMidiStream ** stream;
  Pm_Initialize();

  ErlNifResourceType* streamType = (ErlNifResourceType*)enif_priv_data(env);
  if(!enif_get_resource(env, argv[0], streamType, (PortMidiStream **) &stream)) {
    return enif_make_badarg(env);
  }

  PmEvent event;
  ERL_NIF_TERM data = argv[1];
  ERL_NIF_TERM statusErl, noteErl, velocityErl;
  long int status, note, velocity, timestamp = 0;
  PmError writeError;
  const char * writeErrorMsg;

  enif_get_list_cell(env, data, &statusErl, &data);
  enif_get_list_cell(env, data, &noteErl, &data);
  enif_get_list_cell(env, data, &velocityErl, &data);

  enif_get_long(env, statusErl, &status);
  enif_get_long(env, noteErl, &note);
  enif_get_long(env, velocityErl, &velocity);

  if(argv[2]) {
    enif_get_long(env, argv[2], &timestamp);
  }

  event.message = Pm_Message(status, note, velocity);
  event.timestamp = timestamp;

  writeError = Pm_Write(*stream, &event, 1);

  if (writeError == pmNoError) {
    return enif_make_atom(env, "ok");
  }

  writeErrorMsg = Pm_GetErrorText(writeError);
  return enif_make_tuple2(
    env,
    enif_make_atom(env, "error"),
    enif_make_string(env, writeErrorMsg, ERL_NIF_LATIN1)
  );
}

static ErlNifFunc nif_funcs[] = {
  {"do_open", 1, do_open},
  {"do_message", 3, do_message}
};

ERL_NIF_INIT(Elixir.PortMidi.Output,nif_funcs,load,NULL,NULL,NULL)

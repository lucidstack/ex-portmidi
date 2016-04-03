#include "erl_nif.h"
#include <portmidi.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define MAXBUFLEN 1024

typedef enum {INPUT, OUTPUT} DeviceType;

PmError findDevice(PmStream **stream, char *deviceName, DeviceType type);
char* makePmErrorAtom(PmError);
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
    ERL_NIF_TERM reason = enif_make_atom(env, makePmErrorAtom(result));
    return enif_make_tuple2(env, enif_make_atom(env, "error"), reason);
  }

  streamTerm = enif_make_resource(env, streamAlloc);
  enif_keep_resource(streamAlloc);

  return enif_make_tuple2(env, enif_make_atom(env, "ok"), streamTerm);
}

static ERL_NIF_TERM do_write(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  static PortMidiStream ** stream;

  ErlNifResourceType* streamType = (ErlNifResourceType*)enif_priv_data(env);
  if(!enif_get_resource(env, argv[0], streamType, (PortMidiStream **) &stream)) {
    return enif_make_badarg(env);
  }

  int numOfErlValues;
  ERL_NIF_TERM erlMessage = argv[1];
  const ERL_NIF_TERM * erlValues;
  enif_get_tuple(env, erlMessage, &numOfErlValues, &erlValues);

  long int status, note, velocity, timestamp = 0;
  enif_get_long(env, erlValues[0], &status);
  enif_get_long(env, erlValues[1], &note);
  enif_get_long(env, erlValues[2], &velocity);

  if(argv[2]) {
    enif_get_long(env, argv[2], &timestamp);
  }

  PmEvent event;
  event.message = Pm_Message(status, note, velocity);
  event.timestamp = timestamp;

  PmError writeError;
  writeError = Pm_Write(*stream, &event, 1);

  if (writeError == pmNoError) {
    return enif_make_atom(env, "ok");
  }

  const char * writeErrorMsg;
  writeErrorMsg = Pm_GetErrorText(writeError);

  return enif_make_tuple2(
    env,
    enif_make_atom(env, "error"),
    enif_make_string(env, writeErrorMsg, ERL_NIF_LATIN1)
  );
}

static ERL_NIF_TERM do_close(ErlNifEnv* env, int arc, const ERL_NIF_TERM argv[]) {
  static PortMidiStream ** stream;

  ErlNifResourceType* streamType = (ErlNifResourceType*)enif_priv_data(env);
  if(!enif_get_resource(env, argv[0], streamType, (PortMidiStream **) &stream)) {
    return enif_make_badarg(env);
  }

  Pm_Close(*stream);

  return enif_make_atom(env, "ok");
}

static ErlNifFunc nif_funcs[] = {
  {"do_open", 1, do_open},
  {"do_write", 3, do_write},
  {"do_close", 1, do_close}
};

ERL_NIF_INIT(Elixir.PortMidi.Nifs.Output,nif_funcs,load,NULL,NULL,NULL)

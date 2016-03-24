#include "erl_nif.h"
#include <portmidi.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define MAXBUFLEN 1024

typedef unsigned char byte;

const PmDeviceInfo ** listDevices(int);

static ERL_NIF_TERM do_list(ErlNifEnv* env, int arc, const ERL_NIF_TERM argv[]) {
  ERL_NIF_TERM erlDevices[MAXBUFLEN];
  int i = 0;
  int numOfDevices = Pm_CountDevices();
  const PmDeviceInfo ** devices = listDevices(numOfDevices);

  for(i = 0; i < numOfDevices; i++) {
    ERL_NIF_TERM map = enif_make_new_map(env);
    enif_make_map_put(env, map, enif_make_atom(env, "name"), enif_make_string(env, devices[i]->name, ERL_NIF_LATIN1), &map);
    enif_make_map_put(env, map, enif_make_atom(env, "input"), enif_make_int(env, devices[i]->input), &map);
    enif_make_map_put(env, map, enif_make_atom(env, "output"), enif_make_int(env, devices[i]->output), &map);
    enif_make_map_put(env, map, enif_make_atom(env, "output"), enif_make_int(env, devices[i]->output), &map);

    erlDevices[i] = map;
  }

  return enif_make_list_from_array(env, erlDevices, numOfDevices);
}

static ErlNifFunc nif_funcs[] = {
  {"do_list", 0, do_list}
};

ERL_NIF_INIT(Elixir.PortMidi.Devices,nif_funcs,NULL,NULL,NULL,NULL)

#include "erl_nif.h"
#include <portmidi.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define MAXBUFLEN 1024

typedef unsigned char byte;

const PmDeviceInfo ** listDevices(int);

ErlNifResourceType *PM_DEVICE_RES_TYPE;
int load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info) {
  int flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;
  PM_DEVICE_RES_TYPE = enif_open_resource_type(env, NULL, "pm_device_info", NULL, flags, NULL);

  return 0;
}


static ERL_NIF_TERM do_list_devices(ErlNifEnv* env, int arc, const ERL_NIF_TERM argv[]) {
  ERL_NIF_TERM erlDevices[MAXBUFLEN];

  int numOfDevices = Pm_CountDevices();
  const PmDeviceInfo ** devices = listDevices(numOfDevices);

  for(int i = 0; i < numOfDevices; i++) {
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
  {"do_list_devices", 0, do_list_devices}
};
ERL_NIF_INIT(Elixir.PortMidi.Devices,nif_funcs,NULL,NULL,NULL,NULL)

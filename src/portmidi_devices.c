#include "erl_nif.h"
#include <portmidi.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define MAXBUFLEN 1024

typedef unsigned char byte;

const PmDeviceInfo ** listDevices(int);

static ERL_NIF_TERM do_list(ErlNifEnv* env, int arc, const ERL_NIF_TERM argv[]) {
  int i = 0;
  int numOfDevices = Pm_CountDevices();
  int numOfInputs = 0, numOfOutputs = 0;
  const PmDeviceInfo ** devices = listDevices(numOfDevices);

  ERL_NIF_TERM allDevices = enif_make_new_map(env);
  ERL_NIF_TERM inputDevices[numOfDevices];
  ERL_NIF_TERM outputDevices[numOfDevices];

  for(i = 0; i < numOfDevices; i++) {
    ERL_NIF_TERM device = enif_make_new_map(env);
    enif_make_map_put(env, device, enif_make_atom(env, "name"),   enif_make_string(env, devices[i]->name, ERL_NIF_LATIN1), &device);
    enif_make_map_put(env, device, enif_make_atom(env, "interf"), enif_make_string(env, devices[i]->interf, ERL_NIF_LATIN1), &device);
    enif_make_map_put(env, device, enif_make_atom(env, "input"),  enif_make_int(env, devices[i]->input), &device);
    enif_make_map_put(env, device, enif_make_atom(env, "output"), enif_make_int(env, devices[i]->output), &device);
    enif_make_map_put(env, device, enif_make_atom(env, "opened"), enif_make_int(env, devices[i]->opened), &device);


    if(devices[i]->input) {
      inputDevices[numOfInputs] = device;
      numOfInputs++;
    } else {
      outputDevices[numOfOutputs] = device;
      numOfOutputs++;
    }
  }

  enif_make_map_put(env, allDevices, enif_make_atom(env, "input"), enif_make_list_from_array(env, inputDevices, numOfInputs), &allDevices);
  enif_make_map_put(env, allDevices, enif_make_atom(env, "output"), enif_make_list_from_array(env, outputDevices, numOfOutputs), &allDevices);

  return allDevices;
}

static ErlNifFunc nif_funcs[] = {
  {"do_list", 0, do_list}
};

ERL_NIF_INIT(Elixir.PortMidi.Nifs.Devices,nif_funcs,NULL,NULL,NULL,NULL)

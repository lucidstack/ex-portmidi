all: port_midi_in port_midi_out

port_midi_in:
	gcc -o priv/port_midi_in src/port_midi_in.c src/erl_comm.c -lportmidi

port_midi_out:
	gcc -o priv/port_midi_out src/port_midi_out.c src/erl_comm.c -lportmidi


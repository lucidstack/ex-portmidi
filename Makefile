all: portmidi_in portmidi_out

portmidi_in:
	gcc -o priv/portmidi_in src/portmidi_in.c src/erl_comm.c -lportmidi

portmidi_out:
	gcc -o priv/portmidi_out src/portmidi_out.c src/erl_comm.c -lportmidi


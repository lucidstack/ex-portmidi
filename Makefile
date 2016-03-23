ERL_INCLUDE_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS = -g -O3 -ansi -pedantic -Wall -Wextra -I$(ERLANG_PATH)

all: priv/portmidi_in priv/portmidi_out priv/portmidi_list.so

priv/portmidi_in: src/portmidi_in.c src/portmidi_shared.c
	gcc -o priv/portmidi_in src/portmidi_in.c src/erl_comm.c src/portmidi_shared.c -lportmidi

priv/portmidi_out: src/portmidi_out.c src/portmidi_shared.c
	gcc -o priv/portmidi_out src/portmidi_out.c src/erl_comm.c src/portmidi_shared.c -lportmidi

priv/portmidi_list.so: src/portmidi_list.c src/portmidi_shared.c
	gcc -fPIC -I$(ERL_INCLUDE_PATH) -dynamiclib -undefined dynamic_lookup -o priv/portmidi_list.so -lportmidi src/portmidi_list.c src/portmidi_shared.c

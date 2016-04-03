# Changelog

## 4.1.0
* `@ 614a27e` - Opening inputs and outputs now return `{:error, reason}` if Portmidi can't open the given device. Previously, the Portmidid NIFs would just throw a bad argument error, without context. `reason` is an atom representing an error from the C library. Have a look at `src/portmidi_shared.c#makePmErrorAtom` for all possible errors.

## 4.0.0
* `@ 19ff9a8` - MIDI events from PortMidi.Input are now sent as a tuple of three values, instead of an array. This makes the API consistent with PortMidi.Output, which accepts a tuple of three elements.
* `@ 59efd17` - MIDI events are now sent with the server PID, which is returned when an input is opened (e.g. `{:ok, input} = PortMidi.open(:input, "Launchpad")`). This makes it easy to differentiate received messages, so that a process can listen on multiple MIDI devices, and be able to handle the messages differently, pattern matching on the input. The MIDI event is sent as a second tuple, e.g. `{^input, {status, note, velocity}}`.

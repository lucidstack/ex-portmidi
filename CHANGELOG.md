# Changelog

## 5.1.1

* `@ ea79492` - replace NULL with 0 when calling findDevice in C code

## 5.1.0

* `@ 1cf967b` - Add an optional `latency` argument to `PortMidi.open/2,3`. When opening an output device, a `latency` value greater than `0` has to be set, if you need to use timestamps; otherwise, these will be ignored. Kudos to [@thbar](https://github.com/thbar) for spotting this issue! 👏

## 5.0.1

* `@ 8f7c308` - Add `-std=c99` and remove unneded flags for NIFs compilation in Makefile

## 5.0.0
* `@ 147f569` - `PortMidi.Reader` now passes a `buffer_size` to the underlying nif, saving MIDI messages from being lost. This `buffer_size` is set to 256 by default, and can be configured at application level: `config :portmidi, buffer_size: 1024`
* `@ ed9e3bb` - `PortMidi.Reader` now emits messages as lists, no more as simple tuples. Sometimes there could be only one message, but a list is always returned. The tuples have also changed structure, to include timestamps, that were previously ignored: `[{{status, note1, note2}, timestamp}, ...]`
* `@ d202f7a` - `PortMidi.Writer` now accepts good old message tuples (`{status, note1, note2}`), event tuples, with timestamp (`{{status, note1, note2}, timestamp}`) or lists of event tuples (`[{{status, note1, note2}, timestamp}, ...]`). This is the preferred way for high throughput, and can be safely used as a pipe from an input device.

## 4.1.0
* `@ 614a27e` - Opening inputs and outputs now return `{:error, reason}` if Portmidi can't open the given device. Previously, the Portmidid NIFs would just throw a bad argument error, without context. `reason` is an atom representing an error from the C library. Have a look at `src/portmidi_shared.c#makePmErrorAtom` for all possible errors.

## 4.0.0
* `@ 19ff9a8` - MIDI events from PortMidi.Input are now sent as a tuple of three values, instead of an array. This makes the API consistent with PortMidi.Output, which accepts a tuple of three elements.
* `@ 59efd17` - MIDI events are now sent with the server PID, which is returned when an input is opened (e.g. `{:ok, input} = PortMidi.open(:input, "Launchpad")`). This makes it easy to differentiate received messages, so that a process can listen on multiple MIDI devices, and be able to handle the messages differently, pattern matching on the input. The MIDI event is sent as a second tuple, e.g. `{^input, {status, note, velocity}}`.

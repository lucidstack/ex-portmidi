# Changelog

## 4.0.0
* `@ 19ff9a8` MIDI events from PortMidi.Input are now sent as a tuple of three values, instead of an array. This makes the API consistent with PortMidi.Output, which accepts a tuple of three elements.
* `@ 59efd17` MIDI events are now sent with the server PID, which is returned when an input is opened (e.g. `{:ok, input} = PortMidi.open(:input, "Launchpad")`). This makes it easy to differentiate received messages, so that a process can listen on multiple MIDI devices, and be able to handle the messages differently, pattern matching on the input. The MIDI event is sent as a second tuple, e.g. `{^input, {status, note, velocity}}`.

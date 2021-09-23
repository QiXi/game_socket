<p align="center">
<a title="Pub" href="https://pub.dartlang.org/packages/game_socket"><img alt="Pub Version" src="https://img.shields.io/pub/v/game_socket?color=blue&style=for-the-badge"></a>
</p>

## Game socket
The library was published in early access and is not stable, as it is being developed in parallel with other solutions. English is not a native language so there are no comments. At this stage, the library is for those who want to understand the source code and get a starting point for their solution or help me :)


## Features
* One library contains both Server and Client parts.
* The API communication library is similar to `Socket.io`, but not compatible with this solution.
* Contains a built-in binary protocol so you don't have to work at the byte level.
* The transport layer uses `TCP`. To send game messages, it is planned to implement parallel work with `UDP`.
* It implements such concepts as Multiplexing - interaction with several spaces through a single channel.

Support for `WebSocket` is not planned for the current day (but everything can change with the support of the community)


## Examples
Examples:
* [`example/client/main.dart`](https://github.com/QiXi/game_socket/blob/master/example/client/main.dart)
* [`example/server/main.dart`](https://github.com/QiXi/game_socket/blob/master/example/server/main.dart)


## Protocol

The protocol is schematic based. This approach allows you to save the amount of data transferred, since the data type is not transferred with the message, and the length of the numbers is not serialized.

Data types used in the schema

| Type | Size | Range |
| ---- | ---- | ----- |
| bool | 1 bit | true or false |
| int8 | 1 byte | 0 to 255 |
| int16 | 2 bytes | 0 to 65535 |
| int32 | 4 bytes | 0 to 4294967295 |
| string | 1 + value | 0 to 255 chars |
| bytes | 2 + value | 0 to 65535 bytes |


Data types when writing or reading messages

| Operation | Schema Type | Dart Type | Range |
| --------- | ----------- | --------- | ----- |
| putBool   | bool   | bool| true or false |
| putInt    | int8   | int | -128 to 127 |
| putUInt   | int8   | int | 0 to 255 |
| putInt    | int16  | int | -32768 to 32767 |
| putUInt   | int16  | int | 0 to 65535 |
| putInt    | int32  | int | -2147483648 to 2147483647 |
| putUInt   | int32  | int | 0 to 4294967295 |
| putString | string | String | 0 to 255 chars |
| putSingle | ~int8~ | double | 0 to 1 step ~0.004 |
| putRadians | ~int16~ | double | step ~0.0002 |
| putPayload | bytes | Uint8List | 0 to 65535 bytes |


## Plans
* Initialization for sending `UPD` diagrams.
* Automatic connections and reconnections.
* Expanding the possibilities for working with rooms.
* Conducting stress tests.


## Tips for Beginners
* If you are developing a browser game, then you need a `WebSocket` solution.
* When designing a game for real-time communication, `UDP` should be preferred, since` TCP` will cause a delay in the event of packet loss.


## History of creation
Sources that could have influenced the development of this work:

* https://jamesslocum.com/blog
* https://github.com/socketio/engine.io-server-java
* https://github.com/socketio/socket.io-server-java/
* https://github.com/Jerenaux/binary-protocol-example
* https://github.com/rikulo/socket.io-dart/

___
If you can suggest a translation better than automatic ᕙ(☉̃ₒ☉‶)ว just do it
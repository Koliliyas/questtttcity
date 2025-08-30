import 'package:flutter/material.dart';

abstract class AudioPlayerEvent {}

class PlayTrack extends AudioPlayerEvent {
  final String url;
  final Key id;

  PlayTrack(this.url, this.id);
}

class PauseTrack extends AudioPlayerEvent {
  final Key id;

  PauseTrack(this.id);
}

class SeekTrack extends AudioPlayerEvent {
  final Duration position;
  final Key id;

  SeekTrack(this.position, this.id);
}

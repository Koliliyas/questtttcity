import 'package:flutter/material.dart';

abstract class AudioPlayerState {}

class AudioPlayerInitial extends AudioPlayerState {}

class AudioPlayerPlaying extends AudioPlayerState {
  final Key id;
  final Duration duration;
  final Duration position;

  AudioPlayerPlaying(this.id, this.duration, this.position);
}

class AudioPlayerPaused extends AudioPlayerState {
  final Key id;
  final Duration position;

  AudioPlayerPaused(this.id, this.position);
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:los_angeles_quest/features/presentation/bloc/audioplayer_event.dart';
import 'package:los_angeles_quest/features/presentation/bloc/audioplayer_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayerBloc() : super(AudioPlayerInitial()) {
    on<PlayTrack>((event, emit) async {
      if (state is AudioPlayerPlaying) {
        await _audioPlayer.stop();
      }

      await _audioPlayer.play(UrlSource(event.url));
      emit(
        AudioPlayerPlaying(event.id,
            await _audioPlayer.getDuration() ?? Duration.zero, Duration.zero),
      );

      _audioPlayer.onDurationChanged.listen((duration) {
        if (!emit.isDone) {
          emit(AudioPlayerPlaying(
              event.id,
              duration,
              state is AudioPlayerPlaying
                  ? (state as AudioPlayerPlaying).position
                  : Duration.zero));
        }
      });

      _audioPlayer.onPositionChanged.listen((position) {
        if (!emit.isDone) {
          emit(AudioPlayerPlaying(
            event.id,
            state is AudioPlayerPlaying
                ? (state as AudioPlayerPlaying).duration
                : Duration.zero,
            position,
          ));
        }
      });
    });

    on<PauseTrack>((event, emit) async {
      await _audioPlayer.pause();
      if (!emit.isDone) {
        emit(AudioPlayerPaused(
            event.id,
            state is AudioPlayerPlaying
                ? (state as AudioPlayerPlaying).position
                : Duration.zero));
      }
    });

    on<SeekTrack>((event, emit) async {
      await _audioPlayer.seek(event.position);
      if (!emit.isDone) {
        emit(AudioPlayerPlaying(
          event.id,
          state is AudioPlayerPlaying
              ? (state as AudioPlayerPlaying).duration
              : Duration.zero,
          event.position,
        ));
      }
    });
  }

  @override
  Future<void> close() async {
    await _audioPlayer.stop();
    _audioPlayer.dispose();
    return super.close();
  }
}

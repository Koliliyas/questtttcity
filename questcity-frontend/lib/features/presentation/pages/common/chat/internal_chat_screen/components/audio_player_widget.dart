import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:los_angeles_quest/features/presentation/bloc/audioplayer_bloc.dart';
import 'package:los_angeles_quest/features/presentation/bloc/audioplayer_event.dart';
import 'package:los_angeles_quest/features/presentation/bloc/audioplayer_state.dart';

class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        bool isPlaying = false;
        Duration duration = Duration.zero;
        Duration position = Duration.zero;

        if (state is AudioPlayerPlaying && state.id == key) {
          isPlaying = true;
          duration = state.duration;
          position = state.position;
        } else if (state is AudioPlayerPaused && state.id == key) {
          position = state.position;
        }

        void playPause() {
          if (isPlaying) {
            BlocProvider.of<AudioPlayerBloc>(context).add(PauseTrack(key!));
          } else {
            BlocProvider.of<AudioPlayerBloc>(context).add(
              PlayTrack(
                  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
                  key!),
            );
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RawMaterialButton(
              onPressed: playPause,
              fillColor: Colors.white,
              shape: const CircleBorder(),
              constraints: BoxConstraints(
                maxWidth: 32.w,
                maxHeight: 32.w,
                minHeight: 32.w,
                minWidth: 32.w,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.orange),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(trackHeight: 4.h),
                child: Slider(
                  activeColor: Colors.deepPurple,
                  inactiveColor: Colors.white,
                  value: position.inSeconds.toDouble() > 0
                      ? 1 / position.inSeconds.toDouble()
                      : 0,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (double value) {
                    if (duration.inSeconds > 0) {
                      BlocProvider.of<AudioPlayerBloc>(context).add(SeekTrack(
                          Duration(
                              seconds: (duration.inSeconds * value).toInt()),
                          key!));
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

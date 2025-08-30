import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/artifacts/artifact_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/artifacts/artifacts_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/features/features_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/files/files_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/tools/tool_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/tools/tools_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/cubit/artifacts_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/invite_friend_screen/cubit/invite_friend_cubit.dart';

class ArtifactsScreen extends StatelessWidget {
  const ArtifactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => ArtifactsScreenCubit(),
        child: BlocBuilder<ArtifactsScreenCubit, ArtifactsScreenState>(
          builder: (context, state) {
            ArtifactsScreenCubit cubit = context.read<ArtifactsScreenCubit>();
            return Container(
              padding: getMarginOrPadding(
                top: MediaQuery.of(context).padding.top + 24.h,
                right: 16.w,
                left: 16.w,
              ),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Paths.mockArtifactsBackgroundPath),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high),
              ),
              child: Column(
                children: [
                  if (state is! InviteFriendInvitesSended)
                    Align(
                      alignment: Alignment.topCenter,
                      child: CustomAppBar(
                          onTapBack: () => state is! ArtifactsScreenInitial
                              ? cubit.onTapBack()
                              : Navigator.pop(context),
                          title: cubit.appBarTitle),
                    ),
                  const Spacer(),
                  Center(child: _getView(cubit)),
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getView(ArtifactsScreenCubit cubit) {
    ArtifactsScreenState state = cubit.state;
    switch (cubit.state) {
      case ArtifactsScreenInitial():
        return FeaturesView(onTap: cubit.updateView);
      case final ArtifactsScreenFiles files:
        return FilesView(files: files.files);
      case ArtifactsScreenTools():
        return ToolsView(onTap: cubit.updateView);
      case ArtifactsScreenTool():
        ArtifactsScreenTool state0 = (state as ArtifactsScreenTool);
        return ToolView(
          image: state0.image,
          title: state0.title,
          collectedParts: state0.collectedParts,
        );
      case ArtifactsScreenArtifacts():
        return ArtifactsView(onTap: cubit.updateView);
      case ArtifactsScreenArtifact():
        ArtifactsScreenArtifact state0 = (state as ArtifactsScreenArtifact);
        return ArtifactView(image: state0.image);
      default:
        return Container();
    }
  }
}

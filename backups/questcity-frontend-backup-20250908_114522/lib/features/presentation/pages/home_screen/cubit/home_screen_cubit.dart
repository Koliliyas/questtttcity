import 'package:los_angeles_quest/utils/logger.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/controller/home_screen_controller.dart';

part 'home_screen_state.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  HomeScreenCubit() : super(HomeScreenInitial());

  Role? role;
  int selectedPageIndex = 0;
  List<List<Widget>> navigatorStack = [];
  List<String> iconsPaths = [];
  List<String> iconsNames = [];

  void init(Role role) async {
    try {
      if (this.role == null || this.role != role) {
        this.role = role;
        selectedPageIndex = 0;
        appLogger
            .d('🔍 DEBUG: HomeScreenCubit.init - selectedPageIndex set to 0');
        navigatorStack = HomeScreenController.getNavigationScreensList(role);
        iconsPaths = HomeScreenController.getNavigationIcons(role);
        iconsNames = HomeScreenController.getNavigationNames(role);

        // Проверяем, что все массивы имеют одинаковую длину
        if (navigatorStack.isNotEmpty &&
            navigatorStack.length == iconsPaths.length &&
            navigatorStack.length == iconsNames.length) {
          appLogger.d('✅ HomeScreen initialized successfully for role: $role');
          appLogger.d('📱 Screens count: ${navigatorStack.length}');
          appLogger.d('🎨 Icons count: ${iconsPaths.length}');
          appLogger.d('📝 Names count: ${iconsNames.length}');
        } else {
          appLogger.d('⚠️ HomeScreen initialization warning for role: $role');
          appLogger.d('📱 Screens count: ${navigatorStack.length}');
          appLogger.d('🎨 Icons count: ${iconsPaths.length}');
          appLogger.d('📝 Names count: ${iconsNames.length}');
        }
      }
    } catch (e) {
      appLogger.d('❌ Error initializing HomeScreen for role $role: $e');
      // Fallback to default values
      this.role = role;
      selectedPageIndex = 0;
      navigatorStack = [];
      iconsPaths = [];
      iconsNames = [];
    }
  }

  updateIconsLanguage() {
    iconsNames = HomeScreenController.getNavigationNames(role);
    emit(HomeScreenUpdating());
    emit(HomeScreenInitial());
  }

  onTab1ScreenOpen(dynamic screen) {
    if (navigatorStack.isNotEmpty && navigatorStack.length > 0) {
      navigatorStack[0].add(screen);
      appLogger.d(navigatorStack[0]);
      emit(HomeScreenUpdating());
      emit(HomeScreenInitial());
    }
  }

  onTab2ScreenOpen(dynamic screen) {
    if (navigatorStack.isNotEmpty && navigatorStack.length > 1) {
      navigatorStack[1].add(screen);
      appLogger.d(navigatorStack[1]);
      emit(HomeScreenUpdating());
      emit(HomeScreenInitial());
    }
  }

  onTab3ScreenOpen(dynamic screen) {
    if (navigatorStack.isNotEmpty && navigatorStack.length > 2) {
      navigatorStack[2].add(screen);
      appLogger.d(navigatorStack[2]);
      emit(HomeScreenUpdating());
      emit(HomeScreenInitial());
    }
  }

  onTab4ScreenOpen(dynamic screen) {
    if (navigatorStack.isNotEmpty && navigatorStack.length > 3) {
      navigatorStack[3].add(screen);
      appLogger.d(navigatorStack[3]);
      emit(HomeScreenUpdating());
      emit(HomeScreenInitial());
    }
  }

  onRemoveLastRoute() {
    if (selectedPageIndex >= 0 &&
        selectedPageIndex < navigatorStack.length &&
        navigatorStack[selectedPageIndex].length > 1) {
      navigatorStack[selectedPageIndex].removeLast();
      appLogger.d(navigatorStack[selectedPageIndex]);
      emit(HomeScreenUpdating());
      emit(HomeScreenInitial());
    }
  }

  onRemoveAllRoutesInStack(int index) {
    if (index >= 0 &&
        index < navigatorStack.length &&
        navigatorStack[index].isNotEmpty) {
      navigatorStack[index] = [navigatorStack[index].first];
      appLogger.d(navigatorStack[index]);
      emit(HomeScreenUpdating());
      emit(HomeScreenInitial());
    }
  }

  onChangePage(index) {
    appLogger.d('🔍 DEBUG: onChangePage called with index: $index');
    appLogger.d('🔍 DEBUG: current selectedPageIndex: $selectedPageIndex');
    appLogger.d('🔍 DEBUG: navigatorStack.length: ${navigatorStack.length}');

    if (index >= 0 && index < navigatorStack.length) {
      if (selectedPageIndex == index && navigatorStack[index].length == 1) {
        appLogger.d('🔍 DEBUG: Same page, returning early');
        return;
      }
      onRemoveAllRoutesInStack(index);
      selectedPageIndex = index;
      appLogger.d('🔍 DEBUG: selectedPageIndex updated to: $selectedPageIndex');
      emit(HomeScreenUpdating());
      emit(HomeScreenInitial());
    } else {
      appLogger.d('🔍 DEBUG: Invalid index $index, ignoring');
    }
  }

  reset() {
    role = null;
    selectedPageIndex = 0;
  }
}

enum Role { USER, MANAGER, ADMIN }

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/core/network/http_client.dart';
import 'package:los_angeles_quest/features/data/datasources/auth_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/datasources/auth/auth_remote_data_source_new.dart';
import 'package:los_angeles_quest/features/data/datasources/category_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/datasources/chat_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/datasources/file_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/datasources/person_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/datasources/quest_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/datasources/quest_detail_remote_data_source.dart';
import 'package:los_angeles_quest/features/data/datasources/unlock_requests_datasource.dart';
import 'package:los_angeles_quest/features/data/datasources/user_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/datasources/web_socket_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/repositories/auth_repository_impl.dart';
import 'package:los_angeles_quest/features/data/repositories/auth_repository_new_impl.dart';
import 'package:los_angeles_quest/features/data/repositories/category_repository_impl.dart';
import 'package:los_angeles_quest/features/data/repositories/chat_repository_impl.dart';
import 'package:los_angeles_quest/features/data/repositories/file_repository_impl.dart';
import 'package:los_angeles_quest/features/data/repositories/friends_repository.dart';
import 'package:los_angeles_quest/features/data/repositories/person_repository_impl.dart';
import 'package:los_angeles_quest/features/data/repositories/quest_repository_impl.dart';
import 'package:los_angeles_quest/features/data/repositories/quest_detail_repository_impl.dart';
import 'package:los_angeles_quest/features/data/repositories/unlock_request_repository.dart';
import 'package:los_angeles_quest/features/data/repositories/user_repository_impl.dart';
import 'package:los_angeles_quest/features/data/repositories/web_socket_repository_impl.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository_new.dart';
import 'package:los_angeles_quest/features/domain/repositories/category_repository.dart';
import 'package:los_angeles_quest/features/domain/repositories/chat_repository.dart';
import 'package:los_angeles_quest/features/domain/repositories/file_repository.dart';
import 'package:los_angeles_quest/features/domain/repositories/person_repository.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_detail_repository.dart';
import 'package:los_angeles_quest/features/domain/repositories/user_repository.dart';
import 'package:los_angeles_quest/features/domain/repositories/web_socket_repository.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/auth_login.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/auth_login_new.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/auth_register_new.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/get_access_token.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/refresh_tokens.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/auth_register.dart';
import 'package:los_angeles_quest/features/presentation/bloc/auth_new/auth_cubit.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/get_verification_code.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/reload_token.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/reset_password.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/verify_code.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/verify_reset_password.dart';
import 'package:los_angeles_quest/features/domain/usecases/category/create_category.dart';
import 'package:los_angeles_quest/features/domain/usecases/category/get_all_categories.dart';
import 'package:los_angeles_quest/features/domain/usecases/category/update_category.dart';
import 'package:los_angeles_quest/features/domain/usecases/chat/get_all_chats.dart';
import 'package:los_angeles_quest/features/domain/usecases/chat/get_chat_messages.dart';
import 'package:los_angeles_quest/features/domain/usecases/file/get_file.dart';
import 'package:los_angeles_quest/features/domain/usecases/file/upload_file.dart';
import 'package:los_angeles_quest/core/language_cubit/language_cubit_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/bloc/audioplayer_bloc.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_bottom_sheet_template/cubit/custom_bottom_sheet_template_cubit.dart';
import 'package:los_angeles_quest/features/domain/usecases/person/delete_me.dart';
import 'package:los_angeles_quest/features/domain/usecases/person/get_me.dart';
import 'package:los_angeles_quest/features/domain/usecases/person/get_notifications.dart';
import 'package:los_angeles_quest/features/domain/usecases/person/update_me.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/create_quest.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_all_quests_admin.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_all_quests.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/create_quest_admin.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/update_quest_admin.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_quest_admin.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_levels.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_miles.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_places.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_prices.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_quest.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/update_quest.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_vehicles.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_quest_detail.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/delete_quest.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_quest_analytics.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/bulk_action_quests.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/ban_user.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/create_user.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/edit_user.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/get_all_users.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/unlock_requests.dart';
import 'package:los_angeles_quest/features/domain/usecases/websocket/connect_web_socket.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/category_create_screen/cubit/category_create_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/users_screen/cubit/users_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quests_list_screen/cubit/quests_list_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_create_screen/cubit/quest_create_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quests_analytics_screen/cubit/quests_analytics_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/cubit/account_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/chat_screen/cubit/chat_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/cubit/internal_chat_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/cubit/edit_quest_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/cubit/quests_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/cubit/settings_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/enter_the_code_screen/cubit/enter_the_code_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/forget_password_screen/cubit/forget_password_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/login_screen/cubit/login_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/new_password_screen/cubit/new_password_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/sign_in_screen/cubit/sign_in_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/cubit/friends_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/splash_screen/cubit/splash_screen_cubit.dart';
import 'package:los_angeles_quest/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/data/datasources/friends_datasource.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC / Cubit
  sl.registerFactory(() => LoginScreenCubit(
      authLogin: sl<AuthLogin>(),
      getMe: sl<GetMe>(),
      getVerificationCode: sl<GetVerificationCode>(),
      sharedPreferences: sl<SharedPreferences>(),
      firebaseMessaging: sl<FirebaseMessaging>(),
      repository: sl<AuthRepository>(),
      authNewCubit: sl<AuthNewCubit>()));
  sl.registerFactory(() => SignInScreenCubit(
        authRegister: sl<AuthRegister>(),
      ));
  sl.registerFactory(() => ForgetPasswordScreenCubit(
        resetPassword: sl<ResetPassword>(),
      ));
  sl.registerFactory(() => EnterTheCodeScreenCubit(
        email: '',
        password: '',
        authLogin: sl<AuthLogin>(),
        verifyCode: sl<VerifyCode>(),
        verifyResetPassword: sl<VerifyResetPassword>(),
        getMe: sl<GetMe>(),
        updateMe: sl<UpdateMe>(),
        firebaseMessaging: sl<FirebaseMessaging>(),
      ));
  sl.registerFactory(() => NewPasswordScreenCubit(
        email: '',
        verifyResetPassword: sl<VerifyResetPassword>(),
      ));
  sl.registerFactory(() => ChatScreenCubit(
        getAllChats: sl<GetAllChats>(),
        webSocketConnect: sl<WebSocketConnect>(),
        webSocketDisconnect: sl<WebSocketDisconnect>(),
        webSocketReceiveMessages: sl<WebSocketReceiveMessages>(),
        webSocketSendMessage: sl<WebSocketSendMessage>(),
        sharedPreferences: sl<SharedPreferences>(),
      ));
  sl.registerFactory(() => InternalChatScreenCubit(
        getChatMessages: sl<GetChatMessages>(),
      ));
  sl.registerFactory(() => SplashScreenCubit(
        getMe: sl<GetMe>(),
        sharedPreferences: sl<SharedPreferences>(),
        secureStorage: sl<FlutterSecureStorage>(),
        reloadToken: sl<ReloadToken>(),
      ));
  sl.registerFactory(() => UsersScreenCubit(
        getAllUsersUC: sl<GetAllUsers>(),
        banUserUC: sl<BanUser>(),
        getUnlockRequests: sl<UnlockRequests>(),
      ));
  sl.registerFactory(() => UnlockRequests(sl<UnlockRequestRepository>()));
  sl.registerFactory(() =>
      UnlockRequestRepository(dataSource: sl<UnlockRequestsDatasource>()));
  sl.registerFactory(() => UnlockRequestsDatasource(
      secureStorage: sl<FlutterSecureStorage>(), client: sl<http.Client>()));
  sl.registerFactory(() => AccountScreenCubit(
      getMe: sl<GetMe>(),
      banUser: sl<BanUser>(),
      updateMe: sl<UpdateMe>(),
      sharedPreferences: sl<SharedPreferences>(),
      createUser: sl<CreateUser>(),
      editUser: sl<EditUser>(),
      secureStorage: sl<FlutterSecureStorage>()));
  sl.registerFactory(() => SettingsScreenCubit(
        getMe: sl<GetMe>(),
      ));
  sl.registerFactory(() => QuestsScreenCubit(
        getAllCategoriesUC: sl.get<GetAllCategories>(),
        getAllQuestsUC: sl.get<
            GetAllQuests>(), // ✅ Используем правильный use case для обычных пользователей
      ));
  sl.registerFactory(() => CategoryCreateScreenCubit(
        createCategoryUC: sl<CreateCategory>(),
        updateCategoryUC: sl<UpdateCategory>(),
        uploadFileUC: sl<UploadFile>(),
      ));
  sl.registerFactory<QuestsListScreenCubit>(() => QuestsListScreenCubit(
        getQuestsUC: sl.get<GetAllQuestsAdmin>(),
        deleteQuestUC: sl.get<DeleteQuest>(),
      ));
  sl.registerFactory<QuestsAnalyticsScreenCubit>(
      () => QuestsAnalyticsScreenCubit(
            getQuestAnalyticsUC: sl.get<GetQuestAnalytics>(),
          ));
  sl.registerFactory<QuestCreateScreenCubit>(() => QuestCreateScreenCubit(
        createQuestUC: sl.get<CreateQuestAdmin>(),
        uploadFileUC: sl.get<UploadFile>(),
      ));

  // QuestEditScreenCubit не регистрируем в DI, так как questId должен передаваться через параметры
  // sl.registerFactory<QuestEditScreenCubit>(() => QuestEditScreenCubit(...));
  sl.registerFactory(() => EditQuestScreenCubit(
        getLevelsUC: sl<GetLevels>(),
        getMilesUC: sl<GetMiles>(),
        getPlacesUC: sl<GetPlaces>(),
        getPricesUC: sl<GetPrices>(),
        getVehiclesUC: sl<GetVehicles>(),
        getQuestUC: sl<GetQuest>(),
        updateQuestUC: sl<UpdateQuest>(),
        createQuestUC: sl<CreateQuest>(),
      ));

  sl.registerFactory(() => FriendsScreenCubit(
        sl<FriendsRepository>(),
      ));

  // Missing Cubits
  sl.registerFactory(() => LanguageCubit());
  sl.registerFactory(() => CustomBottomSheetTemplateCubit());
  sl.registerFactory(() => HomeScreenCubit());
  sl.registerFactory(() => AudioPlayerBloc());

  sl.registerFactory<FriendsRepository>(() => FriendsRepositoryImpl(
        remoteDataSource: sl<FriendsDatasource>(),
      ));

  sl.registerFactory<FriendsDatasource>(() => FriendsDatasourceImpl(
        secureStorage: sl<FlutterSecureStorage>(),
        client: sl<http.Client>(),
      ));

  // UseCases
  sl.registerLazySingleton(() => AuthLogin(sl<AuthRepository>()));
  sl.registerLazySingleton(() => AuthRegister(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetVerificationCode(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyCode(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ReloadToken(sl<AuthRepository>()));
  sl.registerLazySingleton(() => DeleteMe(sl<PersonRepository>()));
  sl.registerLazySingleton(() => GetMe(sl<PersonRepository>()));
  sl.registerLazySingleton(() => UpdateMe(sl<PersonRepository>()));
  sl.registerLazySingleton(() => GetNotifications(sl<PersonRepository>()));
  sl.registerLazySingleton(() => VerifyResetPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetAllChats(sl<ChatRepository>()));
  sl.registerLazySingleton(() => GetChatMessages(sl<ChatRepository>()));
  sl.registerLazySingleton(() => GetAllUsers(sl<UserRepository>()));
  sl.registerFactory(() => CreateUser(sl<UserRepository>()));
  sl.registerFactory(() => EditUser(sl<UserRepository>()));
  sl.registerLazySingleton(() => BanUser(sl<UserRepository>()));
  sl.registerLazySingleton(() => GetAllCategories(sl<CategoryRepository>()));
  sl.registerLazySingleton(() => CreateCategory(sl<CategoryRepository>()));
  sl.registerLazySingleton(() => UpdateCategory(sl<CategoryRepository>()));
  sl.registerLazySingleton(() => UploadFile(sl<FileRepository>()));
  sl.registerLazySingleton(() => GetFile(sl<FileRepository>()));
  sl.registerLazySingleton(() => GetAllQuestsAdmin(sl<QuestRepository>()));
  sl.registerLazySingleton(() =>
      GetAllQuests(sl<QuestRepository>())); // ✅ Регистрируем новый use case
  sl.registerLazySingleton(() => CreateQuestAdmin(sl<QuestRepository>()));
  sl.registerLazySingleton(() => UpdateQuestAdmin(sl<QuestRepository>()));
  sl.registerLazySingleton(() => GetQuestAdmin(sl<QuestRepository>()));
  sl.registerLazySingleton(() => GetQuest(sl<QuestRepository>()));
  sl.registerLazySingleton(() => CreateQuest(sl<QuestRepository>()));
  sl.registerLazySingleton(() => UpdateQuest(sl<QuestRepository>()));
  sl.registerLazySingleton(() => DeleteQuest(sl<QuestRepository>()));
  sl.registerLazySingleton(() => GetQuestAnalytics(sl<QuestRepository>()));
  sl.registerLazySingleton(() => BulkActionQuests(sl<QuestRepository>()));
  sl.registerLazySingleton(() => GetLevels(sl<QuestRepository>()));
  sl.registerLazySingleton(() => GetPlaces(sl<QuestRepository>()));
  sl.registerLazySingleton(() => GetPrices(sl<QuestRepository>()));
  sl.registerLazySingleton(() => GetVehicles(sl<QuestRepository>()));
  sl.registerLazySingleton(() => GetMiles(sl<QuestRepository>()));
  sl.registerLazySingleton(() => GetQuestDetail(sl<QuestDetailRepository>()));
  sl.registerLazySingleton(
      () => WebSocketSendMessage(sl<WebSocketRepository>()));
  sl.registerLazySingleton(
      () => WebSocketReceiveMessages(sl<WebSocketRepository>()));
  sl.registerLazySingleton(() => WebSocketConnect(sl<WebSocketRepository>()));
  sl.registerLazySingleton(
      () => WebSocketDisconnect(sl<WebSocketRepository>()));

  // New Auth UseCases
  sl.registerLazySingleton(() => AuthLoginNew(sl<AuthRepositoryNew>()));
  sl.registerLazySingleton(() => AuthRegisterNew(sl<AuthRepositoryNew>()));
  sl.registerLazySingleton(() => GetAccessToken(sl<AuthRepositoryNew>()));
  sl.registerLazySingleton(() => RefreshTokens(sl<AuthRepositoryNew>()));

  // New Auth Cubit
  sl.registerFactory(() => AuthNewCubit(
        authLoginNew: sl<AuthLoginNew>(),
        authRegisterNew: sl<AuthRegisterNew>(),
        getAccessToken: sl<GetAccessToken>(),
        refreshTokens: sl<RefreshTokens>(),
      ));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl<AuthRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<PersonRepository>(
    () => PersonRepositoryImpl(
      personRemoteDataSource: sl<PersonRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      chatRemoteDataSource: sl<ChatRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      userRemoteDataSource: sl<UserRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      categoryRemoteDataSource: sl<CategoryRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<FileRepository>(
    () => FileRepositoryImpl(
      fileRemoteDataSource: sl<FileRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<WebSocketRepository>(() => WebSocketRepositoryImpl(
        webSocketRemoteDataSource: sl<WebSocketRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ));
  sl.registerLazySingleton<QuestRepository>(
    () => QuestRepositoryImpl(
      questRemoteDataSource: sl<QuestRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<QuestDetailRepository>(
    () => QuestDetailRepositoryImpl(
      sl<QuestDetailRemoteDataSource>(),
    ),
  );

  // New Auth Repository
  sl.registerLazySingleton<AuthRepositoryNew>(
    () => AuthRepositoryNewImpl(
      remoteDataSource: sl<AuthRemoteDataSourceNew>(),
      secureStorage: sl<FlutterSecureStorage>(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
        client: sl<http.Client>(), secureStorage: sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<AuthRemoteDataSourceNew>(
    () => AuthRemoteDataSourceNewImpl(
      httpClient: sl<CustomHttpClient>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<PersonRemoteDataSource>(
    () => PersonRemoteDataSourceImpl(
        client: sl<http.Client>(), secureStorage: sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
        client: sl<http.Client>(), secureStorage: sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(
        client: sl<http.Client>(), secureStorage: sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(
        client: sl<http.Client>(), secureStorage: sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<FileRemoteDataSource>(
    () => FileRemoteDataSourceImpl(
        client: sl<http.Client>(), secureStorage: sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<WebSocketRemoteDataSource>(
    () => WebSocketRemoteDataSourceImpl(
        secureStorage: sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<QuestRemoteDataSource>(
    () => QuestRemoteDataSourceImpl(
        client: sl<http.Client>(), secureStorage: sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<QuestDetailRemoteDataSource>(
    () => QuestDetailRemoteDataSource(),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
  );
  sl.registerLazySingleton<CustomHttpClient>(
    () => CustomHttpClient(),
  );

  // External
  await dotenv.load(fileName: ".env");

  final firebase = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  final sharedPreferences = await SharedPreferences.getInstance();

  await EasyLocalization.ensureInitialized();

  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
  sl.registerLazySingleton<FirebaseApp>(() => firebase);
  sl.registerLazySingleton<FirebaseMessaging>(() => firebaseMessaging);
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker());
}

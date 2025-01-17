// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/permissions.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/mini_overlay_machine.dart';

/// @nodoc
class ZegoLiveConnectManager {
  ZegoLiveConnectManager({
    required this.hostManager,
    required this.liveStatusNotifier,
    required this.config,
    required this.translationText,
    this.contextQuery,
  }) {
    listenStream();
  }

  BuildContext Function()? contextQuery;

  final ZegoLiveHostManager hostManager;
  final ValueNotifier<LiveStatus> liveStatusNotifier;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoInnerText translationText;

  bool _initialized = false;

  /// internal variables

  /// audience: current audience connection state, audience or co-host
  final audienceLocalConnectStateNotifier =
      ValueNotifier<ConnectState>(ConnectState.idle);

  /// for host: current requesting co-host's users
  final requestCoHostUsersNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);

  /// When the UI is minimized, and the audience receives a co-hosting invitation.
  ZegoUIKitUser? inviterOfInvitedToJoinCoHostInMinimizing;

  ///
  bool isInvitedToJoinCoHostDlgVisible = false;
  bool isEndCoHostDialogVisible = false;

  /// co-host total count
  final coHostCount = ValueNotifier<int>(0);

  int get maxCoHostCount => config.maxCoHostCount;

  bool get isMaxCoHostReached => coHostCount.value >= config.maxCoHostCount;

  List<String> audienceIDsOfInvitingConnect = [];
  List<StreamSubscription<dynamic>?> subscriptions = [];

  bool isCoHost(ZegoUIKitUser user) {
    if (hostManager.notifier.value?.id == user.id) {
      /// host also open camera/microphone
      return false;
    }

    return ZegoUIKit().getCameraStateNotifier(user.id).value ||
        ZegoUIKit().getMicrophoneStateNotifier(user.id).value;
  }

  void init() {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live streaming',
        subTag: 'seat manager',
      );

      return;
    }

    _initialized = true;

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (ZegoLiveStreamingRole.host == config.role &&
        hostManager.notifier.value != null &&
        hostManager.notifier.value!.id != ZegoUIKit().getLocalUser().id) {
      ZegoLoggerService.logInfo(
        'switch local to be co-host',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      updateAudienceConnectState(ConnectState.idle);
    }

    initCoHostMixin();
  }

  void uninit() {
    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live streaming',
        subTag: 'seat manager',
      );

      return;
    }

    _initialized = false;

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    audienceLocalConnectStateNotifier.value = ConnectState.idle;
    requestCoHostUsersNotifier.value = [];
    inviterOfInvitedToJoinCoHostInMinimizing = null;
    isInvitedToJoinCoHostDlgVisible = false;
    isEndCoHostDialogVisible = false;
    audienceIDsOfInvitingConnect.clear();

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  void listenStream() {
    if (config.plugins.isNotEmpty) {
      subscriptions
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationReceivedStream()
            .where((param) => ZegoInvitationTypeExtension.isCoHostType(
                (param['type'] as int?) ?? -1))
            .listen(onInvitationReceived))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationAcceptedStream()
            .where((param) => ZegoInvitationTypeExtension.isCoHostType(
                (param['type'] as int?) ?? -1))
            .listen(onInvitationAccepted))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationCanceledStream()
            .where((param) => ZegoInvitationTypeExtension.isCoHostType(
                (param['type'] as int?) ?? -1))
            .listen(onInvitationCanceled))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationRefusedStream()
            .where((param) => ZegoInvitationTypeExtension.isCoHostType(
                (param['type'] as int?) ?? -1))
            .listen(onInvitationRefused))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationTimeoutStream()
            .where((param) => ZegoInvitationTypeExtension.isCoHostType(
                (param['type'] as int?) ?? -1))
            .listen(onInvitationTimeout))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationResponseTimeoutStream()
            .where((param) => ZegoInvitationTypeExtension.isCoHostType(
                (param['type'] as int?) ?? -1))
            .listen(onInvitationResponseTimeout));
    }
  }

  Future<bool> kickCoHost(ZegoUIKitUser coHost) async {
    ZegoLoggerService.logInfo(
      'kick-out co-host $coHost',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    return ZegoUIKit()
        .getSignalingPlugin()
        .sendInvitation(
          inviterName: ZegoUIKit().getLocalUser().name,
          invitees: [coHost.id],
          timeout: 60,
          type: ZegoInvitationType.removeFromCoHost.value,
          data: '',
        )
        .then((result) {
      ZegoLoggerService.logInfo(
        'kick co-host ${coHost.id} ${coHost.name}, result:$result',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      return result.error == null;
    });
  }

  Future<void> inviteAudienceConnect(ZegoUIKitUser invitee) async {
    ZegoLoggerService.logInfo(
      'invite audience connect, ${invitee.id} ${invitee.name}',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (audienceIDsOfInvitingConnect.contains(invitee.id)) {
      ZegoLoggerService.logInfo(
        'audience is int connect inviting',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      return;
    }

    audienceIDsOfInvitingConnect.add(invitee.id);

    await ZegoUIKit()
        .getSignalingPlugin()
        .sendInvitation(
          inviterName: ZegoUIKit().getLocalUser().name,
          invitees: [invitee.id],
          timeout: 60,
          type: ZegoInvitationType.inviteToJoinCoHost.value,
          data: '',
        )
        .then((result) {
      if (result.error != null) {
        audienceIDsOfInvitingConnect.remove(invitee.id);

        showError(translationText.inviteCoHostFailedToast);
      }
    });
  }

  void coHostEndConnect() {
    ZegoLoggerService.logInfo(
      'co-host end connect',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    updateAudienceConnectState(ConnectState.idle);
  }

  void onInvitationReceived(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final int type = params['type']!; // call type
    final String data = params['data']!; // extended field

    final invitationType = ZegoInvitationTypeExtension.mapValue[type]!;

    ZegoLoggerService.logInfo(
      'on invitation received, data:$inviter,'
      ' $type($invitationType) $data',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (hostManager.isLocalHost) {
      if (ZegoInvitationType.requestCoHost == invitationType) {
        final translation = translationText.receivedCoHostRequestDialogInfo;
        requestCoHostUsersNotifier.value =
            List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
              ..add(inviter);

        showSuccess(translation.message
            .replaceFirst(translationText.param_1, inviter.name));
      }
    } else {
      if (ZegoInvitationType.inviteToJoinCoHost == invitationType) {
        onAudienceReceivedCoHostInvitation(inviter);
      } else if (ZegoInvitationType.removeFromCoHost == invitationType) {
        updateAudienceConnectState(ConnectState.idle);
      }
    }
  }

  List<Permission> getCoHostPermissions() {
    final permissions = <Permission>[];
    if (config.turnOnCameraWhenCohosted) {
      permissions.add(Permission.camera);
    }

    permissions.add(Permission.microphone);

    return permissions;
  }

  void onAudienceReceivedCoHostInvitation(ZegoUIKitUser host) {
    if (isInvitedToJoinCoHostDlgVisible) {
      ZegoLoggerService.logInfo(
        'invite to join co-host dialog is visible',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      return;
    }

    if (isCoHost(ZegoUIKit().getLocalUser())) {
      ZegoLoggerService.logInfo(
        'audience is co-host now',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      return;
    }

    if (isMaxCoHostReached) {
      config.onMaxCoHostReached?.call(config.maxCoHostCount);

      ZegoLoggerService.logInfo(
        'co-host max count had reached, ignore current co-host invitation',
        tag: 'live streaming',
        subTag: 'connect manager',
      );

      return;
    }

    inviterOfInvitedToJoinCoHostInMinimizing = null;
    if (PrebuiltLiveStreamingMiniOverlayPageState.minimizing ==
        ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().state()) {
      ZegoLoggerService.logInfo(
        'is minimizing now, cache the inviter:$host',
        tag: 'live streaming',
        subTag: 'connect manager',
      );

      inviterOfInvitedToJoinCoHostInMinimizing = host;
    } else {
      final translation = translationText.receivedCoHostInvitationDialogInfo;
      isInvitedToJoinCoHostDlgVisible = true;

      /// not in minimizing
      showLiveDialog(
        context: contextQuery!(),
        title: translation.title,
        content: translation.message,
        leftButtonText: translation.cancelButtonName,
        rootNavigator: config.rootNavigator,
        leftButtonCallback: () {
          isInvitedToJoinCoHostDlgVisible = false;

          if (LiveStatus.living == liveStatusNotifier.value) {
            ZegoUIKit()
                .getSignalingPlugin()
                .refuseInvitation(inviterID: host.id, data: '')
                .then((result) {
              ZegoLoggerService.logInfo(
                'refuse co-host invite, result:$result',
                tag: 'live streaming',
                subTag: 'connect manager',
              );
            });
          } else {
            ZegoLoggerService.logInfo(
              'refuse co-host invite, not living now',
              tag: 'live streaming',
              subTag: 'connect manager',
            );
          }

          Navigator.of(
            contextQuery!(),
            rootNavigator: config.rootNavigator,
          ).pop();
        },
        rightButtonText: translation.confirmButtonName,
        rightButtonCallback: () {
          isInvitedToJoinCoHostDlgVisible = false;

          do {
            if (isMaxCoHostReached) {
              config.onMaxCoHostReached?.call(config.maxCoHostCount);

              ZegoLoggerService.logInfo(
                'co-host max count had reached, ignore current accept co-host invite',
                tag: 'live streaming',
                subTag: 'connect manager',
              );

              break;
            }

            ZegoLoggerService.logInfo(
              'accept co-host invite',
              tag: 'live streaming',
              subTag: 'connect manager',
            );
            if (LiveStatus.living == liveStatusNotifier.value) {
              ZegoUIKit()
                  .getSignalingPlugin()
                  .acceptInvitation(inviterID: host.id, data: '')
                  .then((result) {
                ZegoLoggerService.logInfo(
                  'accept co-host invite, result:$result',
                  tag: 'live streaming',
                  subTag: 'connect manager',
                );

                if (result.error != null) {
                  showError('${result.error}');
                  return;
                }

                requestPermissions(
                  context: contextQuery!(),
                  isShowDialog: true,
                  translationText: translationText,
                  rootNavigator: config.rootNavigator,
                ).then((_) {
                  updateAudienceConnectState(ConnectState.connected);
                });
              });
            } else {
              ZegoLoggerService.logInfo(
                'accept co-host invite, not living now',
                tag: 'live streaming',
                subTag: 'connect manager',
              );
            }
          } while (false);

          Navigator.of(
            contextQuery!(),
            rootNavigator: config.rootNavigator,
          ).pop();
        },
      );
    }
  }

  void onInvitationAccepted(Map<String, dynamic> params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation accepted, invitee:$invitee, data:$data',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (hostManager.isLocalHost) {
      audienceIDsOfInvitingConnect.remove(invitee.id);
    } else {
      final permissions = getCoHostPermissions();
      requestPermissions(
        context: contextQuery!(),
        isShowDialog: true,
        translationText: translationText,
        rootNavigator: config.rootNavigator,
        permissions: permissions,
      ).then((value) {
        ZegoUIKit().turnCameraOn(config.turnOnCameraWhenCohosted);
        ZegoUIKit().turnMicrophoneOn(true);

        updateAudienceConnectState(ConnectState.connected);
      });
    }
  }

  void onInvitationCanceled(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation canceled, data:$inviter, $data',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (hostManager.isLocalHost) {
      requestCoHostUsersNotifier.value =
          List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
            ..removeWhere((user) => user.id == inviter.id);
    }
  }

  void onInvitationRefused(Map<String, dynamic> params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation refused, data: $data, invitee:$invitee',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (hostManager.isLocalHost) {
      audienceIDsOfInvitingConnect.remove(invitee.id);

      showError(translationText.audienceRejectInvitationToast.replaceFirst(
        translationText.param_1,
        ZegoUIKit().getUser(invitee.id).name,
      ));
    } else {
      showError(translationText.hostRejectCoHostRequestToast);
      updateAudienceConnectState(ConnectState.idle);
    }
  }

  void onInvitationTimeout(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation timeout, inviter:$inviter, data:$data',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (hostManager.isLocalHost) {
      requestCoHostUsersNotifier.value =
          List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
            ..removeWhere((user) => user.id == inviter.id);
    } else {
      inviterOfInvitedToJoinCoHostInMinimizing = null;

      /// hide invite join co-host dialog
      if (isInvitedToJoinCoHostDlgVisible) {
        isInvitedToJoinCoHostDlgVisible = false;
        Navigator.of(
          contextQuery!(),
          rootNavigator: config.rootNavigator,
        ).pop();
      }
    }
  }

  void onInvitationResponseTimeout(Map<String, dynamic> params) {
    final List<ZegoUIKitUser> invitees = params['invitees']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation response timeout, data: $data, '
      'invitees:${invitees.map((e) => e.toString())}',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (hostManager.isLocalHost) {
      for (final invitee in invitees) {
        audienceIDsOfInvitingConnect.remove(invitee.id);
      }
    } else {
      updateAudienceConnectState(ConnectState.idle);
    }
  }

  void removeRequestCoHostUsers(ZegoUIKitUser targetUser) {
    requestCoHostUsersNotifier.value =
        List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
          ..removeWhere((user) => user.id == targetUser.id);
  }

  void coHostRequestToEnd() {
    if (isEndCoHostDialogVisible) {
      ZegoLoggerService.logInfo(
        'end host dialog is visible',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      return;
    }

    isEndCoHostDialogVisible = true;
    showLiveDialog(
      context: contextQuery!(),
      rootNavigator: config.rootNavigator,
      title: translationText.endConnectionDialogInfo.title,
      content: translationText.endConnectionDialogInfo.message,
      leftButtonText: translationText.endConnectionDialogInfo.cancelButtonName,
      leftButtonCallback: () {
        isEndCoHostDialogVisible = false;
        //  pop this dialog
        Navigator.of(
          contextQuery!(),
          rootNavigator: config.rootNavigator,
        ).pop(false);
      },
      rightButtonText:
          translationText.endConnectionDialogInfo.confirmButtonName,
      rightButtonCallback: () {
        isEndCoHostDialogVisible = false;
        Navigator.of(
          contextQuery!(),
          rootNavigator: config.rootNavigator,
        ).pop(true);

        coHostEndConnect();
      },
    );
  }

  void updateAudienceConnectState(ConnectState state) {
    if (state == audienceLocalConnectStateNotifier.value) {
      ZegoLoggerService.logInfo(
        'audience connect state is same: $state',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'update audience connect state: $state',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    switch (state) {
      case ConnectState.idle:
        ZegoUIKit()
            .getLocalUser()
            .camera
            .removeListener(onLocalCameraStateChanged);
        ZegoUIKit()
            .getLocalUser()
            .microphone
            .removeListener(onLocalMicrophoneStateChanged);

        ZegoUIKit().resetSoundEffect();
        ZegoUIKit().resetBeautyEffect();

        ZegoUIKit().turnCameraOn(false);
        ZegoUIKit().turnMicrophoneOn(false);

        /// hide invite join co-host dialog
        if (isInvitedToJoinCoHostDlgVisible) {
          isInvitedToJoinCoHostDlgVisible = false;
          Navigator.of(
            contextQuery!(),
            rootNavigator: config.rootNavigator,
          ).pop();
        }

        /// hide co-host end request dialog
        if (isEndCoHostDialogVisible) {
          isEndCoHostDialogVisible = false;
          Navigator.of(
            contextQuery!(),
            rootNavigator: config.rootNavigator,
          ).pop();
        }
        break;
      case ConnectState.connecting:
        break;
      case ConnectState.connected:
        ZegoUIKit().turnCameraOn(config.turnOnCameraWhenCohosted);
        ZegoUIKit().turnMicrophoneOn(true);

        ZegoUIKit()
            .getLocalUser()
            .camera
            .addListener(onLocalCameraStateChanged);
        ZegoUIKit()
            .getLocalUser()
            .microphone
            .addListener(onLocalMicrophoneStateChanged);

        break;
    }

    audienceLocalConnectStateNotifier.value = state;
  }

  void onLocalCameraStateChanged() {
    if (!ZegoUIKit().getLocalUser().camera.value &&
        !ZegoUIKit().getLocalUser().microphone.value) {
      ZegoLoggerService.logInfo(
        "co-host's camera and microphone are closed, update connect state to idle",
        tag: 'live streaming',
        subTag: 'connect manager',
      );

      updateAudienceConnectState(ConnectState.idle);
    }
  }

  void onLocalMicrophoneStateChanged() {
    if (!ZegoUIKit().getLocalUser().camera.value &&
        !ZegoUIKit().getLocalUser().microphone.value) {
      ZegoLoggerService.logInfo(
        "co-host's camera and microphone are closed, update connect state to idle",
        tag: 'live streaming',
        subTag: 'connect manager',
      );

      updateAudienceConnectState(ConnectState.idle);
    }
  }
}

extension ZegoLiveConnectManagerCoHostCount on ZegoLiveConnectManager {
  void initCoHostMixin() {
    subscriptions
      ..add(ZegoUIKit().getUserListStream().listen(onUserListUpdated))
      ..add(ZegoUIKit().getUserJoinStream().listen(onUserJoinUpdated))
      ..add(ZegoUIKit().getUserLeaveStream().listen(onUserLeaveUpdated))
      ..add(ZegoUIKit()
          .getAudioVideoListStream()
          .listen(onAudioVideoListUpdated));
  }

  void onAudioVideoListUpdated(List<ZegoUIKitUser> users) {
    coHostCount.value = users.where((user) => isCoHost(user)).length;

    ZegoLoggerService.logInfo(
      'audio video list changed, co-host count changed to ${coHostCount.value}',
      tag: 'live streaming',
      subTag: 'connect manager co-host count',
    );

    if (isMaxCoHostReached && hostManager.isLocalHost) {
      final coHosts = List<ZegoUIKitUser>.from(users)
        ..removeWhere((user) => hostManager.notifier.value?.id == user.id)
        ..sort((left, right) {
          return left.streamTimestamp.compareTo(right.streamTimestamp);
        });

      final kickCount = coHosts.length - config.maxCoHostCount;
      final kickUsers = coHosts.sublist(0, kickCount);
      ZegoLoggerService.logInfo(
        'audio video list changed, max co-host count reach, '
        'will kick $kickCount user in ${coHosts.length} by sort:$kickUsers',
        tag: 'live streaming',
        subTag: 'connect manager co-host count',
      );

      kickUsers.forEach((user) {
        kickCoHost(user);
      });
    }
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    coHostCount.value = users.where((user) => isCoHost(user)).length;

    ZegoLoggerService.logInfo(
      'user list changed, co-host count changed to ${coHostCount.value}',
      tag: 'live streaming',
      subTag: 'connect manager co-host count',
    );
  }

  void onUserJoinUpdated(List<ZegoUIKitUser> users) {
    for (final user in users) {
      user.camera.addListener(onUserCameraStateChanged);
      user.microphone.addListener(onUserMicrophoneStateChanged);
    }
  }

  void onUserLeaveUpdated(List<ZegoUIKitUser> users) {
    for (final user in users) {
      user.camera.removeListener(onUserCameraStateChanged);
      user.microphone.removeListener(onUserMicrophoneStateChanged);
    }
  }

  void onUserCameraStateChanged() {
    coHostCount.value =
        ZegoUIKit().getAllUsers().where((user) => isCoHost(user)).length;

    ZegoLoggerService.logInfo(
      'user camera state changed, co-host count changed to ${coHostCount.value}',
      tag: 'live streaming',
      subTag: 'connect manager co-host count',
    );
  }

  void onUserMicrophoneStateChanged() {
    coHostCount.value =
        ZegoUIKit().getAllUsers().where((user) => isCoHost(user)).length;

    ZegoLoggerService.logInfo(
      'user microphone state changed, co-host count changed to ${coHostCount.value}',
      tag: 'live streaming',
      subTag: 'connect manager co-host count',
    );
  }
}

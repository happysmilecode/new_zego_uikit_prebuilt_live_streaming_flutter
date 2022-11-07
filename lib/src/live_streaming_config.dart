// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'live_streaming_defines.dart';
import 'live_streaming_translation.dart';

class ZegoUIKitPrebuiltLiveStreamingConfig {
  ZegoUIKitPrebuiltLiveStreamingConfig.host({List<IZegoUIKitPlugin>? plugins})
      : isHost = true,
        plugins = plugins ?? [],
        turnOnCameraWhenJoining = true,
        turnOnMicrophoneWhenJoining = true,
        useSpeakerWhenJoining = true,
        showInRoomMessageButton = true,
        audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig(
          showSoundWavesInAudioMode: true,
        ),
        bottomMenuBarConfig = ZegoBottomMenuBarConfig(
          buttons: const [
            ZegoMenuBarButtonName.beautyEffectButton,
            ZegoMenuBarButtonName.soundEffectButton,
            ZegoMenuBarButtonName.toggleCameraButton,
            ZegoMenuBarButtonName.toggleMicrophoneButton,
            ZegoMenuBarButtonName.switchCameraButton,
          ],
          maxCount: 5,
        ),
        memberListConfig = ZegoMemberListConfig(),
        inRoomMessageViewConfig = ZegoInRoomMessageViewConfig(),
        effectConfig = ZegoEffectConfig(),
        translationText = ZegoTranslationText(),
        confirmDialogInfo = ZegoDialogInfo(
          title: "Stop the live",
          message: "Are you sure to stop the live?",
          cancelButtonName: "Cancel",
          confirmButtonName: "Stop it",
        );

  ZegoUIKitPrebuiltLiveStreamingConfig.audience(
      {List<IZegoUIKitPlugin>? plugins})
      : isHost = false,
        plugins = plugins ?? [],
        turnOnCameraWhenJoining = false,
        turnOnMicrophoneWhenJoining = false,
        useSpeakerWhenJoining = true,
        showInRoomMessageButton = true,
        audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig(
          showSoundWavesInAudioMode: true,
        ),
        bottomMenuBarConfig = ZegoBottomMenuBarConfig(
          buttons: plugins?.isEmpty ?? true
              ? []
              : const [ZegoMenuBarButtonName.coHostControlButton],
          maxCount: 5,
          requestUpdateButtons: (bool isCoHost) {
            return isCoHost
                ? [
                    ZegoMenuBarButtonName.switchCameraButton,
                    ZegoMenuBarButtonName.toggleCameraButton,
                    ZegoMenuBarButtonName.toggleMicrophoneButton,
                    ZegoMenuBarButtonName.coHostControlButton,
                    ZegoMenuBarButtonName.beautyEffectButton,
                    ZegoMenuBarButtonName.soundEffectButton,
                  ]
                : [
                    ZegoMenuBarButtonName.coHostControlButton,
                  ];
          },
        ),
        memberListConfig = ZegoMemberListConfig(),
        inRoomMessageViewConfig = ZegoInRoomMessageViewConfig(),
        effectConfig = ZegoEffectConfig(),
        translationText = ZegoTranslationText();

  ZegoUIKitPrebuiltLiveStreamingConfig({
    this.turnOnCameraWhenJoining = true,
    this.turnOnMicrophoneWhenJoining = true,
    this.useSpeakerWhenJoining = true,
    ZegoPrebuiltAudioVideoViewConfig? audioVideoViewConfig,
    ZegoBottomMenuBarConfig? bottomMenuBarConfig,
    ZegoMemberListConfig? memberListConfig,
    ZegoInRoomMessageViewConfig? messageConfig,
    ZegoEffectConfig? effectConfig,
    this.showInRoomMessageButton = true,
    this.confirmDialogInfo,
    this.onLeaveConfirmation,
    this.onLeaveLiveStreaming,
    this.onLiveStreamingEnded,
    this.avatarBuilder,
    ZegoTranslationText? translationText,
  })  : audioVideoViewConfig =
            audioVideoViewConfig ?? ZegoPrebuiltAudioVideoViewConfig(),
        bottomMenuBarConfig = bottomMenuBarConfig ?? ZegoBottomMenuBarConfig(),
        memberListConfig = memberListConfig ?? ZegoMemberListConfig(),
        inRoomMessageViewConfig =
            messageConfig ?? ZegoInRoomMessageViewConfig(),
        effectConfig = effectConfig ?? ZegoEffectConfig(),
        translationText = translationText ?? ZegoTranslationText();

  /// specify if a host or audience
  bool isHost = false;

  List<IZegoUIKitPlugin> plugins = [];

  /// whether to enable the camera by default, the default value is true
  bool turnOnCameraWhenJoining;

  /// whether to enable the microphone by default, the default value is true
  bool turnOnMicrophoneWhenJoining;

  /// whether to use the speaker by default, the default value is true;
  bool useSpeakerWhenJoining;

  /// configs about audio video view
  ZegoPrebuiltAudioVideoViewConfig audioVideoViewConfig;

  /// configs about bottom menu bar
  ZegoBottomMenuBarConfig bottomMenuBarConfig;

  /// configs about member list
  ZegoMemberListConfig memberListConfig;

  /// configs about message view
  ZegoInRoomMessageViewConfig inRoomMessageViewConfig;

  /// support :
  /// 1. Face beautification
  /// 2. Voice changing
  /// 3. Reverb
  ZegoEffectConfig effectConfig;

  /// support message if set true
  bool showInRoomMessageButton;

  /// alert dialog information of leave
  /// if confirm info is not null, APP will pop alert dialog when you hang up
  ZegoDialogInfo? confirmDialogInfo;

  /// It is often used to customize the process before exiting the live interface.
  /// The liveback will triggered when user click hang up button or use system's return,
  /// If you need to handle custom logic, you can set this liveback to handle (such as showAlertDialog to let user determine).
  /// if you return true in the liveback, prebuilt page will quit and return to your previous page, otherwise will ignore.
  Future<bool> Function(BuildContext context)? onLeaveConfirmation;

  /// customize handling after leave live streaming
  VoidCallback? onLeaveLiveStreaming;

  /// customize handling after end live streaming
  VoidCallback? onLiveStreamingEnded;

  ZegoTranslationText translationText;

  /// customize your user's avatar, default we use userID's first character as avatar
  /// User avatars are generally stored in your server, ZegoUIKitPrebuiltLiveStreaming does not know each user's avatar, so by default, ZegoUIKitPrebuiltLiveStreaming will use the first letter of the user name to draw the default user avatar, as shown in the following figure,
  ///
  /// |When the user is not speaking|When the user is speaking|
  /// |--|--|
  /// |<img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/_default_avatar_nowave.jpg" width="10%">|<img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/_default_avatar.jpg" width="10%">|
  ///
  /// If you need to display the real avatar of your user, you can use the avatarBuilder to set the user avatar builder method (set user avatar widget builder), the usage is as follows:
  ///
  /// ```dart
  ///
  ///  // eg:
  ///  avatarBuilder: (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
  ///    return user != null
  ///        ? Container(
  ///            decoration: BoxDecoration(
  ///              shape: BoxShape.circle,
  ///              image: DecorationImage(
  ///                image: NetworkImage(
  ///                  'https://your_server/app/avatar/${user.id}.png',
  ///                ),
  ///              ),
  ///            ),
  ///          )
  ///        : const SizedBox();
  ///  },
  ///
  /// ```
  ///
  ZegoAvatarBuilder? avatarBuilder;
}

class ZegoPrebuiltAudioVideoViewConfig {
  /// video view mode
  /// if set to true, video view will proportional zoom fills the entire View and may be partially cut
  /// if set to false, video view proportional scaling up, there may be black borders
  bool useVideoViewAspectFill;

  /// hide avatar of audio video view if set false
  bool showAvatarInAudioMode;

  /// hide sound level of audio video view if set false
  bool showSoundWavesInAudioMode;

  /// customize your foreground of audio video view, which is the top widget of stack
  /// <br><img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/_default_avatar_nowave.jpg" width="5%">
  /// you can return any widget, then we will put it on top of audio video view
  ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// customize your background of audio video view, which is the bottom widget of stack
  ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  ZegoPrebuiltAudioVideoViewConfig({
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.showAvatarInAudioMode = true,
    this.showSoundWavesInAudioMode = true,
    this.useVideoViewAspectFill = true,
  });
}

class ZegoBottomMenuBarConfig {
  /// these buttons will displayed on the menu bar, order by the list
  List<ZegoMenuBarButtonName> buttons;

  /// triggered when the viewer switches between the audience and coHost
  /// you needs to return a list of button names.
  /// the default behavior is as follows:
  /// isCoHost is true: [switchCameraButton, toggleCameraButton, toggleMicrophoneButton, coHostControlButton]
  /// isCoHost is false: [coHostControlButton]
  List<ZegoMenuBarButtonName> Function(bool isCoHost)? requestUpdateButtons;

  /// these buttons will sequentially added to menu bar,
  /// and auto added extra buttons to the pop-up menu
  /// when the limit [maxCount] is exceeded
  List<Widget> extendButtons;

  /// triggered when the viewer switches between the audience and coHost
  /// you needs to return a list of widget.
  /// the default behavior is: []
  List<Widget> Function(bool isCoHost)? requestUpdateExtendButtons;

  /// limited item count display on menu bar,
  /// if this count is exceeded, More button is displayed
  int maxCount;

  ZegoBottomMenuBarConfig({
    this.buttons = const [],
    this.requestUpdateButtons,
    this.extendButtons = const [],
    this.requestUpdateExtendButtons,
    this.maxCount = 5,
  });
}

class ZegoMemberListConfig {
  /// show microphone state or not
  bool showMicrophoneState;

  /// show camera state or not
  bool showCameraState;

  /// customize your item view of member list
  ZegoMemberListItemBuilder? itemBuilder;

  ZegoMemberListConfig({
    this.showMicrophoneState = true,
    this.showCameraState = true,
    this.itemBuilder,
  });
}

class ZegoInRoomMessageViewConfig {
  /// customize your item view of message list
  ZegoInRoomMessageItemBuilder? itemBuilder;

  ZegoInRoomMessageViewConfig({
    this.itemBuilder,
  });
}

class ZegoEffectConfig {
  List<BeautyEffectType> beautyEffects;
  List<VoiceChangerType> voiceChangeEffect;
  List<ReverbType> reverbEffect;

  ZegoEffectConfig({
    this.beautyEffects = const [
      BeautyEffectType.whiten,
      BeautyEffectType.rosy,
      BeautyEffectType.smooth,
      BeautyEffectType.sharpen,
    ],
    this.voiceChangeEffect = const [
      VoiceChangerType.littleGirl,
      VoiceChangerType.deep,
      VoiceChangerType.robot,
      VoiceChangerType.ethereal,
      VoiceChangerType.littleBoy,
      VoiceChangerType.female,
      VoiceChangerType.male,
      VoiceChangerType.optimusPrime,
      VoiceChangerType.crystalClear,
      VoiceChangerType.cMajor,
      VoiceChangerType.aMajor,
      VoiceChangerType.harmonicMinor,
    ],
    this.reverbEffect = const [
      ReverbType.ktv,
      ReverbType.hall,
      ReverbType.concert,
      ReverbType.rock,
      ReverbType.smallRoom,
      ReverbType.largeRoom,
      ReverbType.valley,
      ReverbType.recordingStudio,
      ReverbType.basement,
      ReverbType.popular,
      ReverbType.gramophone,
    ],
  });

  ZegoEffectConfig.none({
    this.beautyEffects = const [],
    this.voiceChangeEffect = const [],
    this.reverbEffect = const [],
  });

  bool get isSupportBeauty => beautyEffects.isNotEmpty;

  bool get isSupportVoiceChange => voiceChangeEffect.isNotEmpty;

  bool get isSupportReverb => reverbEffect.isNotEmpty;
}

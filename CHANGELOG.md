## 2.8.4
- Added click event to the host avatar which at the top left corner.
- Added click event to the item of member list .

## 2.8.3
- support config size to message list
- Update dependencies

## 2.8.2
- fix the issue of conflict with extension key of the `flutter_screenutil` package.

## 2.8.1
- fix some user login status issues when used `zego_uikit_prebuilt_live_streaming` with `zego_zimkit`

## 2.8.0
- add a "removeCoHost" method to the controller that allows the host remove a co-host.
- add a "makeAudienceCoHost" method to the controller that allows the host invite an audience to be a co-host.
- supports PK in-app minimization.
- support foreground in config，if you need to nest some widgets in [ZegoUIKitPrebuiltLiveStreaming], please use [foreground] nesting, otherwise these widgets will be lost when you minimize and restore the [ZegoUIKitPrebuiltLiveStreaming]

## 2.7.0
- supports in-app minimization.

## 2.6.1
- Update comments

## 2.6.0
- Support for limiting the maximum number of co-hosts.
- Support for automatically disabling the camera for co-hosts by default.
- Support for setting the video resolution.

## 2.5.10
- Update dependencies

## 2.5.9
- Update comments

## 2.5.8
- Update dependencies

## 2.5.7
- switch from local timing to server-based timing for the live broadcast. additionally, if the live starts again, the timer will reset.

## 2.5.6
- deprecate flutter_screenutil_zego package

## 2.5.5
- supports specifying extend button position in the bottom bar by an index, allowing it to be positioned before the built-in button.

## 2.5.4
- rename style variable

## 2.5.3
- Support customizing the style of buttons (icons and text) in the bottom toolbar.

## 2.5.2
- support close duration in config

## 2.5.1
- add a "leave" method to the controller that allows for actively leave the current live.
- support tracking the duration of the live locally.
- fix some beauty bugs

## 2.5.0
- support advance beauty

## 2.4.4
- Update dependencies

## 2.4.3
- Fix some issues

## 2.4.2
- mark 'appDesignSize' as Deprecated

## 2.4.1
- Update dependencies

## 2.4.0
- To differentiate the 'appDesignSize' between the App and ZegoUIKitPrebuiltLiveStreaming, we introduced the 'flutter_screenutil_zego' library and removed the 'appDesignSize' parameter from the
  ZegoUIKitPrebuiltLiveStreaming that was previously present.

## 2.3.8
- fix the problem that the layout of configuration parameters does not working

## 2.3.7
- add a configuration option that allows the host to skip preview and start live directly
- add transparency configuration for the message list

## 2.3.6

- fixed appDesignSize for ScreenUtil that didn't work
- fixed crash in screen sharing

## 2.3.5

- add the rootNavigator parameter in config param, try to set it to true when you get stuck with navigation
- fixed an issue with the back button icon of the preview page in the RTL scenario
- add assert to key parameters to ensure prebuilt run normally

## 2.3.4

- add member list text customization

## 2.3.3

- fixed landscape not displaying full web screen sharing content
- add message and voice/beauty text customization

## 2.3.2

- fix no response to the chat button click when text direction is RTL

## 2.3.1

- fix some bugs
- update dependency

## 2.3.0

- support screen share

## 2.2.1

- remove login token
- optimizing code warnings

## 2.2.0

- support full screen for screen sharing

## 2.1.3

- Fix the issue of the re-login problem caused by onUserInfoUpdate

## 2.1.2

- Fix the issue of mixed stream view of pkBattles is sometimes not displayed due to express doesn't trigger the first frame callback.

## 2.1.1

- support rtc pkbattles

## 2.1.0

- Support PK Battles.

## 2.0.0

- Architecture upgrade based on adapter.

## 1.4.5

* downgrade flutter_screenutil to ">=5.5.3+2 <5.6.1"

## 1.4.4

* support display user name on audio video view or not

## 1.4.3

* fix bugs
* update resources
* support sdk log
* update a dependency to the latest release

## 1.4.2

* support custom background

## 1.4.1

* support custom start live button

## 1.4.0

* support view screen sharing stream of web

## 1.3.2

* update a dependency to the latest release

## 1.3.1

* fix some bugs

## 1.3.0

* support disable chat
* support mark as large-room
* support 'sendInRoomCommand',
* support kick-out user
* support open/close remote user's microphone or camera
* support CDN video stream

## 1.2.9

* fix some bugs
* update a dependency to the latest release

## 1.2.8

* fix some bugs

## 1.2.7

* update a dependency to the latest release

## 1.2.6

* fix some bugs

## 1.2.5

* fix some bugs
* update a dependency to the latest release

## 1.2.4

* fix some bugs

## 1.2.3

* fix some bugs
* update a dependency to the latest release

## 1.2.2

* fix some bugs

## 1.2.1

* update a dependency to the latest release

## 1.2.0

* support live streaming with co-host

## 1.0.3

* fix some bugs

## 1.0.2

* fix some bugs

## 1.0.1

* update a dependency to the latest release

## 1.0.0

* Congratulations!

## 0.0.9

* fix some bugs

## 0.0.8

* update a dependency to the latest release

## 0.0.7

* update readme
* update ZegoUIKitPrebuiltLiveStreamingConfig

## 0.0.6

* update readme

## 0.0.5

* update config

## 0.0.4

* fix some bugs

## 0.0.2

* fix some bugs
* update a dependency to the latest release

## 0.0.1

* Upload Initial release.

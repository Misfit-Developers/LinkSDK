# MisfitLinkSDK

[![CI Status](http://img.shields.io/travis/Phill Pasqual/MisfitLinkSDK.svg?style=flat)](https://travis-ci.org/Phill Pasqual/MisfitLinkSDK)
[![Version](https://img.shields.io/cocoapods/v/MisfitLinkSDK.svg?style=flat)](http://cocoapods.org/pods/MisfitLinkSDK)
[![License](https://img.shields.io/cocoapods/l/MisfitLinkSDK.svg?style=flat)](http://cocoapods.org/pods/MisfitLinkSDK)
[![Platform](https://img.shields.io/cocoapods/p/MisfitLinkSDK.svg?style=flat)](http://cocoapods.org/pods/MisfitLinkSDK)


## Installation

MisfitLinkSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MisfitLinkSDK"
```

## Author

Phill Pasqual, phill@misfit.com

## License

MisfitLinkSDK is available under the MIT license. See the LICENSE file for more info.


# Misfit Link SDK

* [Getting Started](#preparation)
* [Set Up a Misfit Link App](#setup)
* [Configure Your Application's PList File](#configure)
* [Configure Linker Flags](#linker)
* [Adding a Reference to the Sleep SDK](#adding)
* [Enable Bluetooth LE Background Mode](#enable)
* [Setting Up the Application Delegate](#delegate)
* [Enable the Flash Link Button](#button)
* [Recieving Button Commands](#commands)
* [Recieving State Change Events](#state)
* [Changing Button Command Mappings](#mappings)
* [Programmatically](#prog)
* [UI Dialog](#dialog)
* [Reference](#reference)


## <a name="preparation"></a> Getting Started
### <a name="setup"></a> Set Up a Misfit Link SDK App
1. go to the [Misfit Developer Portal](https://build.misfit.com)
2. if you do not have a developer account, [create one](/signup)
3. navigate to the "Building" section under "Misfit Link SDK Apps"
4. click "Register an App"
5. fill out the form
![image of colors and description](/assets/images/docs/colorPicker.png?w=800)

Theme Color and Secondary Theme Color specify the gradient that will be shown in the Link App:

![image of link gradient](/assets/images/docs/linkGradient.png?w=300)

In the commands section, you can create an action and link it to a button command:

![image of commands](/assets/images/docs/commands.png?w=700)

After filling out the form, click the "Register" button to register the app.
6. after registering, your app key and secret will be desplayed on the app settings page
![image of appkey and secret](/assets/images/docs/appkeysecretLink.png?w=700)
7. add your Misfit email to the "Test Users" page
![image of test users](/assets/images/docs/testAccounts.png?w=400)
*IMPORTANT*: While your app is in development, only emails added to this list will be able to test the application.
8. once your application is ready to release, press the "Submit" button and someone will review your application.
9. when your application has been approved, it will show in the "Approved" section under "Link SDK Apps"
10. your approved application will have a different app key and secret assigned to it. Make sure to update this in your app.

### <a name="configure"></a> Configure Your Application's PList File
Add the following to your application's plist file:
```
<key>CFBundleURLTypes</key>
<array>
<dict>
<key>CFBundleURLName</key>
<string></string>
<key>CFBundleURLSchemes</key>
<array>
<string>mfl-appkey</string>
</array>
</dict>
</array>
```
make sure to replace *appkey* with the app key that was assigned to you by Misfit.

When using iOS 9, the following should also be added to the plst file:
```
<key>LSApplicationQueriesSchemes</key>
<array>
<string>misfitlink</string>
</array>
```

### <a name="linker"></a> Configure Linker Flags
Finally, open your project properties and navigate to build settings -> linking and find the "other linker flags" section. Add "-ObjC" to both debug and release.

![image of frameworks](/assets/images/docs/linkerflags.png?w=350)

### <a name="adding"></a> Adding a Reference to the Link SDK
1. In Xcode, open up your project properties
2. Navigate to "Build Phases"
3. In the "Link Binaries With Libraries" section, add *CoreBluetooth.framework* and *MisfitLinkSDK.framework*

![image of frameworks](/assets/images/docs/frameworks.png?w=550)

### <a name="enable"></a> Enable Bluetooth LE Background Mode
1. In Xcode, navigate to the "Capabilities" tab in your project properties
2. In the "Background Modes" secion, check the box next to "Uses Bluetooth LE accessories"

![image of ble accessories](/assets/images/docs/ble.png?w=700)

### <a name="delegate"></a> Setting Up the Application Delegate
First, import the SDK:
```
#import <MisfitLinkSDK/MisfitLinkSDK.h>
```
The following code should be added to your application delegate to handle redirection to your app after the authorization process:
```
- (void)applicationDidBecomeActive:(UIApplication *)application {
[[MFLSession sharedInstance] handleDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
annotation:(id)annotation
{
BOOL canHandle = NO;
if ([[MFLSession sharedInstance] canHandleOpenUrl:url])
{
canHandle = [[MFLSession sharedInstance] handleOpenURL:url];
}
//other logic
return canHandle;
}
```

### <a name="button"></a> Enable the Flash Link Button
The following code can be used to enable the Flash Link Button in your application using a standard UISwitch:

```
- (IBAction)onEnableSwitchChanged:(UISwitch *)sender
[[MFLSession sharedInstance] enableWithAppId:@"yourAppId" appSecret:@"yourAppSecret"
completion:^(NSDictionary * commandMappingDict,NSArray * supportedCommands, MFLError* error)
{
if (error)
{
//reset the status
theSwitchControl.on = [MFLSession sharedInstance].enabled;
//handle error.
return;
}
//Button Command Settings for the user.
if (commandMappingDict)
{
MFLCommand *command = [commandMappingDict objectForKey:@(MFLGestureTypeTriplePress)];
NSLog(@"command desc:%@, name:%@", command.desc, command.name);
//output: command desc:add to favorites, name:add_to_favorites, eventType: MFLGestureTypeTriplePress
}
for (MFLCommand * command in supportedCommands)
{
NSLog(@"supported command name:%@, desc: %@",command.name,command.desc);
}
}];
}
```

### <a name="commands"></a> Recieving Button Commands
Setup a class in your project to receive events from the MFLGestureCommandDelegate. The example below uses a ViewController. 

```
@interface MainViewController ()<MFLGestureCommandDelegate>
...
- (void)viewDidLoad {
[MFLSession sharedInstance].gestureCommandDelegate = self;
}
...
- (void) performActionByCommand:(MFLCommand *)command
completion:(void (^)(MFLActionResultType result))completion{

if ([command.name isEqualToString:@"play_pause_music"])
{
NSLog(@"Play/Pause Music!");
//Your action here.
if (your_action_failed)
{
//handle error.
completion(MFLActionResultTypeFail);
return;
}
completion(MFLActionResultTypeSuccess);
}
else if ([command.name isEqualToString:@"next_song"])
{
NSLog(@"Next Song!");
//Your action here.
if (your_action_failed)
{
//handle error.
completion(MFLActionResultTypeFail);
return;
}

completion(MFLActionResultTypeSuccess);
}
else if ([command.name isEqualToString:@"add_to_favorites"])
{
NSLog(@"Add the song to your favorites!");
//Your action here.
if (your_action_failed)
{
//handle error.
completion(MFLActionResultTypeFail);
return;
}
completion(MFLActionResultTypeSuccess);
}
else
{
completion(MFLActionResultTypeNotSet);
}

}
```

*Note:* with each instance of
```
[command.name isEqualToString:@"command-name"]
```
*command-name* should be replaced with a command name that you specified when [setting up your Misfit Link App](#setup)

### <a name="state"></a> Recieving Device State Change Events
Setup a class in your project to receive events from the MFLStateTrackingDelegate.

MFLStateTrackingDelegate contains two functions:
```
- (void) onDeviceStateChangeWithState:(MFLDeviceState)state
serialNumber:(NSString *)serialNumber;
```
which can be used to receive events when the connected device becomes available or unavailable, and
```
- (void) onServiceStateChangeWithState:(MFLServiceState)state;
```
which can be used to receive events if your application is disconnected from the Misfit service (or reconnected).

The example below shows how these two delegates can be used in a ViewController:
```
@interface MainViewController ()<MFLStateTrackingDelegate>
...
- (void)viewDidLoad {
[MFLSession sharedInstance].sessionStateDelegate = self;
}
...
- (void) onDeviceStateChangeWithState:(MFLDeviceState)state
serialNumber:(NSString *)serialNumber
{
if (state == MFLDeviceStateUnavailable){
//the device has become unavailable
}else if (state == MFLDeviceStateAvailable){
//the device has become available
}
}

- (void) onServiceStateChangeWithState:(MFLServiceState)state
{
if (state == MFLServiceStateDisabled){
//the application has been disconnected from the Misfit service
}else if (state == MFLServiceStateEnabled){
//the application has been connected to the Misfit service
}
}
```

### <a name="mappings"></a> Changing Button Command Mappings
The Link SDK provides two methods for changing your button command mappings:

##### <a name="prog"></a> Programmatically
```
[[MFLSession sharedInstance] updateCommandMappingByGestureType:(MFLGestureType)gestureType commandName:(NSString *)commandName
completion:^(NSDictionary * commandMappingDict,NSArray * supportedCommands, MFLError* error)
{
if (error)
{
//reset the status
theSwitchControl.on = [MFLSession sharedInstance].enabled;
//handle error.
return;
}
//Button Command Settings for the user.
if (commandMappingDict)
{
MFLCommand *command = [commandMappingDict objectForKey:@(MFLGestureTypeTriplePress)];
NSLog(@"command desc:%@, name:%@", command.desc, command.name);
//output: command desc:add to favorites , name:add_to_favorites
}
for (NSDictionary *command in supportedCommands)
{
NSLog(@"supported command name:%@, desc: %@",command[@"name"],command[@"desc"]);

}
}];
```
##### <a name="dialog"></a> UI Dialog
```
[[MFLSession sharedInstance] showGestureMappingSettingDialogWithNavigationController:(UINavigationController *)controller
completion:^(NSDictionary * commandMappingDict,NSArray * supportedCommands, MFLError* error)
{
if (error)
{
//reset the status
theSwitchControl.on = [MFLSession sharedInstance].enabled;
//handle error.
return;
}
//Button Command Settings for the user.
if (commandMappingDict)
{
MFLCommand *command = [commandMappingDict objectForKey:@(MFLGestureTypeTriplePress)];
NSLog(@"command desc:%@, name:%@", command.desc, command.name);
//output: command desc:add to favorites, name:add_to_favorites
}
for (NSDictionary *command in supportedCommands)
{
NSLog(@"supported command name:%@, desc: %@",command[@"name"],command[@"desc"]);

}
}];
```

There are four different gesture types available:
```
typedef enum {
MFLGestureTypeSinglePress,
MFLGestureTypeDoublePress,
MFLGestureTypeTriplePress,
MFLGestureTypeLongPress,
} MFLGestureType;
```

### <a name="reference"></a> Reference
```objective-c
@interface MFLSession : NSObject

+ (MFLSession *) sharedInstance;

@property (nonatomic, strong) id<MFLGestureCommandDelegate> gestureCommandDelegate;
@property (nonatomic, weak) id<MFLStateTrackingDelegate> sessionStateDelegate;

//is the Link SDK enabled?
@property (nonatomic, readonly) BOOL enabled;

//is the Link App installed?
- (BOOL) isMisfitLinkAppInstalled;

//enable the Link SDK button service
- (void) enableWithAppId:(NSString *) appId appSecret:(NSString *) appSecret completion:(MFLCompletion) completion;

//update the button command mapping programmatically
- (void) updateCommandMappingByGestureType:(MFLGestureType)gestureType command:(NSString *)commandName 
completion:(MFLCompletion) completion;

//update the button command mapping by presenting the user with a dialog window
- (void)showGestureMappingSettingDialogWithNavigationController:(UINavigationController *)controller 
completion:(MFLCompletion) completion;

- (MFLCommand *) getCommandByGestureType:(MFLGestureType)gestureType;

//disable the Link SDK
- (void) disable;

- (void) refreshStatus;

//used in the application delegate to handle redirection from the Link App
- (BOOL) handleOpenURL:(NSURL *) url;
- (BOOL) canHandleOpenUrl:(NSURL *) url;
- (void) handleDidBecomeActive;
@end
```







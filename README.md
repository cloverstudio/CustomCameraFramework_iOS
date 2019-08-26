# CustomCameraFramework_iOS

Open project with xcode and build framework (Product -> Archive -> Distribute Content -> Built Product) or you can use framework from build folder.

## Use CustomCameraFramework

1. Add permission for camera and microphone in plist
```xml
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) uses camera for ...</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) record video and audio</string>
```
2. Copy framework to project, and add it to Target -> General -> Embedded Binaries and Linked Frameworks and Libraries.

3. Import CustomCamera to swift class where want to use CustomCamera library
##### Swift
```swift
import CustomCamera
```
##### Objc
```objc
#import <CustomCamera/CustomCamera.h>
```

## Swift

1. Add permission for camera and microphone in plist
```xml
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) uses camera for ...</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) record video and audio</string>
```
2. Copy framework to project, and add it to Target -> General -> Embedded Binaries and Linked Frameworks and Libraries.
 
3. Import CustomCamera to swift class where want to use CustomCamera library
```swift
import CustomCamera
```
4. Create CustomCameraConfigFile and change string and icon (if defaults string and icons are not good enough)
```swift
let configFile = CustomCameraConfigFile.init() 
configFile.holdForVideoTapForImageString = NSLocalizedString("Hold for video, tap for image", comment: "")
```
5. Start CustomCamera with this methode
```swift
CustomCameraViewController.startCustomCamera(viewOrNavigationController: self, config: configFile, delegate: self)
```
6. Add CustomCameraDelegate delegate to ViewController, and add delegate methods to ViewController
```swift
func customCameraOnPermissionDenied(camera: Bool, microphone: Bool) {
	// user decline perission
}

func customCameraOnCancel(viewController: CustomCameraViewController) {
	// user close CustomCamera without take picture or record video
}

func customCameraOnVideo(path: String, viewController: CustomCameraViewController) {
	// user record video with CustomCamera - path is path of video, you can set this path in config file
}

func customCameraOnImage(image: UIImage, viewController: CustomCameraViewController) {
	// user take image with CustomCamera
}
```

## Objc

1. Add permission for camera and microphone in plist
```xml
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) uses camera for ...</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) record video and audio</string>
```
2. Copy framework to project, and add it to Target -> General -> Embedded Binaries and Linked Frameworks and Libraries.
 
3. Import CustomCamera to swift class where want to use CustomCamera library
```objc
#import <CustomCamera/CustomCamera.h>
```
4. Create CustomCameraConfigFile and change string and icon (if defaults string and icons are not good enough)
```objc
CustomCameraConfigFile *configFile = [CustomCameraConfigFile new];
[configFile setHoldForVideoTapForImageStringWithText:NSLocalizedString(@"Hold for video, tap for image", nil)];
```
5. Start CustomCamera with this methode
```objc
[CustomCameraViewController startCustomCameraForObjCWithViewOrNavigationController:self config:configFile delegate:self];
```
6. Add CustomCameraDelegate delegate to ViewController, and add delegate methods to ViewController
```objc
-(void)customCameraOnPermissionDeniedWithCamera:(BOOL)camera microphone:(BOOL)microphone{
	// user decline perission
}

-(void)customCameraOnCancelWithViewController:(CustomCameraViewController *)viewController{
	// user close CustomCamera without take picture or record video
}

-(void)customCameraOnVideoWithPath:(NSString *)path viewController:(CustomCameraViewController *)viewController{
	// user record video with CustomCamera - path is path of video, you can set this path in config file
}

-(void)customCameraOnImageWithImage:(UIImage *)image viewController:(CustomCameraViewController *)viewController{
	// user take image with CustomCamera
}
```

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
4. Create CustomCameraConfigFile and change string and icon (if defaults string and icons are not good enough)
##### Swift
```swift
let configFile = CustomCameraConfigFile.init() 
configFile.holdForVideoTapForImageString = NSLocalizedString("Hold for video, tap for image", comment: "")
```
##### Objc
```objc
CustomCameraConfigFile *configFile = [CustomCameraConfigFile new];
[configFile setHoldForVideoTapForImageStringWithText:NSLocalizedString(@"Hold for video, tap for image", nil)];
```
5. CustomCameraFramework can be started like ViewController or View. 
#### CustomCameraFramework like ViewCotroller
5.1. Start CustomCamera with this methode
##### Swift
```swift
CustomCameraViewController.startCustomCamera(viewOrNavigationController: self, config: configFile, delegate: self)
```
##### Objc
```objc
[CustomCameraViewController startCustomCameraForObjCWithViewOrNavigationController:self config:configFile delegate:self];
```
Native video editing can be enable in ConfigFile. This feature is only available if CustomCameraFramework is started like ViewController.
##### Swift
```swift
config.editVideoEnabled = true
config.setEditVideoQuality(quality: .typeHigh)
```
##### Objc
```objc
[file setEditVideoEnabledWithEnabled:NO];
[file setEditVideoQualityWithQuality:UIImagePickerControllerQualityTypeHigh]
```
5.2. Add CustomCameraDelegate delegate to ViewController, and add delegate methods to ViewController
##### Swift
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
##### Objc
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
#### CustomCameraFramework like ViewCotroller
5.1. Add subview to view with this method (view is parent view for CustomCameraView)
##### Swift
```swift
CustomCameraView.startCustomCameraInView(view: view, config: config, delegate: self, animate: true)
```
##### Objc
```objc
[CustomCameraView startCustomCameraInViewForObjCWithView:view config:file delegate:self animate:YES];
```
or CustomCameraView can be created like any other view:
##### Swift
```swift
let cameraView = CustomCameraView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
cameraView.setCustomConfigFile(configFile: config)
cameraView.setCustomCameraViewDelegate(delegate: self)
self.view.addSubview(cameraView)
```
##### Objc
```objc
CustomCameraView *cameraView = [[CustomCameraView alloc] initWithFrame:CGRectMake(0, 0, 200, 400)];
cameraView setCustomConfigFileWithConfigFile:file];
[cameraView setCustomCameraViewDelegateWithDelegate:self];
[self.view addSubview:cameraView];
```
5.2. Add CustomCameraViewDelegate delegate to ViewController, and add delegate methods to ViewController
##### Swift
```swift
func customCameraViewOnPermissionDenied(camera: Bool, microphone: Bool) {
	// user decline perission
}

func customCameraViewOnCancel(view: CustomCameraView) {
	// user close CustomCamera without take picture or record video
}

func customCameraViewOnVideo(urlPath: URL, view: CustomCameraView) {
	// user record video with CustomCamera - path is path of video, you can set this path in config file
}

func customCameraViewOnImage(image: UIImage, view: CustomCameraView) {
	// user take image with CustomCamera
}
```
##### Objc
```objc
- (void)customCameraViewOnPermissionDeniedWithCamera:(BOOL)camera microphone:(BOOL)microphone {
	// user decline perission
}

- (void)customCameraViewOnCancelWithView:(CustomCameraView * _Nonnull)view {
	// user close CustomCamera without take picture or record video
}

- (void)customCameraViewOnVideoWithUrlPath:(NSURL * _Nonnull)urlPath view:(CustomCameraView * _Nonnull)view {
	// user record video with CustomCamera - path is path of video, you can set this path in config file
}

- (void)customCameraViewOnImageWithImage:(UIImage * _Nonnull)image view:(CustomCameraView * _Nonnull)view {
	// user take image with CustomCamera
}
```

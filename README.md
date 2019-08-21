# CustomCameraFramework_iOS

Open project with xcode and build framework (Product -> Archive -> Distribute Content -> Built Product) or you can use framework from build folder.

## Swift

1. Add permission for camera and microphone in plist

<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) uses camera for ...</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) record video and audio</string>

2. Copy framework to project, and add it to Target -> General -> Embedded Binaries and Linked Frameworks and Libraries.
 
3. Import CustomCamera to swift class where want to use CustomCamera library
```swift
import CustomCamera
```
4. Create CustomCameraConfigFile and change string and icon (if defaults string and icons are not good enough)

        let configFile = CustomCameraConfigFile.init()
        configFile.holdForVideoTapForImageString = NSLocalizedString("Hold for video, tap for image", comment: "")

5. Start CustomCamera with this methode

CustomCameraViewController.startCustomCamera(viewOrNavigationController: self, config: configFile, delegate: self)

6. Add CustomCameraDelegate delegate to ViewController, and add delegate methods to ViewController

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


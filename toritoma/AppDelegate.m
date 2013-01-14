/*!
 @file AppDelegate.m
 @brief Application controller定義
 
 Application controllerを定義する。
 */

#import "cocos2d.h"

#import "AppDelegate.h"
#import "AKPlayingScene.h"

/*!
 @brief Application controller
 
 Application controller。
 */
@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

/*!
 @brief アプリケーション生成処理
 
 Tells the delegate that the launch process is almost done and the app is almost ready to run.
 @param application The delegating application object.
 @param launchOptions A dictionary indicating the reason the application was launched.
 @return NO if the application cannot handle the URL resource, otherwise return YES.
         The return value is ignored if the application is launched as a result of a remote notification.
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
    // マルチタッチを有効にする
    [glView setMultipleTouchEnabled:YES];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	director_.wantsFullScreenLayout = YES;

	// Display FSP and SPF
	[director_ setDisplayStats:YES];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
	[director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:NO] )
		CCLOG(@"Retina Display Not supported");

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// Create a Navigation Controller with the Director
	navController_ = [[AKNavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
	
	return YES;
}

/*!
 @brief シーン初期設定処理
 
 This is needed for iOS4 and iOS5 in order to ensure
 that the 1st scene has the correct dimensions
 This is not needed on iOS6 and could be added to the application:didFinish...
 @param director ディレクター
 */
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil) {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
		[director runWithScene: [AKPlayingScene node]];
	}
}

/*!
 @brief 画面回転可否判定
 
 Supported orientations: Landscape. Customize it for your own needs
 @param interfaceOrientation 回転する向き
 @return YES:回転可能、NO:回転不可
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // 画面の向きがLandscapeの場合のみ回転を許可する。    
    AKLog(1, @"interfaceOrientation=%d retval=%d",
          interfaceOrientation, UIInterfaceOrientationIsLandscape(interfaceOrientation));
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

/*!
 @brief アプリ中断時処理
 
 アプリが中断された時にコールされる。
 ゲームプレイ中の場合はシーンを一時停止する。
 @param application アプリケーションクラス
 */
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

/*!
 @brief call got rejected
 
 call got rejected
 @param application アプリケーションクラス
 */
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

/*!
 @brief バックグラウンドに移行したときの処理
 
 バックグラウンドに移行したときの処理を行う。
 @param application アプリケーションクラス
 */
-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

/*!
 @brief フォアグラウンドに移行したときの処理
 
 フォアグラウンドに移行したときの処理を行う。
 @param application アプリケーションクラス
 */
-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

/*!
 @brief application will be killed
 
 application will be killed
 @param application アプリケーションクラス
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

/*!
 @brief purge memory
 
 purge memory
 @param application アプリケーションクラス
 */
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

/*!
 @brief next delta time will be zero
 
 next delta time will be zero
 @param application アプリケーションクラス
 */
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

/*!
 @brief インスタンス解放処理
 
 インスタンス解放時の処理を行う。
 */
- (void) dealloc
{
	[window_ release];
	[navController_ release];

	[super dealloc];
}
@end


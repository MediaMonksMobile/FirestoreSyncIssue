//
// Firestore Sync Issue Example App.
// Copyright (C) 2018 MediaMonks B.V. All rights reserved.
//

#import "AppDelegate.h"

#import "ExampleViewController.h"

#import <FirebaseCore/FirebaseCore.h>

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
	didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[FIRApp configure];

	ExampleViewController *vc = [[ExampleViewController alloc] init];

	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.window.rootViewController = vc;
	[self.window makeKeyAndVisible];

	return YES;
}

@end

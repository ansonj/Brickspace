//
//  BKPAppDelegate.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPAppDelegate.h"
#import "BKPSplashViewController.h"

@implementation BKPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	BKPSplashViewController *splashVC = [[BKPSplashViewController alloc] init];
	[[self window] setRootViewController:splashVC];
    
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
	
	return YES;
}

@end

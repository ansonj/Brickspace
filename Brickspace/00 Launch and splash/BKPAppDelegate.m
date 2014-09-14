//
//  BKPAppDelegate.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPAppDelegate.h"

#import "BKPSplashViewController.h"

// For STWirelessLog
#import <Structure/Structure.h>
static BOOL useWirelessLogging = NO;
static NSString *loggingIP = @"172.25.235.22";
static int loggingPort = 4999;
/////////

@implementation BKPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
	BKPSplashViewController *splashVC = [[BKPSplashViewController alloc] init];
	[[self window] setRootViewController:splashVC];
    
	[self startWirelessLogging];
//	NSLog(@"\n\n\nGood morning.\nThese are the captain's logs from run starting at %@.", [NSDate date]);
	
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void)startWirelessLogging {
	if (!useWirelessLogging)
		return;
	
	NSError *error;
	
	[STWirelessLog broadcastLogsToWirelessConsoleAtAddress:loggingIP usingPort:loggingPort error:&error];
	
	if (error)
		NSLog(@"Error starting STWirelessLog: %@", error);
	else
		NSLog(@"STWirelessLog to %@:%d began.", loggingIP, loggingPort);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

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

	[self startWirelessLogging];
	
	BKPSplashViewController *splashVC = [[BKPSplashViewController alloc] init];
	[[self window] setRootViewController:splashVC];
    
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

@end

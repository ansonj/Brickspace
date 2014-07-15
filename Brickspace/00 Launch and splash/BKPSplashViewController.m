//
//  BKPViewController.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPSplashViewController.h"

// For random bricks inside the little LegoView
#import "BKPLegoView.h"
#import "BKPPlacedBrick.h"

// For loading the next VC
#import "BKPCapturingViewController.h"

@interface BKPSplashViewController ()
@property (weak, nonatomic) IBOutlet BKPLegoView *legoView;
@end

@implementation BKPSplashViewController

@synthesize legoView;

- (void)viewDidAppear:(BOOL)animated {
	NSMutableArray *brickSet = [NSMutableArray array];
	for (int count = 0; count < 6; count++) {
		BKPPlacedBrick *placedBrick = [[BKPPlacedBrick alloc] init];
		[placedBrick setBrick:[BKPBrick brickWithColor:[BKPBrickColorOptions randomColor] shortSide:2 longSide:4 andHeight:3]];
		[brickSet addObject:placedBrick];
	}
	[brickSet[0] setX:-4 Y:0 andZ:0];
	[brickSet[1] setX:0  Y:0 andZ:0];
	[brickSet[2] setX:4  Y:0 andZ:0];
	[brickSet[3] setX:-2 Y:0 andZ:3];
	[brickSet[4] setX:2  Y:0 andZ:3];
	[brickSet[5] setX:0  Y:0 andZ:6];
	
	[legoView displayBricks:[NSSet setWithArray:brickSet]];
}

- (IBAction)startButtonPressed:(id)sender {
	BKPCapturingViewController *capturingVC = [[BKPCapturingViewController alloc] init];
	[[[UIApplication sharedApplication] keyWindow] setRootViewController:capturingVC];
}

@end

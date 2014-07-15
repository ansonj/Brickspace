//
//  BKPViewController.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPSplashViewController.h"

#import "BKPLegoView.h"
#import "BKPPlacedBrick.h"

@interface BKPSplashViewController ()
@property (weak, nonatomic) IBOutlet BKPLegoView *legoView;
@end

@implementation BKPSplashViewController

@synthesize legoView;

- (void)viewDidAppear:(BOOL)animated {
	NSMutableArray *brickSet = [NSMutableArray array];
	BKPBrick *oneBrickToRuleThemAll = [BKPBrick brickWithColor:BKPBrickColorRed shortSide:2 longSide:4 andHeight:3];
	for (int count = 0; count < 6; count++) {
		BKPPlacedBrick *placedBrick = [[BKPPlacedBrick alloc] init];
		[placedBrick setBrick:oneBrickToRuleThemAll];
		[brickSet addObject:placedBrick];
	}
	[brickSet[0] setX:-4 Y:0 andZ:0];
	[brickSet[1] setX:0 Y:0 andZ:0];
	[brickSet[2] setX:4 Y:0 andZ:0];
	[brickSet[3] setX:-2 Y:0 andZ:3];
	[brickSet[4] setX:2 Y:0 andZ:3];
	[brickSet[5] setX:0 Y:0 andZ:6];
	
	[legoView displayBricks:[NSSet setWithArray:brickSet]];
}

@end

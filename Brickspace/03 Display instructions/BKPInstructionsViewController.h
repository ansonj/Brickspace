//
//  BKPInstructionsViewController.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKPInstructionsViewController : UIViewController <UIAlertViewDelegate>

- (void)setUpWithCountedBricks:(NSSet *)newSet;

- (void)updateUI;

@end

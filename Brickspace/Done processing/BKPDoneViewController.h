//
//  BKPDoneViewController.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKPBrickSet.h"

@interface BKPDoneViewController : UIViewController

- (void)setUpWithBrickSet:(BKPBrickSet *)newSet;

- (void)updateUI;

@end

//
//  BKPLegoView.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/9/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrickColorOptions.h"
#import <UIKit/UIKit.h>

@interface BKPLegoView : UIView

@property (nonatomic) BOOL drawAxes;
@property (nonatomic) BOOL drawBaseplate;
@property (nonatomic, readonly) BKPBrickColor baseplateColor;
@property (nonatomic, readonly) int baseplateSize;

- (void)setBaseplateColor:(BKPBrickColor)newColor andSize:(int)newSize;

- (void)displayBricks:(NSSet *)bricks;

@end

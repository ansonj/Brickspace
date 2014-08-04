//
//  BKPBrickSizeGuesser.h
//  Brickspace
//
//  Created by Anson Jablinski on 8/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKPBrickSizeGuesser : NSObject

+ (int)brickLongSideLengthIfShortSideIs2AndVolumeIs:(float)volume;

@end

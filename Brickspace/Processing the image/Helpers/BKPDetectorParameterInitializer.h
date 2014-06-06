//
//  BKPDetectorParameterInitializer.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/5/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKPBrickCounter.h"

@interface BKPDetectorParameterInitializer : NSObject

typedef NS_ENUM(NSUInteger, BKPDPIParameterSet) {
	BKPDPIParameterSetDefault,
	BKPDPIParameterSetLego1
};

+ (void)setParameters:(BKPDPIParameterSet)parameters
		   forCounter:(BKPBrickCounter *)counter;

@end

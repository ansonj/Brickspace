//
//  BKPTempImageHolder.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKPTempImageHolder : NSObject

@property (nonatomic) UIImage* image;

- (id)initWithImage:(UIImage *)newImage;

@end

//
//  BKPKeypointBrickPair.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/25/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrick.h"
#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>

@interface BKPKeypointBrickPair : NSObject

@property (nonatomic) cv::KeyPoint keypoint;
@property (nonatomic) BKPBrick *brick;

- (id)initWithKeypoint:(cv::KeyPoint)keypoint;

- (id)initWithKeypoint:(cv::KeyPoint)keypoint
			  andBrick:(BKPBrick *)brick;

@end

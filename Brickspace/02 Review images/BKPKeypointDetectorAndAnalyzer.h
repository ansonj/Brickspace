//
//  BKPKeypointDetectorAndAnalyzer.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/25/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKPKeypointDetectorAndAnalyzer : NSObject

+ (void)detectKeypoints:(NSMutableArray *)keypoints
                inImage:(UIImage *)image;

+ (void)assignBricksToKeypoints:(NSMutableArray *)keypoints
                      fromImage:(UIImage *)image;

@end

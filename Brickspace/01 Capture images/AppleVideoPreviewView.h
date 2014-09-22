//
//  AppleVideoPreviewView.h
//  Brickspace
//
//  Created by Anson Jablinski on 6/23/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

// This class is based on AVCamPreviewView,
// from Apple's AVCam sample project.

#import <Foundation/Foundation.h>

@class AVCaptureSession;

@interface AppleVideoPreviewView : UIView

@property (nonatomic) AVCaptureSession *session;

@end

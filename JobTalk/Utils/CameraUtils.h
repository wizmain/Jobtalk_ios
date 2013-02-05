//
//  CameraUtils.h
//  interview
//
//  Created by 김규완 on 12. 8. 1..
//  Copyright (c) 2012년 김규완. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraUtils : NSObject

+ (int)numberOfCameras;
+ (BOOL)backCameraAvailable;
+ (BOOL)frontCameraAvailable;
+ (AVCaptureDevice *)backCamera;
+ (AVCaptureDevice *)frontCamera;

@end

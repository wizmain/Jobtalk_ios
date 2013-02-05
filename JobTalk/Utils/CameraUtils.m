//
//  CameraUtils.m
//  interview
//
//  Created by 김규완 on 12. 8. 1..
//  Copyright (c) 2012년 김규완. All rights reserved.
//

#import "CameraUtils.h"

@implementation CameraUtils

+ (int)numberOfCameras
{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
}

+ (BOOL)backCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for(AVCaptureDevice *device in videoDevices)
        if(device.position == AVCaptureDevicePositionBack)
            return YES;
    
    return NO;
}

+ (BOOL)frontCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in videoDevices) {
        if(device.position == AVCaptureDevicePositionFront)
            return YES;
    }
    
    return NO;
}

+ (AVCaptureDevice *)backCamera
{
    NSArray *videoDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for(AVCaptureDevice *device in videoDevice)
        if (device.position == AVCaptureDevicePositionBack) {
            return device;
        }
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

+ (AVCaptureDevice *)frontCamera
{
    NSArray *videoDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for(AVCaptureDevice *device in videoDevice)
        if (device.position == AVCaptureDevicePositionFront) {
            return device;
        }
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

@end

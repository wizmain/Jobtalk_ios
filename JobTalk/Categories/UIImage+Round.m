//
//  UIImage+Round.m
//  mClass
//
//  Created by 김규완 on 11. 4. 7..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Round.h"


@implementation UIImage (UIImage_Round)

- (UIImage*)imageScaledToSize:(CGSize)size {
    
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

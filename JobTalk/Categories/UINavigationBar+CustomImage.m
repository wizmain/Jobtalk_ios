//
//  UINavigationBar+CustomImage.m
//  mClass
//
//  Created by 김규완 on 11. 4. 5..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar+CustomImage.h"

@implementation UINavigationBar (UINavigationBar_CustomImage)
- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"navigation_back.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    
    
    //if(self.tag == CustomNavBarTag){//특정 바만 해야할때
        
    //} else {
    //  [super drawRect:rect];
    //}
}
@end

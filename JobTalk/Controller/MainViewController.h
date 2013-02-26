//
//  MainViewController.h
//  interview
//
//  Created by 김규완 on 12. 7. 31..
//  Copyright (c) 2012년 김규완. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoginViewController.h"

@interface MainViewController : UIViewController <UINavigationControllerDelegate, UITabBarControllerDelegate> {
    UITabBarController *tabController;
    UINavigationController *naviController;
    LoginViewController *loginController;
}

@property (nonatomic, retain) UITabBarController *tabController;
@property (nonatomic, retain) UINavigationController *naviController;
@property (nonatomic, retain) LoginViewController *loginController;
@property (nonatomic, assign) BOOL isRotate;

- (void)switchLoginView;
- (void)switchTabView:(NSInteger)tabIndex;
- (void)switchTalkView:(NSInteger)masterUid;
- (void)setTabBarBadgeNumber:(NSInteger)tabID badgeValue:(NSString*)badgeValue;
- (void)updateUnReadTalkCount;
@end

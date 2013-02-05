//
//  LoginViewController.h
//  interview
//
//  Created by 김규완 on 12. 7. 31..
//  Copyright (c) 2012년 김규완. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Utils/ProgressIndicator.h"
@class LoginProperties;

@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    UITextField *txtUserID;
	UITextField *txtPassword;
	UISwitch *swSaveID;
	UISwitch *swAutoLogin;
	UIButton *loginButton;
	ProgressIndicator *spinner;
	LoginProperties *loginProperties;
}

@property (nonatomic, retain) IBOutlet UITextField *txtUserID;
@property (nonatomic, retain) IBOutlet UITextField *txtPassword;
@property (nonatomic, retain) IBOutlet UISwitch *swSaveID;
@property (nonatomic, retain) IBOutlet UISwitch *swAutoLogin;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (nonatomic, retain) LoginProperties *loginProperties;

- (IBAction)loginButtonPressed:(id)sender;

@end

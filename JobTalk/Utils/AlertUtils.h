//
//  AlertUtils.h
//  mClass
//
//  Created by 김규완 on 10. 12. 7..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

void AlertWithError(NSError *error);
void AlertWithMessage(NSString *message);
void AlertWithMessageAndDelegate(NSString *message, id delegate);
void AlertWithMessageAndIndicator(NSString *message, id delegate);
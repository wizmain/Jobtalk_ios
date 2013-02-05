//
//  CustomTableCell1.h
//  JobTalk
//
//  Created by 김규완 on 13. 1. 11..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableCell1 : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *infoLabel;
@property (nonatomic, retain) IBOutlet UIButton *button1;

+ (id)cellWithNib;
@end

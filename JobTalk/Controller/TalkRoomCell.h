//
//  TalkRoomCell.h
//  JobTalk
//
//  Created by 김규완 on 13. 1. 23..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TalkRoomCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *lastMessageLabel;
@property (nonatomic, retain) IBOutlet UILabel *lastMessageDateLabel;
@property (nonatomic, retain) IBOutlet UIButton *unreadMessageCntButton;

+ (id)cellWithNib;

@end

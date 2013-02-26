//
//  FriendListCell.h
//  JobTalk
//
//  Created by 김규완 on 13. 2. 5..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendListCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

+ (id)cellWithNib;

@end

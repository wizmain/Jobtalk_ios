//
//  FriendListCell.m
//  JobTalk
//
//  Created by 김규완 on 13. 2. 5..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "FriendListCell.h"

@implementation FriendListCell

@synthesize thumbnailImageView;
@synthesize titleLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (id)cellWithNib
{
    
    UIViewController *controller = [[UIViewController alloc] initWithNibName:@"FriendListCell" bundle:nil];
    FriendListCell *cell = (FriendListCell *)controller.view;
    
    
    
    [controller release];
    
    return cell;
}

- (void)willTransitionToState:(UITableViewCellStateMask)state{
    
    [super willTransitionToState:state];
    
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
        
        for (UIView *subview in self.subviews) {
            
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                
                UIImageView *deleteBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 64, 33)];
                [deleteBtn setImage:[UIImage imageNamed:@"friend_out.png"]];
                [[subview.subviews objectAtIndex:0] addSubview:deleteBtn];
                [deleteBtn release];
                
            }
            
        }
    }
    
}

@end

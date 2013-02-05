//
//  TalkRoomCell.m
//  JobTalk
//
//  Created by 김규완 on 13. 1. 23..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "TalkRoomCell.h"

@implementation TalkRoomCell

@synthesize thumbnailImageView;
@synthesize titleLabel;
@synthesize lastMessageDateLabel;
@synthesize lastMessageLabel;
@synthesize unreadMessageCntButton;

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
    
    UIViewController *controller = [[UIViewController alloc] initWithNibName:@"TalkRoomCell" bundle:nil];
    TalkRoomCell *cell = (TalkRoomCell *)controller.view;
    
    
    
    [controller release];
    
    return cell;
}
/*
- (void)layoutSubviews {
    CGRect b = [self bounds];
    b.size.height -= 1; // leave room for the separator line
    b.size.width += 30; // allow extra width to slide for editing
    b.origin.x -= (self.editing) ? 0 : 30; // start 30px left unless editing
    [self.contentView setFrame:b];
    [super layoutSubviews];
}
*/

- (void)willTransitionToState:(UITableViewCellStateMask)state{
    
    [super willTransitionToState:state];
    
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
        
        for (UIView *subview in self.subviews) {
            
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                
                UIImageView *deleteBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 64, 33)];
                [deleteBtn setImage:[UIImage imageNamed:@"talkout.png"]];
                [[subview.subviews objectAtIndex:0] addSubview:deleteBtn];
                [deleteBtn release];
                
            }
            
        }
    } 
    
}


- (void)dealloc
{
    [thumbnailImageView release];
    [titleLabel release];
    [lastMessageLabel release];
    [lastMessageDateLabel release];
    [unreadMessageCntButton release];
    [super dealloc];
}

@end

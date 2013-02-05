//
//  CustomTableCell1.m
//  JobTalk
//
//  Created by 김규완 on 13. 1. 11..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "CustomTableCell1.h"

@implementation CustomTableCell1

@synthesize thumbnailImageView;
@synthesize titleLabel;
@synthesize infoLabel;
@synthesize button1;

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
    
    UIViewController *controller = [[UIViewController alloc] initWithNibName:@"CustomTableCell1" bundle:nil];
    CustomTableCell1 *cell = (CustomTableCell1 *)controller.view;
    
    
    
    [controller release];
    
    return cell;
}


- (void)dealloc
{
    [thumbnailImageView release];
    [titleLabel release];
    [infoLabel release];
    [button1 release];
    [super dealloc];
}
@end

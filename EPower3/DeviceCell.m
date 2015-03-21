//
//  DeviceCell.m
//  EPower3
//
//  Created by JIMMY on 2013/11/14.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import "DeviceCell.h"

@implementation DeviceCell

@synthesize computerNameLabel;
@synthesize loginNameLabel;
@synthesize deviceIdLabel;
@synthesize externalIPLabel;
@synthesize healthyImageView;
@synthesize dateUpdated;

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

@end

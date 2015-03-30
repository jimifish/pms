//
//  FSCell.m
//  EPower3
//
//  Created by Jimmy Yu on 3/23/15.
//  Copyright (c) 2015 JIMMY. All rights reserved.
//

#import "FSCell.h"

@implementation FSCell

@synthesize ticketId;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

@end

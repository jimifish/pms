//
//  DeviceCell.h
//  EPower3
//
//  Created by JIMMY on 2013/11/14.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *deviceIdLabel;
@property (nonatomic, strong) IBOutlet UILabel *computerNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *loginNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *externalIPLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateUpdated;
@property (nonatomic, strong) IBOutlet UIImageView *healthyImageView;
@property (strong, nonatomic) IBOutlet UILabel *uiVersionLabel;
@property (strong, nonatomic) IBOutlet UILabel *agentVersionLabel;


@end

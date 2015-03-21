//
//  DevicesViewController.h
//  EPower3
//
//  Created by JIMMY on 2013/11/13.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceDetailViewController.h"

@interface DevicesViewController : UITableViewController<DeviceDetailViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *deviceList;
@property (strong, nonatomic) IBOutlet UITableView *tblDevices;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

-(void) refreshDevices;

@end

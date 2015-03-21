//
//  DeviceDetailViewController.h
//  EPower3
//
//  Created by JIMMY on 2013/11/25.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceImageViewController.h"

@class DeviceDetailViewController;
@class Device;

@protocol DeviceDetailViewControllerDelegate

//-(void)passValue:(Device*)device;
-(void)deviceDetailViewControllerDidBack: (DeviceDetailViewController *)controller;

@end

@interface DeviceDetailViewController : UITableViewController<DeviceImageViewControllerDelegate, UIAlertViewDelegate>
{
    UITextField* m_tfMSg;
    UITextField* m_tfPassword;
}

@property (strong, nonatomic) Device* device;


@property (nonatomic, weak) id <DeviceDetailViewControllerDelegate> delegate;

@end

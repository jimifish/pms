//
//  DeviceDetailsViewController.h
//  EPower3
//
//  Created by JIMMY on 2013/11/15.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceImageViewController;
@class Device;

@protocol DeviceImageViewControllerDelegate

//-(void)passValue:(Device*)device;
-(void)deviceImageViewControllerDidBack: (DeviceImageViewController *)controller;

@end

@interface DeviceImageViewController : UIViewController<UIScrollViewDelegate>


//@property (strong, nonatomic) IBOutlet UITextView *tvInternalIP;

@property (strong, nonatomic) IBOutlet UIImageView *imgDevice;

@property (strong, nonatomic) IBOutlet UIScrollView *svDevice;

@property (strong, nonatomic) Device* device;

-(BOOL) getScreenshot: (NSString*)tokenId;
-(BOOL) queryScreenshot: (NSString*)tokenId;

@property (nonatomic, weak) id <DeviceImageViewControllerDelegate> delegate;

@end

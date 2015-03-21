//
//  InternalIPViewController.h
//  EPower3
//
//  Created by JIMMY on 2013/11/28.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

@class Device;

#import <UIKit/UIKit.h>

@interface InternalIPViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *tvIP;
@property (strong, nonatomic) Device* device;

@end

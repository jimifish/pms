//
//  DeviceSendMsgViewController.h
//  EPower3
//
//  Created by JIMMY on 2013/11/29.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

@class Device;
#import <UIKit/UIKit.h>

@interface PowerActionViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate>

@property (strong, nonatomic) Device* device;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerPowerAction;
@property (strong, nonatomic) NSArray* powerActionList;


@end

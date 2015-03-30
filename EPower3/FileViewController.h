//
//  FileViewController.h
//  EPower3
//
//  Created by Jimmy Yu on 3/30/15.
//  Copyright (c) 2015 JIMMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "File.h"

@interface FileViewController : UIViewController
- (IBAction)openIn:(id)sender;

@property (nonatomic) NSInteger		ticketId;
@property (strong, nonatomic) Device* device;
@property (strong, nonatomic) File* file;

@end

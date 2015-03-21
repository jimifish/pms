//
//  InternalIPViewController.m
//  EPower3
//
//  Created by JIMMY on 2013/11/28.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import "InternalIPViewController.h"
#import "Device.h"

@interface InternalIPViewController ()

@end

@implementation InternalIPViewController

@synthesize tvIP;
@synthesize device;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    tvIP.text = device.internalIPList;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

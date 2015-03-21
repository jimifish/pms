//
//  DeviceSendMsgViewController.m
//  EPower3
//
//  Created by JIMMY on 2013/11/29.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import "PowerActionViewController.h"
#import "Device.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import "Private.h"

@interface PowerActionViewController ()

@end

@implementation PowerActionViewController

@synthesize powerActionList;
@synthesize pickerPowerAction;
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
    
    NSArray* array = [[NSArray alloc] initWithObjects:@"Hibernate", @"Lock PC", @"Standby", @"Log off", @"Power off", @"Reboot", nil];
    powerActionList = array;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 10:
            if(buttonIndex == 1)
            {
                NSInteger nIdx = [pickerPowerAction selectedRowInComponent:0];
                NSInteger nAction = 0;
                switch (nIdx) {
                    case 0:
                        nAction = POWER_ACTION_HIBERNATE;
                        break;
                    case 1:
                        nAction = POWER_ACTION_LOCK_PC;
                        break;
                    case 2:
                        nAction = POWER_ACTION_STANDBY;
                        break;
                    case 3:
                        nAction = POWER_ACTION_LOGOFF;
                        break;
                    case 4:
                        nAction = POWER_ACTION_POWEROFF;
                        break;
                    case 5:
                        nAction = POWER_ACTION_REBOOT;
                        break;
                    default:
                        break;
                }
                
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.securityPolicy.allowInvalidCertificates = YES;
                NSString* strURL = [NSString stringWithFormat:@"%@%d&DeviceId=%@&cmd=%d&params=%ld", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_SEND_CMD, self.device.deviceId, SRV_CLINET_CMD_POWERACTION, (long)nAction];
                strURL = [Helper EncodeURI:strURL];
                NSLog(@"%@", strURL);
                [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     
                     @try
                     {
                         
                     }
                     @catch (NSException *exception) {
                         NSLog(@"%@", [exception description]);
                     }
                     
                     //NSLog(@"Device count: %d", [self.devices count]);
                     
                     //[self.tableView reloadData];
                     
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Error: %@", error);
                     NSLog(@"%@", operation.responseString);
                 }];

            }
            break;
        default:
            break;
    }
}

- (IBAction)didPowerAction:(id)sender {
    
    NSInteger nIdx = [pickerPowerAction selectedRowInComponent:0];
    NSString* strPowerAction = @"";
    switch (nIdx) {
        case 0:
            strPowerAction = @"hibernate";
            break;
        case 1:
            strPowerAction = @"lock";
            break;
        case 2:
            strPowerAction = @"stand by";
            break;
        case 3:
            strPowerAction = @"logoff";
            break;
        case 4:
            strPowerAction = @"poweroff";
            break;
        case 5:
            strPowerAction = @"reboot";
            break;
        default:
            break;
    }
    
    NSString* msg = [NSString stringWithFormat: @"Do you want to %@ for %@", strPowerAction, self.device.computerName];
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Confirm" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.tag = 10;
    
    [alert show];
    
}

#pragma mark - Picker Data Source Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [powerActionList count];
}

#pragma mark - Picker Delegate Methods

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [powerActionList objectAtIndex:row];
}

@end

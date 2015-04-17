//
//  DeviceDetailViewController.m
//  EPower3
//
//  Created by JIMMY on 2013/11/25.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import "DeviceDetailViewController.h"
#import "Device.h"
#import "AFNetworking.h"
#import "DeviceImageViewController.h"
#import "InternalIPViewController.h"
#import "PowerActionViewController.h"
#import "ImageListViewController.h"
#import "FSViewController.h"
#import "Constants.h"
#import "Private.h"

@interface DeviceDetailViewController ()

@end

@implementation DeviceDetailViewController

@synthesize device;

#pragma mark - DeviceImageViewControllerDelegate

-(void)deviceImageViewControllerDidBack:(DeviceImageViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:self.device.computerName];    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didBack:(id)sender {
    [self.delegate deviceDetailViewControllerDidBack:self];

}

- (IBAction)didReboot:(id)sender {
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Confirm" message:@"Do you want to reboot?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.tag = 20;
    
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case TAG_SEND_MSG:
            if(buttonIndex == 1)
            {
                @try {
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.securityPolicy.allowInvalidCertificates = YES;
                    NSString* strURL = [NSString stringWithFormat:@"%@3&DeviceId=%@&cmd=%d&params=%@", PMS_WEBAPP_REQ_URI, self.device.deviceId, SRV_CLINET_CMD_SEND_MSG, m_tfMSg.text];
                    strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
                @catch (NSException *exception) {
                    NSLog(@"%@", [exception description]);
                }
                @finally {
                    m_tfMSg = nil;
                }
            }
            break;
        case TAG_TERMINATE_CLIENT:
            if(buttonIndex == 1)
            {
                @try {
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.securityPolicy.allowInvalidCertificates = YES;
                    NSString* strURL = [NSString stringWithFormat:@"%@3&DeviceId=%@&cmd=%d", PMS_WEBAPP_REQ_URI, self.device.deviceId, SRV_CLINET_CMD_TERMINAL_SELF];
                    strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSLog(@"%@", strURL);
                    [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
                     {
                         
                         @try
                         {
                             NSInteger nRet = [[responseObject objectForKey:JSON_TAG_RETURNCODE] intValue];
                             NSLog(@"%@", [responseObject objectForKey:JSON_TAG_RETURNCODE]);
                             if(nRet == RET_SUCCESS)
                             {
                                 UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Terminate" message:@"Success" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                 
                                 [alert show];

                             }
                             else
                             {
                                 NSLog(@"failed");
                             }
                         }
                         @catch (NSException *exception) {
                             NSLog(@"%@", [exception description]);
                         }
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         NSLog(@"TAG_TERMINATE_CLIENT Error: %@", error);
                         NSLog(@"%@", operation.responseString);
                     }];
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", [exception description]);
                }
                @finally {
                    m_tfMSg = nil;
                }
            }
            break;
        case TAG_VIEW_IMG:
            @try {
                if([m_tfPassword.text isEqual:@"qaz"])
                {
                    ImageListViewController * imgListvc = [self.storyboard instantiateViewControllerWithIdentifier:ID_PAGE_IMAGE_LIST];
                    [self.navigationController pushViewController:imgListvc animated:YES];
                    imgListvc.device = device;
                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.description);
            }
            break;
        default:
            break;
    }
}

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0: // Internal IPs
                @try {
                    InternalIPViewController* ipvc = [self.storyboard instantiateViewControllerWithIdentifier:ID_PAGE_DEVICE_INT_IP];
                    [self.navigationController pushViewController:ipvc animated:YES];
                    ipvc.device = device;
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.description);
                }
                break;
            case 1: // Send message
                @try {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Enter message" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    m_tfMSg = [alert textFieldAtIndex:0];
                    
                    alert.tag = TAG_SEND_MSG;
                    [alert show];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.description);
                }
                break;
            case 2: // Power Action
                @try {
                    PowerActionViewController* pavc = [self.storyboard instantiateViewControllerWithIdentifier:ID_PAGE_DEVICE_POWER_ACTION];
                    [self.navigationController pushViewController:pavc animated:YES];
                    pavc.device = device;
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.description);
                }
                break;
            case 3: // Image view
                @try {
                    ImageListViewController * imgListvc = [self.storyboard instantiateViewControllerWithIdentifier:ID_PAGE_IMAGE_LIST];
                    [self.navigationController pushViewController:imgListvc animated:YES];
                    imgListvc.device = device;
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.description);
                }
                break;
            case 4: // Show UI
            @try {
                return;
                NSInteger nShow = 0;
                if([self.tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryNone){
                    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
                    nShow = 1;
                }
                else{
                    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
                }
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.securityPolicy.allowInvalidCertificates = YES;
                NSString* strURL = [NSString stringWithFormat:@"%@%d&DeviceId=%@&cmd=%d&params=%ld", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_SEND_CMD, self.device.deviceId, SRV_CLINET_CMD_TOGGLE_UI, (long)nShow];
                strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"%@", strURL);
                [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     
                     @try
                     {
                         
                     }
                     @catch (NSException *exception) {
                         NSLog(@"%@", [exception description]);
                     }
                     
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Error: %@", error);
                     NSLog(@"%@", operation.responseString);
                 }];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.description);
            }
                break;
            case 5: // File System
                @try {
                    int ticketId = arc4random_uniform(9999999);
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.securityPolicy.allowInvalidCertificates = YES;
                    NSString* strURL = [NSString stringWithFormat:@"%@%d&DeviceId=%@&cmd=%d&params=%d|", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_SEND_CMD, self.device.deviceId, SRV_CLINET_CMD_ENUMERATE_PATH, ticketId];
                    strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSLog(@"%@", strURL);
                    [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
                     {
                         @try
                         {
                             NSInteger nRet = [[responseObject objectForKey:JSON_TAG_RETURNCODE] intValue];
                             NSLog(@"%@", [responseObject objectForKey:JSON_TAG_RETURNCODE]);
                             if(nRet == RET_SUCCESS)
                             {
                                 sleep(1);
                                 
                                 FSViewController * fsListvc = [[FSViewController alloc] init];                                 
                                 fsListvc.device = device;
                                 fsListvc.ticketId = ticketId;
                                 [self.navigationController pushViewController:fsListvc animated:YES];
                                 //fsListvc.path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Files"];
                             }
                             else
                             {
                                 NSLog(@"failed");
                             }
                         }
                         @catch (NSException *exception) {
                             NSLog(@"%@", [exception description]);
                         }
                         
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         NSLog(@"Error: %@", error);
                         NSLog(@"%@", operation.responseString);
                     }];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.description);
                }
                break;
            case 6: // Terminate
                @try {
                    NSString* msg = [NSString stringWithFormat:@"Do you want to terminate %@", device.computerName];
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Confirm" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    alert.tag = TAG_TERMINATE_CLIENT;
                    
                    [alert show];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.description);
                }
                break;
            default:
                break;
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:ID_PAGE_DEVICE_IMAGE])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        DeviceImageViewController *deviceImageViewController = [[navigationController viewControllers]objectAtIndex:0];
        deviceImageViewController.delegate = self;
        deviceImageViewController.device = device;
    }
}




@end

//
//  DevicesViewController.m
//  EPower3
//
//  Created by JIMMY on 2013/11/13.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import "DevicesViewController.h"
#import "Device.h"
#import "AFNetworking.h"
//#import "MBProgressHUD.h"
#import "Constants.h"
//#import "SBJson.h"
#import "DeviceCell.h"
#import "DeviceDetailViewController.h"
#import "Helper.h"
#import "Private.h"

@interface DevicesViewController ()

@end

@implementation DevicesViewController

@synthesize deviceList;
@synthesize refreshControl;

-(UIImage*) imageForHealthy: (Device*) device
{
    NSString* strImage = IMG_CIRCLE_GREY;
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:-90];
    BOOL deviceUpdated = FALSE;
    BOOL sreenshotUpdated = FALSE;
    if ([date compare:device.dateUpdated] == NSOrderedAscending) deviceUpdated = TRUE;
    if ([date compare:device.dateScreenshot] == NSOrderedAscending) sreenshotUpdated = TRUE;
    
    if(deviceUpdated && sreenshotUpdated){
        strImage = IMG_CIRCLE_GREEN;
    }
    else if(deviceUpdated){
        strImage = IMG_CIRCLE_ORANGE;
    }
    else{
        strImage = IMG_CIRCLE_RED;
    }
    
    return [UIImage imageNamed:strImage];
}

- (IBAction)didAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Order By"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Join Time"
                                                    otherButtonTitles:@"Update Time", @"Computer Name", @"UI Version", @"Agent Version", @"Screenshot Time", nil];
    
    //也可以透過此方式新增按鈕
    //[actionSheet addButtonWithTitle:@"MSN"];
    
    //將actionSheet顯示於畫面上
    [actionSheet showInView:self.view];
}

//判斷ActionSheet按鈕事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //將按鈕的Title當作判斷的依據
    NSLog(@"%ld", (long)buttonIndex);
    
    if(buttonIndex == 6)return;
    
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSString stringWithFormat: @"%ld", (long)buttonIndex] forKey:KEY_DEVICD_ORDER];
    [userDefault synchronize];
    [self refreshDevices];
//    if([title isEqualToString:@"電話"]) {
//        contentLabel.text = @"可惜我們目前還沒有電話";
//    }
//    
//    else if([title isEqualToString:@"E-Mail"]) {
//        contentLabel.text = @"furnacedigital@gmail.com";
//    }
//    
//    else if([title isEqualToString:@"MSN"]) {
//        contentLabel.text = @"可惜我們目前還沒有MSN";
//    }
}

-(void)refreshDevices
{
    //set the title while refreshing
    //refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Refreshing the device list"];
    
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSString* strDeviceOrder = [userDefault stringForKey:KEY_DEVICD_ORDER];
    if(NULL == strDeviceOrder)
    {
        [userDefault setObject:DEVICE_ORDER_BY_JOIN_TIME forKey:KEY_DEVICD_ORDER];
        [userDefault synchronize];
        strDeviceOrder = @"0";
    }
    
    NSString* strURL = [NSString stringWithFormat:@"%@Device?orderBy=%d", PMS_WEBAPI_URI, [strDeviceOrder intValue]];
    strURL = [Helper EncodeURI:strURL];
    NSLog(@"%@", strURL);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:@"Basic cG1zOnhLY0ZZdjE4" forHTTPHeaderField:@"Authorization"];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.requestSerializer = requestSerializer;
    [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
        
        @try
        {
            NSArray *results = (NSArray*)responseObject;
            deviceList = [NSMutableArray arrayWithCapacity:results.count];
            for(NSDictionary* d in results)
            {
                Device* device = [[Device alloc] init];
                device.deviceId = [d objectForKey: KEY_DEVICEID];
                device.computerName = [d objectForKey: KEY_COMPUTERNAME];
                device.loginName = [d objectForKey: KEY_LOGINNAME];
                device.externalIP = [d objectForKey:KEY_EXTERNALIP];
                device.internalIPList = [d objectForKey:KEY_INTERNALIPLIST];
                device.uiVersion = [d objectForKey:KEY_UI_VERSION];
                device.agentVersion = [d objectForKey:KEY_AGENT_VERSION];
                
                NSDateFormatter* inputFormatter = [[NSDateFormatter alloc] init];
                [inputFormatter setDateFormat:WS_DATE_FORMAT];
                NSString* strDateUpdated = [d objectForKey:KEY_DATEUPDATED];
                NSString* strDateScreenshot = [d objectForKey:KEY_DATESCREENSHOT];
                device.dateUpdated = [inputFormatter dateFromString:strDateUpdated];
                device.dateScreenshot = [inputFormatter dateFromString:strDateScreenshot];
                
                [deviceList addObject:device];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", [exception description]);
        }
         
         NSLog(@"Device count: %lu", (unsigned long)[deviceList count]);
         
         [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"%@", operation.responseString);
    }];
    
    //set the date and time of refreshing
//    NSDateFormatter *formattedDate = [[NSDateFormatter alloc]init];
//    [formattedDate setDateFormat:@"MMM d, h:mm a"];
//    NSString *lastupdated = [NSString stringWithFormat:@"Last Updated on %@",[formattedDate stringFromDate:[NSDate date]]];
//    refreshControl	.attributedTitle = [[NSAttributedString alloc]initWithString:lastupdated];
//    //end the refreshing
    [refreshControl endRefreshing];
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
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.title = @"Devices";
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshDevices)
                  forControlEvents:UIControlEventValueChanged];
    [self.tblDevices addSubview:self.refreshControl];
    
    [self refreshDevices];
    
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(aTimerTick) userInfo:nil repeats:YES];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)aTimerTick
{
    [self refreshDevices];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [deviceList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell"];
    
    Device *device = [deviceList objectAtIndex:indexPath.row];
    //UILabel *nameLabel = (UILabel*)[cell viewWithTag:100];
    cell.computerNameLabel.text = device.computerName;
    cell.deviceIdLabel.text = device.deviceId;
    cell.loginNameLabel.text = device.loginName;
    cell.externalIPLabel.text = device.externalIP;
    cell.uiVersionLabel.text = device.uiVersion;
    cell.agentVersionLabel.text = device.agentVersion;
    
    NSDateFormatter* outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:UI_DATE_FORNAT];
    cell.dateUpdated.text = [outputFormatter stringFromDate:device.dateUpdated];
    cell.healthyImageView.image = [self imageForHealthy:device];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        Device *device = [deviceList objectAtIndex:indexPath.row];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy.allowInvalidCertificates = YES;
        NSString* strURL = [NSString stringWithFormat:@"%@%d&DeviceId=%@", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_DELETE_DEVICE, device.deviceId];
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
        
        [self.deviceList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Device* device = [deviceList objectAtIndex:indexPath.row];
    //NSIndexPath* path = [self.tableView indexPathForSelectedRow];
    //NSString* fileName = [thumbList objectAtIndex:path.row];
    
    DeviceDetailViewController* ddvc = [self.storyboard instantiateViewControllerWithIdentifier:ID_PAGE_DEVICE_DETAIL];
    [self.navigationController pushViewController:ddvc animated:YES];
    ddvc.device = device;
}

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

#pragma mark - DeviceDetailViewControllerDelegate

-(void)deviceDetailViewControllerDidBack:(DeviceDetailViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//-(void)playerDetailsViewControllerDidSave:(PlayerDetailsViewController *)controller
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//-(void)playerDetailsViewController:(PlayerDetailsViewController *)controller didAddPlayer:(Player *)player
//{
//    [self.players addObject:player];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.players count] -1 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath* path = [self.tableView indexPathForSelectedRow];
    Device* device = [deviceList objectAtIndex:path.row];
    
//    id deviceDetailPage = segue.destinationViewController;
//    //[deviceDetailPage setDevice:device];
//    [deviceDetailPage setValue:device.computerName forKey:@"deviceName"];
    
    UINavigationController *navigationController = segue.destinationViewController;
    DeviceDetailViewController *deviceDetailViewController = [[navigationController viewControllers]objectAtIndex:0];
    deviceDetailViewController.delegate = self;
    deviceDetailViewController.device = device;
}

@end

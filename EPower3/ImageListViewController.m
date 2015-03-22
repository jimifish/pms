//
//  ImageListViewController.m
//  EPower3
//
//  Created by JIMMY on 2013/12/1.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import "ImageListViewController.h"
#import "Device.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "ThumbnailViewController.h"
#import "Helper.h"
#import "Private.h"

@interface ImageListViewController ()

@end

@implementation ImageListViewController

@synthesize imageList;
@synthesize device;
@synthesize refreshControl;

-(void)refresh
{
    //set the title while refreshing
    //refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Refreshing the device list"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    NSString* strURL = [NSString stringWithFormat:@"%@%d&ComputerName=%@", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_GET_IMG_LIST, self.device.computerName];
    strURL = [Helper EncodeURI:strURL];
    NSLog(@"%@", strURL);
    [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         @try
         {
//             NSArray *results = (NSArray*)responseObject;
//             imageList = [NSMutableArray arrayWithCapacity:results.count];
//             
             NSInteger nRet = [[responseObject objectForKey:JSON_TAG_RETURNCODE] intValue];
             NSLog(@"%@", [responseObject objectForKey:JSON_TAG_RETURNCODE]);
             if(nRet == RET_SUCCESS)
             {
                 NSArray* dirList = responseObject[JSON_TAG_DIRLIST];
                 imageList = [NSMutableArray arrayWithCapacity:dirList.count];
                 for(NSString* strPath in dirList)
                 {
                     [imageList addObject:strPath];
                     NSLog(@"%@", strPath);
                 }
             }
             else
             {
                 NSLog(@"failed");
             }
         }
         @catch (NSException *exception) {
             NSLog(@"%@", [exception description]);
         }
         
         NSLog(@"image folder count: %lu", (unsigned long)[imageList count]);
         
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

- (IBAction)didAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Image List Action"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:@"Delete Computer Folder"
                                                   otherButtonTitles:nil, nil];
    
    //也可以透過此方式新增按鈕
    //[actionSheet addButtonWithTitle:@"MSN"];
    
    //將actionSheet顯示於畫面上
    [actionSheet showInView:self.view];
}


//判斷ActionSheet按鈕事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //將按鈕的Title當作判斷的依據
    NSLog(@"%ld", (long)buttonIndex);
    
    if(buttonIndex == 1)return;
    
    NSString* msg = [NSString stringWithFormat: @"Do you want to delete all images of %@?", self.device.computerName];
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Confirm" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.tag = 10;
    
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case 10:
        {
            if(buttonIndex == 1)
            {
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.securityPolicy.allowInvalidCertificates = YES;
                NSString* strURL = [NSString stringWithFormat:@"%@%d&%@=%@",
                                    PMS_WEBAPP_REQ_URI,
                                    SRV_CLEINT_REQ_DEL_FOLDER,
                                    KEY_COMPUTERNAME,
                                    self.device.computerName];
                strURL = [Helper EncodeURI:strURL];
                NSLog(@"%@", strURL);
                [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     @try
                     {
                         NSInteger nRet = [[responseObject objectForKey:JSON_TAG_RETURNCODE] intValue];
                         NSLog(@"%@", [responseObject objectForKey:JSON_TAG_RETURNCODE]);
                         if(nRet == RET_SUCCESS)
                         {
                             NSLog(@"Del computer folder success!");
                         }
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = device.computerName;//@"Image List";
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.tblImageList addSubview:self.refreshControl];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    return [imageList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    cell.textLabel.text = [imageList objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* path = [self.tableView indexPathForSelectedRow];
    NSString* folderName = [imageList objectAtIndex:path.row];
    
    ThumbnailViewController* tnvc = [self.storyboard instantiateViewControllerWithIdentifier:ID_PAGE_THUMBNAIL_LIST];
    [self.navigationController pushViewController:tnvc animated:YES];
    tnvc.device = device;
    tnvc.folderName = folderName;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        NSString* folderName = [imageList objectAtIndex:indexPath.row];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy.allowInvalidCertificates = YES;
        NSString* strURL = [NSString stringWithFormat:@"%@%d&%@=%@&FolderName=%@",
                            PMS_WEBAPP_REQ_URI,
                            SRV_CLEINT_REQ_DEL_FOLDER,
                            KEY_COMPUTERNAME,
                            self.device.computerName,
                            folderName];
        strURL = [Helper EncodeURI:strURL];
        NSLog(@"%@", strURL);
        [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             @try
             {
                 NSInteger nRet = [[responseObject objectForKey:JSON_TAG_RETURNCODE] intValue];
                 NSLog(@"%@", [responseObject objectForKey:JSON_TAG_RETURNCODE]);
                 if(nRet == RET_SUCCESS)
                 {
                     [self.imageList removeObjectAtIndex:indexPath.row];
                     [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationFade];
                 }
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
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end

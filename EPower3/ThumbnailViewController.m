//
//  ThumbnailViewController.m
//  EPower3
//
//  Created by JIMMY on 2013/12/4.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import "ThumbnailViewController.h"
#import "Device.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "ImageViewController.h"
#import "Helper.h"
#import "Private.h"
#import "MBProgressHUD.h"

@interface ThumbnailViewController ()

@end

@implementation ThumbnailViewController

@synthesize device;
//@synthesize thumbList;
@synthesize dictThumb;
@synthesize thumbImg;
@synthesize folderName;
@synthesize refreshControl;
@synthesize tblThumbnail;
@synthesize m_progressAlert;

#pragma mark - DeviceImageViewControllerDelegate

-(void)ImageViewControllerDidBack:(NSString *)fileName
{
    NSLog(@"%@", fileName);
    NSInteger idx = 0;
    for (NSString *key in [dictThumb allKeysForObject:fileName]) {
        NSLog(@"Key: %@", key);
        idx = [key intValue];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx - 1 inSection:0];
    [tblThumbnail scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];
}

-(IBAction)screenshot:(id)sender
{
    [self showProgress];
    
    @try {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *strTokenId = [dateFormatter stringFromDate:[NSDate date]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy.allowInvalidCertificates = YES;
        NSString* strURL = [NSString stringWithFormat:@"%@%d&DeviceId=%@&cmd=%d&params=%@", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_SEND_CMD, self.device.deviceId, SRV_CLINET_CMD_SCREENSHOT, strTokenId];
        NSString* encodeURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@", encodeURL);
        [manager GET:encodeURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             @try
             {
                 NSInteger nRet = [[responseObject objectForKey:JSON_TAG_RETURNCODE] intValue];
                 NSLog(@"%@", [responseObject objectForKey:JSON_TAG_RETURNCODE]);
                 if(nRet == RET_SUCCESS)
                 {
                     BOOL bSuccess = FALSE;
//                     NSInteger nCount = 0;
//                     while (!bSuccess && nCount < 5) {
//                         bSuccess = [self queryScreenshot:strTokenId];
//                         if(bSuccess)break;
//                         sleep(1);
//                         nCount++;
//                     }
                     
                     sleep(5);
                     
                     bSuccess = [self queryScreenshot:strTokenId];
                     [self refresh];
                     [m_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
                     //bSuccess = [self getScreenshot: strTokenId];
                     
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
        NSLog(@"%@", [exception description]);
    }
    @finally {
        
    }
}

-(BOOL)queryScreenshot:(NSString *)tokenId {
    __block BOOL bSuccess = FALSE;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    NSString* strURL = [NSString stringWithFormat:@"%@%d&TokenId=%@", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_QUERY_SCREENSHOT, tokenId];
    NSString* encodeURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", encodeURL);
    [manager GET:encodeURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         @try
         {
             NSInteger nRet = [[responseObject objectForKey:JSON_TAG_RETURNCODE] intValue];
             NSLog(@"%@", [responseObject objectForKey:JSON_TAG_RETURNCODE]);
             if(nRet == RET_SUCCESS)
             {
                 bSuccess = TRUE;
             }
             else
             {
                 bSuccess = FALSE;
             }
         }
         @catch (NSException *exception) {
             NSLog(@"%@", [exception description]);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         bSuccess = FALSE;
         NSLog(@"Error: %@", error);
         NSLog(@"%@", operation.responseString);
     }];
    
    
    return bSuccess;
}

-(void)showProgress{
    [m_progressAlert show];
}

-(void)refresh
{
    //set the title while refreshing
    //refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Refreshing the device list"];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Loading";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    NSString* strURL = [NSString stringWithFormat:@"%@%d&ComputerName=%@&FolderName=%@", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_GET_THUMB_LIST, self.device.computerName, folderName];
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
                 NSArray* array = responseObject[JSON_TAG_IMGLIST];
                 //thumbList = [NSMutableArray arrayWithCapacity:array.count];
                 dictThumb = [[NSMutableDictionary alloc]init];
                 NSInteger i = 1;
                 for(NSString* strThumb in array)
                 {
                     NSString *inStr = [NSString stringWithFormat:@"%ld", (long)i];
                     [dictThumb setObject:strThumb forKey:inStr];
                     //[thumbList addObject:strThumb];
                     NSLog(@"%@", strThumb);
                     i++;
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
         @finally
         {
             [self getAllThumbnils];
         }
         
         //NSLog(@"thumbnail count: %d", [thumbList count]);
         
         //[self.tableView reloadData];
         
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

-(void)getAllThumbnils
{
    NSLog(@"getAllThumbnils");
    for (NSString* key in dictThumb) {
        NSString* fileName = [dictThumb objectForKey:key];
        
        NSURL* filePath = [thumbImg objectForKey:fileName];
        if(nil != filePath)
        {
            NSLog(@"Get thumbnail from cache.");
            continue;
        }
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        manager.securityPolicy.allowInvalidCertificates = YES;
        NSString* strURL = [NSString stringWithFormat:@"%@%d&ComputerName=%@&FolderName=%@&FileName=%@", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_GET_THUMB, self.device.computerName, folderName, fileName];
        strURL = [Helper EncodeURI:strURL];
        NSLog(@"%@", strURL);
        
        NSURL* URL = [NSURL URLWithString:strURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        @try {
            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
                return [documentsDirectoryPath URLByAppendingPathComponent:[targetPath lastPathComponent]];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                NSLog(@"File downloaded to: %@", filePath);
                //cell.imageView.frame = CGRectMake(0,0,72,40);
                [thumbImg setObject:filePath forKey:fileName];
            }];
            [downloadTask resume];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        }
    }
    
    [self.tableView reloadData];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = folderName;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.tblThumbnail addSubview:self.refreshControl];
    
    m_progressAlert = [[UIAlertView alloc] initWithTitle:@"Get screenshot\nPlease wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = CGPointMake(m_progressAlert.bounds.size.width / 2, m_progressAlert.bounds.size.height / 2 + 10);
    [indicator startAnimating];
    [m_progressAlert addSubview:indicator];
    
    thumbImg = [[NSMutableDictionary alloc]init];
    
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
    return [dictThumb count];
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
    
    NSString *inStr = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
    NSString* fileName = [dictThumb objectForKey:inStr];
    //NSString* fileName = [thumbList objectAtIndex:indexPath.row];
    UILabel* lbl = [cell textLabel];
    NSDate* picDate = [Helper GetPicDate:fileName];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    lbl.text = [dateFormatter stringFromDate:picDate];
    UIFont* font = [UIFont fontWithName:@"TrebuchetMS" size:16.0];
    cell.textLabel.font = font;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSURL* filePath = [thumbImg objectForKey:fileName];
    if(nil != filePath)
    {
        cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:filePath]];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"Desktop_144x80.png"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* path = [self.tableView indexPathForSelectedRow];
    //NSString* fileName = [thumbList objectAtIndex:path.row];
    
    ImageViewController* ivc = [self.storyboard instantiateViewControllerWithIdentifier:ID_PAGE_IMAGE_VIEW];
    [self.navigationController pushViewController:ivc animated:YES];
    ivc.device = device;
    ivc.folderName = folderName;
    ivc.dictThumb = dictThumb;
    ivc.imgIndex = path.row + 1;
    ivc.delegate = self;
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

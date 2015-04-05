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

/**
 The downloadCount is used as a counter to ensure that all profile images are downloaded before reloading the tableView.
 */
@property int downloadCount;
@property (nonatomic) MBProgressHUD   *theHud;
@end

@implementation ThumbnailViewController

@synthesize device;
//@synthesize thumbList;
@synthesize dictThumb;
@synthesize dictTmp;
@synthesize thumbImg;
@synthesize folderName;
@synthesize refreshControl;
@synthesize tblThumbnail;
@synthesize m_progressAlert;
const int NCOUNT = 10;

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
                     //[self refresh];
                     [self downloadThumbList];
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
    [self downloadThumbList];
    
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
    
    _downloadCount = 0;
    
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
    
    [self downloadThumbList];
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
    UILabel* lbl = [cell textLabel];
    NSDate* picDate = [Helper GetPicDate:fileName];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    lbl.text = [dateFormatter stringFromDate:picDate];
    UIFont* font = [UIFont fontWithName:@"TrebuchetMS" size:16.0];
    cell.textLabel.font = font;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSLog(@"indexPath.row: %ld", indexPath.row);
    
    int nextDownloadNum = (int)(indexPath.row + (NCOUNT * 2));
    if(indexPath.row % NCOUNT == 0 && _downloadCount < nextDownloadNum)
    {
        NSLog(@"indexPath.row: %ld, all thumb: %ld, Show hud", indexPath.row, [dictThumb count]);
        [self showHud];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self downloadThumbs:nextDownloadNum fileNameForDownload:nil];
        });
    }
    
    NSURL* filePath = [thumbImg objectForKey:fileName];
    if(nil != filePath)
    {
        cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:filePath]];
        NSLog(@"Assign image from cache");
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"Desktop_144x80.png"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self downloadThumbs:0 fileNameForDownload:fileName];
        });
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* path = [self.tableView indexPathForSelectedRow];
    
    ImageViewController* ivc = [self.storyboard instantiateViewControllerWithIdentifier:ID_PAGE_IMAGE_VIEW];
    [self.navigationController pushViewController:ivc animated:YES];
    ivc.device = device;
    ivc.folderName = folderName;
    ivc.dictThumb = dictThumb;
    ivc.imgIndex = path.row + 1;
    ivc.delegate = self;
}

#pragma mark - Custom Download Methods
/**
 This method downloads the latest 50 tweets from the user's timeline.
 
 It then creates an NSURLSessionDownloadTask to download the profile images of each tweet author in the timeline. Once all profile images are downloaded the tableView is reloaded and presented to the user.
 @warning This is a very syncronous method of displaing tweets and not very user friendly.
 @see downloadProfileImages
 */
-(void)downloadThumbList
{
    //[self showHud];
    
    dictThumb = [[NSMutableDictionary alloc]init];
    
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
                 
                 NSInteger i = 1;
                 for(NSString* strThumb in array)
                 {
                     NSString *inStr = [NSString stringWithFormat:@"%ld", (long)i];
                     [dictThumb setObject:strThumb forKey:inStr];
                     //NSLog(@"%@", strThumb);
                     i++;
                 }
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self downloadThumbs:(int)(NCOUNT) fileNameForDownload:nil];
                 });
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
             //[self getAllThumbnils];
         }
         
         [self.tableView reloadData];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         NSLog(@"%@", operation.responseString);
     }];
    
    // Memory Management
    strURL = nil;
    manager = nil;
    
    [refreshControl endRefreshing];
}


-(void)downloadThumbs:(int)stopInIdx fileNameForDownload:(NSString*)fileNameForDownload
{
    if (nil != fileNameForDownload || (_downloadCount < [dictThumb count] && _downloadCount < stopInIdx))
    {
        NSString* fileName = nil;
        
        if(nil != fileNameForDownload)
        {
            NSLog(@"Assign filename directly.");
            fileName = fileNameForDownload;
        }
        else
        {
            NSLog(@"_downloadCount: %d, stopInIdx: %d", _downloadCount, stopInIdx);
            NSString *inStr = [NSString stringWithFormat:@"%d", _downloadCount + 1];
            fileName = [dictThumb objectForKey:inStr];
        }
        
        if(nil == fileName)
        {
            NSLog(@"Filename still nil then return.");
            return;
        }
        
        NSURL* filePath = [thumbImg objectForKey:fileName];
        if(nil != filePath)
        {
            NSLog(@"Get thumbnail from cache.");
            return;
        }
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        manager.securityPolicy.allowInvalidCertificates = YES;
        NSString* strURL = [NSString stringWithFormat:@"%@%d&ComputerName=%@&FolderName=%@&FileName=%@", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_GET_THUMB, self.device.computerName, folderName, fileName];
        strURL = [Helper EncodeURI:strURL];
        //NSLog(@"%@", strURL);
        
        NSURL* URL = [NSURL URLWithString:strURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        @try {
            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
            {
                NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
                return [documentsDirectoryPath URLByAppendingPathComponent:[targetPath lastPathComponent]];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                //NSLog(@"File downloaded to: %@", filePath);
                if(nil != filePath)
                {
                    [thumbImg setObject:filePath forKey:fileName];
                    
                    _downloadCount++;
                }
                else
                {
                    NSLog(@"filePath is nil.");
                }
                
                if (fileNameForDownload == nil && _downloadCount <= [dictThumb count])
                {
                    usleep(100000);
                    [self downloadThumbs:stopInIdx fileNameForDownload:nil];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideHud];
                        [self.tableView reloadData];
                    });
                }
            }];
            [downloadTask resume];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud];
            [self.tableView reloadData];
            if(_downloadCount >= [dictThumb count])
            {
                _downloadCount = 0;
            }
        });
    }
}


//#pragma mark - NSURLSessionDownloadDelegate
///* Sent when a download task that has completed a download.  The delegate should
// * copy or move the file at the given location to a new location as it will be
// * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
// * still be called.
// */
//- (void)URLSession:(NSURLSession *)session
//      downloadTask:(NSURLSessionDownloadTask *)downloadTask
//didFinishDownloadingToURL:(NSURL *)location
//{
//    // Download Task
//    //NSLog(@"Download Task");
//    [session invalidateAndCancel];
//    NSData *imageData      = [NSData dataWithContentsOfURL:location];
//    UIImage *imageFromData = [UIImage imageWithData:imageData];
//    TWBTweetObject *obj    = [_arrayOfTweets objectAtIndex:_downloadCount];
//    obj.profileImage       = imageFromData;
//    obj                    = nil;
//    
//    _downloadCount++;
//    
//    if (_downloadCount <= [dictThumb count])
//    {
//        [self downloadThumbs];
//    }
//}

#pragma mark - NSURLSessionDelegate
/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //NSLog(@"Did Write Data");
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

#pragma mark - ProgressHud
-(void)showHud
{
    if (_theHud == nil) {
        _theHud           = [[MBProgressHUD alloc] init];
    }
    
    NSLog(@"Show Hud...");
    _theHud           = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _theHud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    _theHud.labelText = @"Downloading thumbmail";
}

-(void)hideHud
{
    [_theHud hide:YES];
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

//
//  FSViewController.m
//  EPower3
//
//  Created by Jimmy Yu on 3/23/15.
//  Copyright (c) 2015 JIMMY. All rights reserved.
//

#import "ImageViewController.h"
#import "FSViewController.h"
#import "Device.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import "Private.h"
#import "File.h"
#import "FSCell.h"


@interface FSViewController ()
@property (nonatomic, strong) UIDocumentInteractionController *controller;
@end

@implementation FSViewController

@synthesize path,visibleExtensions,fsList;
@synthesize m_progressAlert;

#pragma mark - DeviceImageViewControllerDelegate

-(void)ImageViewControllerDidBack:(NSString *)fileName
{
    NSLog(@"%@", fileName);
//    NSInteger idx = 0;
//    for (NSString *key in [dictThumb allKeysForObject:fileName]) {
//        NSLog(@"Key: %@", key);
//        idx = [key intValue];
//    }
//    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx - 1 inSection:0];
//    [tblThumbnail scrollToRowAtIndexPath:indexPath
//                        atScrollPosition:UITableViewScrollPositionTop
//                                animated:YES];
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//        self.title = @"File Browser";
//        visibleExtensions = [NSArray arrayWithObjects:@"txt", @"htm", @"html", @"pdb", @"pdf", @"jpg", @"png", @"gif", nil];
//        fsList = [[NSMutableArray alloc] init];
//    }
//    return self;
//}

//- (id)init
//{
//    if (self = [super initWithStyle:UITableViewStyleGrouped])
//    {
//        //self.title = self.viewTitle;
//        visibleExtensions = [NSArray arrayWithObjects:@"txt", @"htm", @"html", @"pdb", @"pdf", @"jpg", @"png", @"gif", nil];
//        fsList = [[NSMutableArray alloc] init];
//    }
//    return self;
//}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        visibleExtensions = [NSArray arrayWithObjects:@"txt", @"htm", @"html", @"pdb", @"pdf", @"jpg", @"png", @"gif", nil];
        
        imgExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", @"png", @"gif", @"bmp", nil];
        fsList = [[NSMutableArray alloc] init];
    }
    return self;
}

//- (void)setPath:(NSString*)newPath
//{
//    path = newPath;
//    self.title = [path lastPathComponent];
//    [self reloadFiles];
//}

-(void)setViewTitle:(NSString *)viewTitle
{
    self.title = viewTitle;
}

-(void)setTicketId:(NSInteger)ticketId
{
    [self queryFS:ticketId bFilesys:TRUE];
}

-(void)queryFS:(NSInteger)ticketId bFilesys:(BOOL)isFileSys {
    
    //sleep(2);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    NSString* strURL = [NSString stringWithFormat:@"%@%d&ticketId=%ld", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_QUERY_FS, (long)ticketId];
    NSString* encodeURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", encodeURL);
    
    [manager GET:encodeURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         @try
         {
             NSInteger nRet = [[responseObject objectForKey:JSON_TAG_RETURNCODE] intValue];
             NSLog(@"queryFS return code: %@", [responseObject objectForKey:JSON_TAG_RETURNCODE]);
             if(nRet == RET_SUCCESS)
             {
                 if(isFileSys)
                 {
                     [self getFS:ticketId];
                 }
                 else
                 {
                     NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
                     File *aFile = [fsList objectAtIndex:selectedIndexPath.row];
                     
                     BOOL isImage = FALSE;
                     NSString* strExt = [aFile.path pathExtension];
                     for(NSString* ext in imgExtensions)
                     {
                         if([ext isEqualToString:strExt])
                         {
                             isImage = TRUE;
                             break;
                         }
                     }
                     
                     if(isImage)
                     {
                         ImageViewController* ivc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:ID_PAGE_IMAGE_VIEW];
                         
                         [self.navigationController pushViewController:ivc animated:YES];
                         ivc.device = self.device;
                         ivc.imgFileName = aFile.name;
                         ivc.ticketId = ticketId;
                         ivc.delegate = self;
                     }
                     else
                     {
                         NSLog(@"Not image");
                         
                         NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                         AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                         manager.securityPolicy.allowInvalidCertificates = YES;
                         
                         NSString* strURL = [NSString stringWithFormat:@"%@%d&ticketId=%ld", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_GET_FILE, (long)self.ticketId];

                         strURL = [Helper EncodeURI:strURL];
                         NSLog(@"%@", strURL);
                         NSURL *URL = [NSURL URLWithString:strURL];
                         NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                         @try {
                             NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                 NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
                                 return [documentsDirectoryPath URLByAppendingPathComponent:[targetPath lastPathComponent]];
                             } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                 NSLog(@"File downloaded to: %@", filePath);
                                 
                                 NSString* downloadFilePath = [NSString stringWithFormat:@"Documents/%@.%@", aFile.name, strExt];
                                 
                                 NSString *fPath=[NSHomeDirectory() stringByAppendingPathComponent:downloadFilePath];
                                 
                                 NSURL *fileURL = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@",fPath]];
//                                 
//                                 self.controller.URL = fileURL;
//                                 [self.controller presentOptionsMenuFromRect:(CGRectZero) inView:self.view animated:YES];
                                 
                                 self.controller = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
                                 // Present the app picker display
                                 [self.controller presentOptionsMenuFromRect:(CGRectZero) inView:self.view animated:YES];
                                 
                                 //TTOpenInAppActivity
                             }];
                             [downloadTask resume];
                         }
                         @catch (NSException *exception) {
                             NSLog(@"%@", exception.description);
                         }
                         @finally{
                             [m_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
                         }
                     }
                 }
             }
             else
             {
                 [self queryFS:ticketId bFilesys:isFileSys];
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

- (UIDocumentInteractionController *)controller {
    
    if (!_controller) {
        _controller = [[UIDocumentInteractionController alloc]init];
        _controller.delegate = self;
    }
    return _controller;
}

-(BOOL)getFS:(NSInteger)ticketId {
    __block BOOL bSuccess = FALSE;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    NSString* strURL = [NSString stringWithFormat:@"%@%d&ticketId=%ld", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_GET_FS, (long)ticketId];
    NSString* encodeURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", encodeURL);
    
    [manager GET:encodeURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         @try
         {
             NSArray *results = (NSArray*)responseObject;
             fsList = [NSMutableArray arrayWithCapacity	:results.count];
             NSLog(@"fsList count: %ld", (long)fsList.count);
             for(NSDictionary* f in results)
             {
                 File *aFile = [[File alloc] init];
                 aFile.name = [f objectForKey:KEY_FS_NAME];
                 aFile.type = [[f objectForKey:KEY_FS_TYPE] intValue];
                 aFile.path = [f objectForKey:KEY_FS_PATH];
                 [fsList addObject:aFile];
                 NSLog(@"Add object to fsList: %@", aFile.name);
                 
                 [self.tableView reloadData];
                 NSLog(@"reload data");
                 
             }
         }
         @catch (NSException *exception) {
             bSuccess = FALSE;
             NSLog(@"%@", [exception description]);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         bSuccess = FALSE;
         NSLog(@"Error: %@", error);
         NSLog(@"%@", operation.responseString);
     }];
    
    return bSuccess;
}

//- (void)reloadFiles
//{
//    NSFileManager * fileManager = [NSFileManager defaultManager];
//    NSArray * fileArray = [fileManager contentsOfDirectoryAtPath:path error:nil];
//    for(NSString *file in fileArray)
//    {
//        if ([file characterAtIndex:0] == (unichar)'.') // Skip invisibles, like .DS_Store
//            continue;
//        
//        BOOL isDir = NO;
//        if([fileManager fileExistsAtPath:[path stringByAppendingPathComponent:file] isDirectory:&isDir])
//        {
//            File *aFile;
//            if(isDir)
//            {
//                aFile = [[File alloc] init];
//                aFile.name = file;
//                aFile.isDirectory = isDir;
//                [fsList addObject:aFile];
//            }
//            else
//            {
//                NSAssert(visibleExtensions,@"Please set visibleExtensions before setPath.");
//                NSString *extension = [[file pathExtension] lowercaseString];
//                if ([visibleExtensions containsObject:extension])
//                {
//                    aFile = [[File alloc] init];
//                    aFile.name = file;
//                    aFile.isDirectory = isDir;
//                    [fsList addObject:aFile];
//                }
//            } 
//        }
//    }
//}

- (void) viewWillDisappear:(BOOL) animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    m_progressAlert = [[UIAlertView alloc] initWithTitle:@"Loading..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = CGPointMake(m_progressAlert.bounds.size.width / 2, m_progressAlert.bounds.size.height / 2 + 10);
    [indicator startAnimating];
    [m_progressAlert addSubview:indicator];
}

-(void)showProgress{
    [m_progressAlert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //NSLog(@"fsList: %ld", [fsList count]);
    return [fsList count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showProgress];
    int ticketId = arc4random_uniform(9999999);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    File *aFile = [fsList objectAtIndex:indexPath.row];
    if(aFile.type == 2)
    {
        @try {
            NSString* strURL = [NSString stringWithFormat:@"%@%d&DeviceId=%@&cmd=%d&params=%d|%@", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_SEND_CMD, self.device.deviceId, SRV_CLINET_CMD_REQ_FILE, ticketId, aFile.path];
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
                         [self queryFS:ticketId bFilesys:FALSE];
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
                     [m_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"Error: %@", error);
                 NSLog(@"%@", operation.responseString);
             }];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        }
    }
    else
    {
        @try {
            NSString* strURL = [NSString stringWithFormat:@"%@%d&DeviceId=%@&cmd=%d&params=%d|%@", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_SEND_CMD, self.device.deviceId, SRV_CLINET_CMD_ENUMERATE_PATH, ticketId, aFile.path];
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
                         FSViewController *anotherViewController = [[FSViewController alloc] init];
                         anotherViewController.path = [path stringByAppendingPathComponent:aFile.name];
                         anotherViewController.device = self.device;
                         anotherViewController.ticketId = ticketId;
                         anotherViewController.viewTitle = aFile.name;
                         [self.navigationController pushViewController:anotherViewController animated:YES];
                     }
                     else
                     {
                         NSLog(@"failed");
                     }
                 }
                 @catch (NSException *exception) {
                     NSLog(@"%@", [exception description]);
                 }
                 @finally{
                     [m_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"Error: %@", error);
                 NSLog(@"%@", operation.responseString);
             }];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    static NSString *CellIdentifier = @"FSCell";
    FSCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[FSCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    File *aFile = [fsList objectAtIndex:[indexPath row]];
    cell.textLabel.text = aFile.name;
    if(aFile.type != 2)
        cell.imageView.image = [File folderImage];
    else
        cell.imageView.image = [File fileImage];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    
    NSLog(@"Starting to send this puppy to %@", application);
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    
    NSLog(@"We're done sending the document.");
}


@end

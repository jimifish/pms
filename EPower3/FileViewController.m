//
//  FileViewController.m
//  EPower3
//
//  Created by Jimmy Yu on 3/30/15.
//  Copyright (c) 2015 JIMMY. All rights reserved.
//

#import "FileViewController.h"
#import "TTOpenInAppActivity.h"
#import "AFNetworking.h"
#import "Helper.h"
#import "Private.h"
#import "Constants.h"

@interface FileViewController ()
@property (nonatomic, strong) UIPopoverController *activityPopoverController;
@end

@implementation FileViewController

@synthesize file;
@synthesize device;
@synthesize ticketId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)openIn:(id)sender {
    
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

             NSString* strExt = [self.file.path pathExtension];

                NSString* downloadFilePath = [NSString stringWithFormat:@"Documents/%@.%@", self.file.name, strExt];
                NSString *fPath=[NSHomeDirectory() stringByAppendingPathComponent:downloadFilePath];
                NSURL *fileURL = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", fPath]];
             NSFileManager *fileMgr = [NSFileManager defaultManager];
             [fileMgr moveItemAtURL:filePath toURL:fileURL error:nil];
             NSLog(@"%@", fileURL.path);
             TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc] initWithView:self.view andRect:(CGRectZero)];
             UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:@[openInAppActivity]];

             if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                 // Store reference to superview (UIActionSheet) to allow dismissal
                 openInAppActivity.superViewController = activityViewController;
                 // Show UIActivityViewController
                 [self presentViewController:activityViewController animated:YES completion:NULL];
             } else {
                 // Create pop up
                 self.activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
                 // Store reference to superview (UIPopoverController) to allow dismissal
                 openInAppActivity.superViewController = self.activityPopoverController;
                 // Show UIActivityViewController in popup
                 [self.activityPopoverController presentPopoverFromRect:(CGRectZero) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
             }
         }];
         [downloadTask resume];
     }
     @catch (NSException *exception) {
         NSLog(@"%@", exception.description);
     }
     @finally{
         //[m_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
     }
}
@end

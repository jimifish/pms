//
//  DeviceDetailsViewController.m
//  EPower3
//
//  Created by JIMMY on 2013/11/15.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import "DeviceImageViewController.h"
#import "Device.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import "Private.h"

@interface DeviceImageViewController ()

@end

@implementation DeviceImageViewController

//@synthesize tvInternalIP;
@synthesize imgDevice;
@synthesize svDevice;
@synthesize device;

-(BOOL)getScreenshot:(NSString *)tokenId {
    __block BOOL bSuccess = FALSE;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.securityPolicy.allowInvalidCertificates = YES;
    NSString* strURL = [NSString stringWithFormat:@"%@%d&TokenId=%@", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_GET_SCREENSHOT, tokenId];
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
            imgDevice.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:filePath]];
            bSuccess = TRUE;
        }];
        [downloadTask resume];
    }
    @catch (NSException *exception) {
        bSuccess = FALSE;
        NSLog(@"%@", exception.description);
    }
    
    return bSuccess;
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

- (IBAction)didBack:(id)sender {
    [self.delegate deviceImageViewControllerDidBack:self];
    //[self.navigationController popViewControllerAnimated:YES];
}

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
    
    self.svDevice.delegate = self;
    self.imgDevice.contentMode = UIViewContentModeScaleAspectFit;
    
    
    [self setTitle:device.computerName];
    
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
                     NSInteger nCount = 0;
                     while (!bSuccess && nCount < 5) {
                         bSuccess = [self queryScreenshot:strTokenId];
                         sleep(1);
                         nCount++;
                     }
                     
                     bSuccess = [self getScreenshot: strTokenId];
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

-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews objectAtIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

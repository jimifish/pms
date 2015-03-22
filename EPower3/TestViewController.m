//
//  TestViewController.m
//  EPower3
//
//  Created by JIMMY on 2013/11/6.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import "TestViewController.h"
#import "AFNetworking.h"
//#import "MBProgressHUD.h"
#import "Constants.h"
#import "Private.h"

@interface TestViewController ()

@end


@implementation TestViewController

@synthesize tbxEmail;
@synthesize tbxPasswd;

- (IBAction)onClickGetCategory:(id)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    [manager GET:ServerApiURL2 parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
//    {
//         NSString *returnCode = [responseObject objectForKey:@"returnCode"];
//         NSLog(@"returnCode: %@", returnCode);
//         
//         NSString *value = responseObject[@"CategoryList"];
//         NSLog(@"CategoryList: %@", value);
//         _textViewCategory.text = value;
//         
//         
//    }
//    failure:^(AFHTTPRequestOperation *operation, NSError *error)
//    {
//        NSLog(@"Error: %@", error);
//    }];

    [manager GET:PMS_WEBAPP_URI parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSString *value = responseObject[@"ComputerName"];
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"%@", operation.responseString);
    }];
                                                         
    
}

- (IBAction)didLogin:(id)sender {
    BOOL bSuccess = true;
    
    @try
    {
        if ([[self.tbxPasswd text] isEqualToString:PMS_PASSWD])
        {
            NSLog(@"Pass");
        }
        else
        {
            bSuccess = false;
            [self alertStatus:@"Invalid password" :@"Login failed" :0];
        }

    }
    @catch (NSException *exception) {
        bSuccess = false;
    }
    
    if(bSuccess)
    {
        [self performSegueWithIdentifier:@"login_success" sender:self];
    }
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}


- (IBAction)didSignup:(id)sender {
    NSString* strEmail = tbxEmail.text;
    strEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString* strDeviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_DEVICE_TOKEN];
    NSLog(@"%@", strDeviceToken);
    
    NSString* strReqURL = [NSString stringWithFormat:@"%@?requestId=1&regType=1&email=%@&passwd=123456&pushToken=%@",
                           SERVER_URL, strEmail, strDeviceToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:strReqURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSString *returnCode = [responseObject objectForKey:@"returnCode"];
         NSLog(@"returnCode: %@", returnCode);
         NSInteger nRetCode = [returnCode integerValue];
         if (nRetCode == 1) {
             NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
             [userDefault setObject:strEmail forKey:KEY_EMAIL];
             [userDefault synchronize];
         }
         
         NSLog(@"email: %@", [[NSUserDefaults standardUserDefaults] stringForKey:KEY_EMAIL]);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didCleanCache:(id)sender {
    @try {
        //NSString *extension = @"jpg";
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
        NSEnumerator *e = [contents objectEnumerator];
        NSString *filename;
        
        // clean all for now1
        while ((filename = [e nextObject])) {
//            if ([[filename pathExtension] isEqualToString:extension]) {
//                
//                [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
//            }
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
        
        NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
        for (NSString *file in tmpDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

//- (IBAction)didEditFieldDone:(id)sender {
//    //取消目前是第一回應者（鍵盤消失）
//    [sender resignFirstResponder];
//}
@end

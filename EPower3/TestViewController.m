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

- (IBAction)btnLoginClick:(id)sender {
    NSString* strEmail = _tbxEmail.text;
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

@end

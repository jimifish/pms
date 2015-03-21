//
//  AppDelegate.m
//  EPower3
//
//  Created by JIMMY on 13/10/17.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import "AppDelegate.h"
#import "Player.h"
#import "PlayersViewController.h"
#import "Constants.h"

@implementation AppDelegate
{
    NSMutableArray *players;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
//    players = [NSMutableArray arrayWithCapacity:20];
//    Player *player = [[Player alloc] init];
//    player.name = @"Jimmy Yu";
//    player.game = @"JimiFish";
//    player.rating = 5;
//    [players addObject:player];
//    player = [[Player alloc] init];
//    player.name = @"Amy Yu";
//    player.game = @"AmyFish";
//    player.rating = 5;
//    [players addObject:player];
//    
//    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
//    UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
//    PlayersViewController *playerViewControllers = [[navigationController viewControllers] objectAtIndex:0];
//    playerViewControllers.players = players;
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeSound];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* strEmail = [userDefaults stringForKey:KEY_EMAIL];
    NSLog(@"email: %@", strEmail);
    
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"receive deviceToken: %@", [deviceToken description]);
    NSString* tokenString = [deviceToken description];
    tokenString = [tokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:KEY_DEVICE_TOKEN];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Remote notification error:%@", [error localizedDescription]);
    NSString* tokenString = TMP_DEVICE_TOKEN;
    [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:KEY_DEVICE_TOKEN];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Received notification:%@", [userInfo description]);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

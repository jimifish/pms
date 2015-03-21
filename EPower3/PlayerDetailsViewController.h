//
//  PlayerDetailsViewController.h
//  EPower3
//
//  Created by JIMMY on 13/10/17.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerDetailsViewController;
@class Player;

@protocol PlayerDetailsViewControllerDelegate <NSObject>
-(void)playerDetailsViewControllerDidCancel: (PlayerDetailsViewController *)controller;
-(void)playerDetailsViewControllerDidSave:(PlayerDetailsViewController *)controller;
-(void)playerDetailsViewController:(PlayerDetailsViewController *)controller didAddPlayer:(Player *)player;
@end

@interface PlayerDetailsViewController : UITableViewController

@property (nonatomic, weak) id <PlayerDetailsViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

-(IBAction)cancel:(id)sender;
-(IBAction)done:(id)sender;

@end

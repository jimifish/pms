//
//  ImageListViewController.h
//  EPower3
//
//  Created by JIMMY on 2013/12/1.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Device;

@interface ImageListViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *tblImageList;

@property (nonatomic, strong) NSMutableArray* imageList;
@property (strong, nonatomic) Device* device;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

-(void) refresh;

@end

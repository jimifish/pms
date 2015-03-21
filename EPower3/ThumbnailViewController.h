//
//  ThumbnailViewController.h
//  EPower3
//
//  Created by JIMMY on 2013/12/4.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewController.h"

@class Device;

@interface ThumbnailViewController : UITableViewController<ImageViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblThumbnail;

//@property (nonatomic, strong) NSMutableArray* thumbList;
@property (nonatomic, strong) NSMutableDictionary* dictThumb;
@property (nonatomic, strong) NSMutableDictionary* thumbImg;
@property (strong, nonatomic) Device* device;
@property (strong, nonatomic) NSString* folderName;
@property (strong, nonatomic) UIAlertView* m_progressAlert;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

-(void) refresh;

@end

//
//  FSViewController.h
//  EPower3
//
//  Created by Jimmy Yu on 3/23/15.
//  Copyright (c) 2015 JIMMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewController.h"

@class FSViewController;
@class Device;

@interface FSViewController : UITableViewController<ImageViewControllerDelegate>
{
    NSString		*path;
    NSArray			*visibleExtensions;
    NSMutableArray	*fsList;
}

@property (nonatomic) NSInteger		ticketId;
@property (nonatomic,retain) NSString		*path;
@property (nonatomic,retain) NSArray		*visibleExtensions;
@property (nonatomic,retain) NSMutableArray	*fsList;
@property (nonatomic,retain) NSString		*viewTitle;

@property (strong, nonatomic) IBOutlet UITableView *tblFSList;
@property (strong, nonatomic) UIAlertView* m_progressAlert;

@property (strong, nonatomic) Device* device;

@end

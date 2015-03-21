//
//  ImageViewController.h
//  EPower3
//
//  Created by JIMMY on 2013/12/4.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ImageViewController;
@class ThumbnailViewController;
@class Device;

@protocol ImageViewControllerDelegate

//-(void)passValue:(Device*)device;
-(void)ImageViewControllerDidBack: (NSString*)fileName;

@end

@interface ImageViewController : UIViewController<UIScrollViewDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imgDevice;

@property (strong, nonatomic) IBOutlet UIScrollView *svDevice;

@property (strong, nonatomic) Device* device;
@property (strong, nonatomic) NSString* folderName;
@property (strong, nonatomic) NSURL* imgURL;
@property (strong, nonatomic) NSDate* imgDate;
//@property (strong, nonatomic) NSString* fileName;
@property (nonatomic, strong) NSMutableDictionary* dictThumb;

@property (nonatomic) NSInteger imgIndex;
@property (strong, nonatomic) IBOutlet UILabel *lblFileName;
@property (strong, nonatomic) UIAlertView* m_progressAlert;

@property (nonatomic, weak) id <ImageViewControllerDelegate> delegate;
@end

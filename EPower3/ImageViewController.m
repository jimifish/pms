//
//  ImageViewController.m
//  EPower3
//
//  Created by JIMMY on 2013/12/4.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import "ImageViewController.h"
#import "Device.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import "Private.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 5

@interface ImageViewController ()
@property (nonatomic, strong) UIDocumentInteractionController *controller;
@end

@implementation ImageViewController

@synthesize imgDevice;
@synthesize svDevice;
@synthesize device;
//@synthesize fileName;
@synthesize ticketId;
//@synthesize imgURL;
@synthesize imgDate;
@synthesize dictThumb;
@synthesize folderName;
@synthesize imgIndex;
@synthesize lblFileName;
@synthesize m_progressAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.imgIndex = -1;
    }
    return self;
}

- (void) viewWillDisappear:(BOOL) animated
{
    if(self.ticketId <= 0)
    {
        NSString *inStr = [NSString stringWithFormat:@"%ld", (long)imgIndex];
        NSString* fileName = [dictThumb objectForKey:inStr];
        [self.delegate ImageViewControllerDidBack:fileName];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.imgDevice.contentMode = UIViewContentModeScaleAspectFit;
    self.imgDevice.userInteractionEnabled = YES;
    
    svDevice.contentSize = CGSizeMake(imgDevice.frame.size.width, imgDevice.frame.size.height);
    svDevice.maximumZoomScale = 4.0;
    svDevice.minimumZoomScale = 1.0;
    svDevice.clipsToBounds = YES;
    self.svDevice.delegate = self;
    svDevice.scrollEnabled = FALSE;
    
    [lblFileName setFont:[UIFont fontWithName:@"TrebuchetMS" size:16]];
    
    [self setWantsFullScreenLayout:TRUE];
    
    m_progressAlert = [[UIAlertView alloc] initWithTitle:@"Loading file\nPlease wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = CGPointMake(m_progressAlert.bounds.size.width / 2, m_progressAlert.bounds.size.height / 2 + 10);
    [indicator startAnimating];
    [m_progressAlert addSubview:indicator];
    
    [imgDevice setTag: ZOOM_VIEW_TAG];
    
    [self setTitle:device.computerName];
    
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer* twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    
    UISwipeGestureRecognizer *upSwipe =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    upSwipe.direction= UISwipeGestureRecognizerDirectionUp;
    upSwipe.delaysTouchesBegan = TRUE;
    
    UISwipeGestureRecognizer *downSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    downSwipe.direction= UISwipeGestureRecognizerDirectionDown;
    downSwipe.delaysTouchesBegan = TRUE;

    UISwipeGestureRecognizer *rightSwipe =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    rightSwipe.direction= UISwipeGestureRecognizerDirectionRight;
    rightSwipe.delaysTouchesBegan = TRUE;
    
    UISwipeGestureRecognizer *leftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    leftSwipe.direction= UISwipeGestureRecognizerDirectionLeft;
    leftSwipe.delaysTouchesBegan = TRUE;

    [svDevice addGestureRecognizer:upSwipe];
    [svDevice addGestureRecognizer:downSwipe];
    [svDevice addGestureRecognizer:rightSwipe];
    [svDevice addGestureRecognizer:leftSwipe];
    [svDevice delaysContentTouches];

    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    [imgDevice addGestureRecognizer:doubleTap];
    [imgDevice addGestureRecognizer:twoFingerTap];
    
    NSString* strURL = @"";
    
    if(self.ticketId > 0)
    {
        strURL = [NSString stringWithFormat:@"%@%d&ticketId=%ld", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_GET_FILE, (long)self.ticketId];
        lblFileName.text = self.imgFileName;
    }
    else
    {
        NSString *inStr = [NSString stringWithFormat:@"%ld", (long)imgIndex];
        NSString* imageName = [dictThumb objectForKey:inStr];
        
        self.imgDate = [Helper GetPicDate:imageName];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        lblFileName.text = [dateFormatter stringFromDate:self.imgDate];
        
        strURL = [NSString stringWithFormat:@"%@%d&ComputerName=%@&FolderName=%@&FileName=%@", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_GET_DEVICE_PIC, self.device.computerName, folderName, imageName];
    }
    
    NSLog(@"%@", strURL);
    
    [self loadImage:strURL];
}

-(void)showProgress{
    [m_progressAlert show];
}

-(void)loadImage: (NSString*) strURL{
    
    [self showProgress];
    
//    self.imgDate = [Helper GetPicDate:imageName];
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"HH:mm:ss"];
//    lblFileName.text = [dateFormatter stringFromDate:self.imgDate];

//    float w = [[UIScreen mainScreen] bounds].size.width;
//    lblFileName.frame = CGRectMake(0, 10, w, 20);

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
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
            //imgDevice.image = [UIImage imageNamed:@"Desktop_144x80.png"];
            //self.imgURL = filePath;
            //[self fitImage];
        }];
        [downloadTask resume];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    @finally{
        [m_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(void) fitImage{
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    
    UIImage* image = imgDevice.image;
    float y = 0.0;
    
    if(image.size.width > image.size.height)
    {
        float h = width / image.size.width * image.size.height;
        y = height / 2 - h / 2;
        imgDevice.frame = CGRectMake(0, y, width, h);
    }
    else
    {
        float h = height;
        y = height / 2 - h / 2;
        imgDevice.frame = CGRectMake(0, y, height / image.size.height * image.size.width, h);
    }
}

-(void)handleDoubleTap:(UIGestureRecognizer*)gestureRecognizer{
    // double tap zomms in
    float currentScale = [svDevice zoomScale];
    float newScale = (currentScale == 1.0) ? currentScale * ZOOM_STEP : currentScale / ZOOM_STEP;
    
    CGRect zoomRect = [self zoomRectForScale: newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];

    NSLog(@"%f", [svDevice zoomScale]);
    [svDevice zoomToRect:zoomRect animated:YES];
    [svDevice resignFirstResponder];
}

-(void)handleTwoFingerTap:(UIGestureRecognizer*)gestureRecognizer{
    // two-finger tap zomms out
    float newScale = [svDevice zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale: newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];

    NSLog(@"%f", [svDevice zoomScale]);

    [svDevice zoomToRect:zoomRect animated:YES];
}

-(void)handleSwipe:(UISwipeGestureRecognizer *)recognizer  //Here you can also make some validations so to make sure the gesture is finished
{
    NSLog(@"%s", __FUNCTION__);
    switch (recognizer.direction)
    {
        case (UISwipeGestureRecognizerDirectionRight):
        case (UISwipeGestureRecognizerDirectionUp):
            //[self performSelector:@selector(previousPage:)];
            //[self previousPage];
            imgIndex += 1;

            break;
        case (UISwipeGestureRecognizerDirectionLeft):
        case (UISwipeGestureRecognizerDirectionDown):
            //[self performSelector:@selector(nextPage:)];
            //[self nextPage];
            imgIndex -= 1;
            
            break;
        default:
            break;
    }
    
    if(imgIndex > dictThumb.count || imgIndex < 1)
        return;
    
    NSString *inStr = [NSString stringWithFormat:@"%ld", (long)imgIndex];
    NSString* imageName = [dictThumb objectForKey:inStr];
    
    NSString* strURL = [NSString stringWithFormat:@"%@%d&ComputerName=%@&FolderName=%@&FileName=%@", PMS_WEBAPP_REQ_URI, SRV_CLINET_REQ_GET_DEVICE_PIC, self.device.computerName, folderName, imageName];
    
    [self loadImage:strURL];
    
}

-(CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    
    zoomRect.size.height = [svDevice frame].size.height / scale;
    zoomRect.size.width = [svDevice frame].size.width / scale;
    
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.zoomScale!=1.0) {
        // Zooming, enable scrolling
        scrollView.scrollEnabled = TRUE;
    } else {
        // Not zoomed, disable scrolling so gestures get used instead
        scrollView.scrollEnabled = FALSE;
    }
}

-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //return [scrollView.subviews objectAtIndex:0];
    return [svDevice viewWithTag:ZOOM_VIEW_TAG];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIDocumentInteractionController *)controller {
    
    if (!_controller) {
        _controller = [[UIDocumentInteractionController alloc]init];
        _controller.delegate = self;
    }
    return _controller;
}

- (IBAction)didAction:(id)sender {
    @try {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString* imgPath = [NSString stringWithFormat:@"Documents/%@.jpg", [dateFormatter stringFromDate:self.imgDate]];

        NSString *jpgPath=[NSHomeDirectory() stringByAppendingPathComponent:imgPath];
        
        [UIImageJPEGRepresentation(self.imgDevice.image, 1.0) writeToFile:jpgPath atomically:YES];
        NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@",jpgPath]];
        
        self.controller.URL = igImageHookFile;
        [self.controller presentOptionsMenuFromRect:(CGRectZero) inView:self.view animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
}

#pragma mark - Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    
    NSLog(@"Starting to send this puppy to %@", application);
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    
    NSLog(@"We're done sending the document.");
}
@end

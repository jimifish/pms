//
//  TestViewController.h
//  EPower3
//
//  Created by JIMMY on 2013/11/6.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextView *textViewCategory;
@property (strong, nonatomic) IBOutlet UITextField *tbxEmail;
@property (strong, nonatomic) IBOutlet UITextField *tbxPasswd;
//- (IBAction)didEditFieldDone:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;

@end

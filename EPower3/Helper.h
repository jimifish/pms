//
//  Helper.h
//  EPower3
//
//  Created by JIMMY on 2013/12/10.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject

+ (NSString*)GetPicDateStr: (NSString*)picName;
+ (NSDate*)GetPicDate: (NSString*)picName;
+ (NSString*)EncodeURI: (NSString*)strURL;

@end

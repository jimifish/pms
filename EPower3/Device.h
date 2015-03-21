//
//  Device.h
//  EPower3
//
//  Created by JIMMY on 2013/11/13.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *computerName;
@property (nonatomic, copy) NSString *loginName;
@property (nonatomic, copy) NSString *externalIP;
@property (nonatomic, copy) NSString* internalIPList;
@property (nonatomic, copy) NSDate* dateUpdated;
@property (nonatomic, copy) NSString* uiVersion;
@property (nonatomic, copy) NSString* agentVersion;
@property (nonatomic, copy) NSDate* dateScreenshot;
@end

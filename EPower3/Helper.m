//
//  Helper.m
//  EPower3
//
//  Created by JIMMY on 2013/12/10.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (NSString*)GetPicDateStr: (NSString*)picName{
    __block NSString* str = @"";
    
    @try {
        NSError* error = NULL;
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{4})-(\\d{2})-(\\d{2})-(\\d{2})-(\\d{2})-(\\d{2}).jpg" options:NSRegularExpressionCaseInsensitive error:&error];
        
        [regex enumerateMatchesInString:picName options:0 range:NSMakeRange(0, [picName length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSString* strYear = [picName substringWithRange:[result rangeAtIndex:1]];
            NSString* strMonth = [picName substringWithRange:[result rangeAtIndex:2]];
            NSString* strDay = [picName substringWithRange:[result rangeAtIndex:3]];
            NSString* strHour = [picName substringWithRange:[result rangeAtIndex:4]];
            NSString* strMinute = [picName substringWithRange:[result rangeAtIndex:5]];
            NSString* strSecond = [picName substringWithRange:[result rangeAtIndex:6]];
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString* strDate = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", strYear, strMonth, strDay, strHour, strMinute, strSecond];
            NSDate* picDate = [dateFormatter dateFromString:strDate];
            
            str = [dateFormatter stringFromDate:picDate];
        }];
    }
    @catch (NSException *exception) {
        str = @"";
    }
    
    return  str;
}

+ (NSDate*)GetPicDate: (NSString*)picName{
    __block NSDate* picDate = [NSDate date];
    
    @try {
        NSError* error = NULL;
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{4})-(\\d{2})-(\\d{2})-(\\d{2})-(\\d{2})-(\\d{2}).jpg" options:NSRegularExpressionCaseInsensitive error:&error];
        
        [regex enumerateMatchesInString:picName options:0 range:NSMakeRange(0, [picName length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSString* strYear = [picName substringWithRange:[result rangeAtIndex:1]];
            NSString* strMonth = [picName substringWithRange:[result rangeAtIndex:2]];
            NSString* strDay = [picName substringWithRange:[result rangeAtIndex:3]];
            NSString* strHour = [picName substringWithRange:[result rangeAtIndex:4]];
            NSString* strMinute = [picName substringWithRange:[result rangeAtIndex:5]];
            NSString* strSecond = [picName substringWithRange:[result rangeAtIndex:6]];
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString* strDate = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", strYear, strMonth, strDay, strHour, strMinute, strSecond];
            picDate = [dateFormatter dateFromString:strDate];
        }];
    }
    @catch (NSException *exception) {
    }
    
    return picDate;
}

+(NSString*)EncodeURI:(NSString *)strURL{
    __block NSString* strURI = @"";
    
    @try {
        strURI = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    @catch (NSException *exception) {
    }
    
    return strURI;
}


@end

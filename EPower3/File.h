//
//  File.h
//

#import <Foundation/Foundation.h>


@interface File : NSObject 
{
	BOOL      isDirectory;
	NSString *name;
}

@property (assign)           BOOL       isDirectory;
@property (nonatomic,retain) NSString * name;

+ (UIImage*)folderImage;
+ (UIImage*)fileImage;

@end

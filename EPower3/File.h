//
//  File.h
//

#import <Foundation/Foundation.h>


@interface File : NSObject 
{
	BOOL      isDirectory;
	NSString *name;
}

//@property (assign)           BOOL       isDirectory;
@property (nonatomic,retain) NSString * name;
@property (nonatomic) NSInteger type;
@property (nonatomic,retain) NSString* path;

+ (UIImage*)folderImage;
+ (UIImage*)fileImage;

@end

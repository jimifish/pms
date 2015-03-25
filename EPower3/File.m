//
//  File.m
//

#import "File.h"
#import "Constants.h"

@implementation File

@synthesize name, type;

static UIImage * s_folderImage = nil;
static UIImage * s_fileImage   = nil;

+ (UIImage*)folderImage
{
	if(!s_folderImage)
		s_folderImage = [UIImage imageNamed:IMG_COLLECTION_SMALL];
	return s_folderImage;
}

+ (UIImage*)fileImage
{
	if(!s_fileImage)
		s_fileImage = [UIImage imageNamed:IMG_GENERIC_SMALL];
	return s_fileImage;
}

@end

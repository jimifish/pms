//
//  FSViewController.m
//  EPower3
//
//  Created by Jimmy Yu on 3/23/15.
//  Copyright (c) 2015 JIMMY. All rights reserved.
//

#import "FSViewController.h"
#import "Device.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "Helper.h"
#import "Private.h"
#import "File.h"
#import "FSCell.h"


@interface FSViewController ()

@end

@implementation FSViewController

@synthesize path,visibleExtensions,fsList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"File Browser";
        visibleExtensions = [NSArray arrayWithObjects:@"txt", @"htm", @"html", @"pdb", @"pdf", @"jpg", @"png", @"gif", nil];
        fsList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)init
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        self.title = @"File Browser";
        visibleExtensions = [NSArray arrayWithObjects:@"txt", @"htm", @"html", @"pdb", @"pdf", @"jpg", @"png", @"gif", nil];
        fsList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setPath:(NSString*)newPath
{
    path = newPath;
    self.title = [path lastPathComponent];
    [self reloadFiles];
}

- (void)reloadFiles
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * fileArray = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(NSString *file in fileArray)
    {
        if ([file characterAtIndex:0] == (unichar)'.') // Skip invisibles, like .DS_Store
            continue;
        
        BOOL isDir = NO;
        if([fileManager fileExistsAtPath:[path stringByAppendingPathComponent:file] isDirectory:&isDir])
        {
            File *aFile;
            if(isDir)
            {
                aFile = [[File alloc] init];
                aFile.name = file;
                aFile.isDirectory = isDir;
                [fsList addObject:aFile];
            }
            else
            {
                NSAssert(visibleExtensions,@"Please set visibleExtensions before setPath.");
                NSString *extension = [[file pathExtension] lowercaseString];
                if ([visibleExtensions containsObject:extension])
                {
                    aFile = [[File alloc] init];
                    aFile.name = file;
                    aFile.isDirectory = isDir;
                    [fsList addObject:aFile];
                }
            } 
        }
    }
}

- (void) viewWillDisappear:(BOOL) animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.title = @"File Browser";
//    visibleExtensions = [NSArray arrayWithObjects:@"txt", @"htm", @"html", @"pdb", @"pdf", @"jpg", @"png", @"gif", nil];
//    fsList = [[NSMutableArray alloc] init];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [fsList count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    File *aFile = [fsList objectAtIndex:indexPath.row];
    if(aFile.isDirectory)
    {
        FSViewController *anotherViewController = [[FSViewController alloc] init];
        anotherViewController.path = [path stringByAppendingPathComponent:aFile.name];
        [self.navigationController pushViewController:anotherViewController animated:YES];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    static NSString *CellIdentifier = @"FSCell";
    FSCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[FSCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    File *aFile = [fsList objectAtIndex:[indexPath row]];
    cell.textLabel.text = aFile.name;
    if([aFile isDirectory])
        cell.imageView.image = [File folderImage];
    else
        cell.imageView.image = [File fileImage];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

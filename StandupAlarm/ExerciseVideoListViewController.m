//
//  ExerciseVideoListViewController.m
//  StandupAlarm
//
//  Created by Apple Fan on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExerciseVideoListViewController.h"
#import "ExerciseVideoViewController.h"
#import "CountingEngine.h"
#import "Config.h"
#import "SimpleTableCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ExerciseVideoListViewController ()

@end

@implementation ExerciseVideoListViewController

@synthesize actionListTableView;

- (void)popViewController:(UIButton*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
    [iPhoneImage(@"commonbg.png") drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(popViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:self.navigationItem.title];
    titleLabel.layer.transform = CATransform3DMakeScale(0.6, 0.6, 1.0);
    [self.view addSubview:titleLabel];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [backButton setFrame:CGRectMake(20, 18, 119, 72)];
        [titleLabel setFrame:CGRectMake(0, 0, 768, 107)];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:72]];
    } else {
        [backButton setFrame:CGRectMake(5, 12, 26, 20)];
        [titleLabel setFrame:CGRectMake(0, 0, 320, 45)];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:30]];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [actionListTableView.layer setBorderWidth:1.0];
    [actionListTableView.layer setBorderColor:[UIColor colorWithRed:200.0 / 255 green:200.0 / 255 blue:200.0 / 255 alpha:1].CGColor];

#if USE_ADMOB
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    CGSize adSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adSize = GAD_SIZE_728x90;
    } else {
        adSize = GAD_SIZE_320x50;
    }
    
    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - adSize.width) / 2, self.view.frame.size.height - adSize.height,adSize.width,adSize.height)];
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"a14ff3a14d8de5d";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
#endif
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

// Return the number of sections.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[CountingEngine getInstance] numberOfActionGroups];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#if USE_ACTIONLIST_GROUP
// Return the title of section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[CountingEngine getInstance] titleOfActionGroup:section];
}
#endif

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[CountingEngine getInstance] numberOfActionsForGroup:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    static NSString *CellIdentifier = @"ActionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *action = [[CountingEngine getInstance] actionAtIndex:indexPath.row group:indexPath.section];
    cell.textLabel.text = [action objectForKey:@"actionTitle"];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 36.0 : 20.0];
    cell.textLabel.textColor = [UIColor colorWithRed:76.0 / 255 green:113.0 / 255 blue:148.0 / 255 alpha:1];
    
    UIImageView* videoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video.png"]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [videoIcon setFrame:CGRectMake(0, 0, 60, 62)];
    } else {
        [videoIcon setFrame:CGRectMake(0, 0, 25, 26)];
    }
    
    cell.accessoryView = videoIcon;
    
    return cell;
     */
    static NSString *simpleTableIdentifier = @"SimpleTableCell";    
    SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSDictionary *action = [[CountingEngine getInstance] actionAtIndex:indexPath.row group:indexPath.section];
    cell.nameLabel.text = [action objectForKey:@"actionTitle"];
    cell.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 36.0 : 20.0];
    cell.nameLabel.textColor = [UIColor colorWithRed:58.0 / 255 green:134.0 / 255 blue:255.0 / 255 alpha:1];
    cell.thumbnailImageView.image = [UIImage imageNamed:@"video.png"];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

#ifdef FREEVERSION
    NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_Free_iPad" : @"MainStoryboard_Free_iPhone";
#else
    NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_iPad" : @"MainStoryboard_iPhone";
#endif
    if (isPhone568)
        storyboardName = [storyboardName stringByAppendingString:@"_568h"];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    ExerciseVideoViewController* exerciseVideoViewController = (ExerciseVideoViewController*)[storyboard instantiateViewControllerWithIdentifier:@"exerciseVideoViewController"];
    
    [exerciseVideoViewController setActionByIndex:indexPath.row group:indexPath.section];
    
    [self.navigationController pushViewController:exerciseVideoViewController animated:YES];
}

@end

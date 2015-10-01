//
//  AlarmDetailExerciseViewController.m
//  StandupAlarm
//
//  Created by Albert Li on 4/29/13.
//
//

#import "AlarmDetailExerciseViewController.h"
#import "CountingEngine.h"
#import "Config.h"
#import <QuartzCore/QuartzCore.h>

@interface AlarmDetailExerciseViewController ()

@end

@implementation AlarmDetailExerciseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)popViewController:(UIButton*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    [self.alarmExerciseTableView.layer setBorderWidth:1.0];
    [self.alarmExerciseTableView.layer setBorderColor:[UIColor colorWithRed:200.0 / 255 green:200.0 / 255 blue:200.0 / 255 alpha:1].CGColor];
    
#if USE_ADMOB
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    CGSize adSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adSize = GAD_SIZE_728x90;
    } else {
        adSize = GAD_SIZE_320x50;
    }
    
    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - adSize.width) / 2,
                                                                  self.view.frame.size.height - adSize.height,
                                                                  adSize.width,
                                                                  adSize.height)];
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"a14ff3a14d8de5d";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
#endif
    
    int section = [self.alarmDetailViewController alarmExercise] / 1000;
    int row = [self.alarmDetailViewController alarmExercise] % 1000;
    currentExercise = [NSIndexPath indexPathForRow:row inSection:section];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAlarmExerciseTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[CountingEngine getInstance] numberOfActionGroups] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;    
    return [[CountingEngine getInstance] numberOfActionsForGroup:section - 1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 50.0 : 18.0];
    //cell.textLabel.textColor = [UIColor colorWithRed:76.0 / 255 green:113.0 / 255 blue:148.0 / 255 alpha:1];
    cell.textLabel.textColor = [UIColor darkGrayColor];

    if (indexPath.section == 0) {
        cell.textLabel.text = @"Randomly";
    } else {
        NSDictionary *action = [[CountingEngine getInstance] actionAtIndex:indexPath.row group:indexPath.section - 1];
        cell.textLabel.text = [action objectForKey:@"actionTitle"];
    }
    
    if (currentExercise.section == indexPath.section && currentExercise.row == indexPath.row)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell;
    for (NSInteger j = 0; j < [tableView numberOfSections]; j++) {
        for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; i++) {
            cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            cell.textLabel.textColor = [UIColor darkGrayColor];
        }
    }
    
    if (currentExercise.section != indexPath.section || currentExercise.row != indexPath.row) {
        cell = [tableView cellForRowAtIndexPath:currentExercise];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor = [UIColor colorWithRed:33.0 / 255 green:99.0 / 255 blue:198.0 / 255 alpha:1];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        currentExercise = indexPath;
        [self.alarmDetailViewController setAlarmExercise:(currentExercise.section * 1000 + currentExercise.row)];
    }
}

@end

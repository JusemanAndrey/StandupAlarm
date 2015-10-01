//
//  AlarmViewController.m
//  StandupAlarm
//
//  Created by Albert Li on 4/28/13.
//
//

#import "AlarmViewController.h"
#import "Config.h"
#import "CountingEngine.h"
#import "AlarmCell.h"
#import "AlarmDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AlarmViewController ()
{
    NSMutableArray* alarmList;
}

@end

@implementation AlarmViewController

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
//    if ([globalNotif10 count] > 0) {
//        [globalNotif10 removeAllObjects];
//    }
//    UIApplication *app = [UIApplication sharedApplication];
//    NSArray *oldNotifications = [app scheduledLocalNotifications];
//    for ( UILocalNotification *notification in oldNotifications) {
//        int notificationType = [[notification.userInfo objectForKey:kNotificationTypeKey] intValue];
//        if (notificationType == 10) {
//            [globalNotif10 addObject:notification];
//        }
//    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
    [iPhoneImage(@"myalarmbg.png") drawInRect:self.view.bounds];
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
    
#if USE_ADMOB
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    CGSize adSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adSize = GAD_SIZE_728x90;
    } else {
        adSize = GAD_SIZE_320x50;
    }
    
    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - adSize.width) / 2,self.view.frame.size.height - adSize.height,adSize.width,adSize.height)];
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

- (void)viewWillAppear:(BOOL)animated
{
    [self loadAlarmList];
    [self.alarmTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [self loadAlarmList];
    [self.alarmTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadAlarmList
{
    NSMutableArray* alarmKeyList = [[NSMutableArray alloc] initWithCapacity:0];
    alarmList = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIApplication* app = [UIApplication sharedApplication];
    NSArray* oldNotifications = [app scheduledLocalNotifications];
    
    for (UILocalNotification* notification in oldNotifications) {
        int notificationType = [[notification.userInfo objectForKey:kNotificationTypeKey] intValue];
        if (notificationType == 10) {
            NSString* guid = [notification.userInfo objectForKey:kNotificationGuidKey];
            if (![alarmKeyList containsObject:guid]) {
                [alarmKeyList addObject:guid];
                [alarmList addObject:notification];
            }
        }
    }

    [alarmList sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first     = [[a userInfo] objectForKey:kNotificationGuidKey];
        NSString *second    = [[b userInfo] objectForKey:kNotificationGuidKey];
        return [first compare:second];
    }];
}

- (void)viewDidUnload {
    [self setAlarmTableView:nil];
    [super viewDidUnload];
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [alarmList count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ALARM_CELL = @"AlarmCell";
    
    AlarmCell *cell = (AlarmCell*)[tableView dequeueReusableCellWithIdentifier:ALARM_CELL];
    if (cell == nil) {
        cell = [[AlarmCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ALARM_CELL];
    }
    
    UILocalNotification* notification = [alarmList objectAtIndex:indexPath.row];
    [cell setAlarmTime:notification.fireDate];
    [cell setAlarmRepeat:[[notification.userInfo objectForKey:kNotificationWeekdaysKey] intValue]];
    [cell setAlarmExercise:[[notification.userInfo objectForKey:kNotificationExerciseKey] intValue]];
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
#ifdef FREEVERSION
    NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_Free_iPad" : @"MainStoryboard_Free_iPhone";
#else
    NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_iPad" : @"MainStoryboard_iPhone";
#endif
    if (isPhone568)
        storyboardName = [storyboardName stringByAppendingString:@"_568h"];

    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    AlarmDetailViewController* alarmDetailViewController = (AlarmDetailViewController*)[storyboard instantiateViewControllerWithIdentifier:@"alarmDetailViewController"];
    
    UILocalNotification* alarm = [alarmList objectAtIndex:indexPath.row];
    [alarmDetailViewController setAlarmGuid:[alarm.userInfo objectForKey:kNotificationGuidKey]];
    [alarmDetailViewController setAlarmTime:alarm.fireDate];
    [alarmDetailViewController setAlarmRepeat:[[alarm.userInfo objectForKey:kNotificationWeekdaysKey] intValue]];
    [alarmDetailViewController setAlarmExercise:[[alarm.userInfo objectForKey:kNotificationExerciseKey] intValue]];
 
    [self.navigationController pushViewController:alarmDetailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setEditing:YES animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIApplication* app = [UIApplication sharedApplication];
        UILocalNotification* alarm = [alarmList objectAtIndex:indexPath.row];
        NSString* alarmGuid = [alarm.userInfo objectForKey:kNotificationGuidKey];

        NSArray* oldNotifications = [app scheduledLocalNotifications];
        
        for (UILocalNotification* notification in oldNotifications) {
            int notificationType = [[notification.userInfo objectForKey:kNotificationTypeKey] intValue];
            if (notificationType == 10) {
                NSString* guid = [notification.userInfo objectForKey:kNotificationGuidKey];
                if ([alarmGuid isEqualToString:guid]) {
                    [app cancelLocalNotification:notification];
                }
            }
        }
        [alarmList removeObjectAtIndex:indexPath.row];
      
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
}


- (IBAction)showAlarmDetain:(id)sender {
    [self performSegueWithIdentifier:@"showAlarmDetail" sender:self];
}
@end

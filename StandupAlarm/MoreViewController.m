//
//  MoreViewController.m
//  StandupAlarm
//
//  Created by Albert Li on 10/11/12.
//
//

#import "MoreViewController.h"
#import "GADBannerView.h"
#import "Config.h"
#import "CountingEngine.h"
#import <QuartzCore/QuartzCore.h>

@interface MoreViewController ()
{
    GADBannerView *bannerView_;
    NSArray* itemsList;
}

@end

@implementation MoreViewController

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
    [titleLabel setTextColor:[UIColor whiteColor]];
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
    
    itemsList = @[@[@"Exercise List", @"showExerciseVideoList"], @[@"Progress Chart", @"showProgress"]];
    
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

#pragma mark - Table view data source

// Return the number of sections.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [itemsList count];
}

// Return the title of section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [[itemsList objectAtIndex:indexPath.section] objectAtIndex:0];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* segue = [[itemsList objectAtIndex:indexPath.section] objectAtIndex:1];
    if ([segue isEqualToString:@"showProgress"]) {
        CountingEngine *engine = [CountingEngine getInstance];
        if ([engine userWeight] == 0) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please input  your weight (lbs)!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeDecimalPad;
            [alert show];
            return;
        }
    }
    
    [self performSegueWithIdentifier:segue sender:self];
}

#pragma mark - alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // click OK
    if (buttonIndex == 1) {
        // get inputed weight
        NSString* weightText = [[alertView textFieldAtIndex:0] text];
        if (weightText && [weightText floatValue] > 0) {
            
            CountingEngine *engine = [CountingEngine getInstance];
            
            // set user weight
            [engine setUserWeight:[weightText floatValue]];
            [engine applyWeight];
            [engine saveCaloriesData];
            
            // show progress chart
            [self performSegueWithIdentifier:@"showProgress" sender:self];
        } else {
            // retry input
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please input  your weight (lbs)!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeDecimalPad;
            [alert show];
            return;
        }
    }
}

@end

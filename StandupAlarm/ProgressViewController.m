//
//  ProgressViewController.m
//  StandupAlarm
//
//  Created by Albert Li on 10/18/12.
//
//

#import "ProgressViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Config.h"
#import "CountingEngine.h"
#import "AppDelegate.h"

extern BOOL bTracker;

@interface ProgressViewController ()

@end

@implementation ProgressViewController

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
    NSUserDefaults *saves = [NSUserDefaults standardUserDefaults];
    [saves setBool:_caloAndBreakSwitch.on forKey:@"bTracker"];
    [saves synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated{
    [_caloAndBreakSwitch setOn:bTracker];
    if( bTracker ){
        _caloriesLabel.textColor = [UIColor darkGrayColor];
        _breaksLabel.textColor = PCColorCustom;
        [_backImageView setImage:[UIImage imageNamed:@"progressbg1.png"]];
        [_caloAndBreakSwitch setThumbTintColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    }
    else{
        _caloriesLabel.textColor = PCColorCustom;
        _breaksLabel.textColor = [UIColor darkGrayColor];
        [_backImageView setImage:[UIImage imageNamed:@"progressbg.png"]];
        [_caloAndBreakSwitch setThumbTintColor:[UIColor colorWithRed:58.0/255.0 green:134.0/255.0 blue:1.0 alpha:1.0]];
    }
    if (_lineChartView) {
        [_lineChartView removeFromSuperview];
    }
    [self loadProgressChart];
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
    
#if USE_ADMOB
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    CGSize adSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adSize = GAD_SIZE_728x90;
    } else {
        adSize = GAD_SIZE_320x50;
    }
    
    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - adSize.width) / 2, self.view.frame.size.height - adSize.height, adSize.width, adSize.height)];
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"a14ff3a14d8de5d";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
#endif
    
    // load progress
    //[self loadProgressChart];
    
    // show user weight
    CountingEngine *engine = [CountingEngine getInstance];
    [_weightButton setTitle:[NSString stringWithFormat:@"%.1f lbs", [engine userWeight]] forState:UIControlStateNormal];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:) name:SCSessionStateChangedNotification object:nil];
}

- (void)viewDidUnload {
    [self setLineChartContainer:nil];
    //[self setLblUserWeight:nil];
    [super viewDidUnload];
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

- (void)loadProgressChart
{
    _lineChartView = [[PCLineChartView alloc] initWithFrame:_lineChartContainer.frame];
    [_lineChartView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:_lineChartView];
    
    CountingEngine *engine = [CountingEngine getInstance];
    
    NSMutableArray *caloriesStandApp = [NSMutableArray array];
    NSMutableArray *caloriesSittingDown = [NSMutableArray array];
    NSMutableArray *breakCounts = [NSMutableArray array];
    NSMutableArray *days = [NSMutableArray array];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"MM/dd"];
    [formatter setDateFormat:@"M/dd"];
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate* today = [NSDate date];
    float maxCalories = 0;
    int maxCounts = 0;
    for (int i = 4; i >= 0; i--) {
        NSDate* day = [today dateByAddingTimeInterval:-secondsPerDay * i];
        [days addObject:[formatter stringFromDate:day]];
        
        int calStandApp = [engine caloriesOfDate:day];
        int calSittingDown = [engine caloriesBySittingOfDate:day];
        int calCounts = [engine countsOfDate:day];
        
        if (calStandApp > maxCalories)
            maxCalories = calStandApp;
        if (calSittingDown > maxCalories)
            maxCalories = calSittingDown;
        if (calCounts > maxCounts) {
            maxCounts = calCounts;
        }
        
        [caloriesStandApp addObject:[NSNumber numberWithInt:calStandApp]];
        [caloriesSittingDown addObject:[NSNumber numberWithInt:calSittingDown]];
        [breakCounts addObject:[NSNumber numberWithInt:calCounts]];
    }
    
    PCLineChartViewComponent *componentStandApp = [[PCLineChartViewComponent alloc] init];
    [componentStandApp setTitle:nil];
    [componentStandApp setPoints:caloriesStandApp];
    [componentStandApp setShouldLabelValues:YES];
    [componentStandApp setLabelFormat:@"%.f"];
    [componentStandApp setColour:PCColorWhite];
    
    PCLineChartViewComponent *componentSittingDown = [[PCLineChartViewComponent alloc] init];
    [componentSittingDown setTitle:nil];
    [componentSittingDown setPoints:caloriesSittingDown];
    [componentSittingDown setShouldLabelValues:YES];
    [componentSittingDown setLabelFormat:@"%.f"];
    [componentSittingDown setColour:PCColorWhite];
    
    PCLineChartViewComponent *componentCounts = [[PCLineChartViewComponent alloc] init];
    [componentCounts setTitle:nil];
    [componentCounts setPoints:breakCounts];
    [componentCounts setShouldLabelValues:YES];
    [componentCounts setLabelFormat:@"%.f"];
    [componentCounts setColour:PCColorWhite];
    
    if (bTracker) {// break counts
        _lineChartView.minValue = 0;
        _lineChartView.maxValue = ceil(maxCounts / 5) * 5;
        if (_lineChartView.maxValue < 20)
            _lineChartView.maxValue = 20;
        [_lineChartView setXLabels:days];
        [_lineChartView setComponents:@[componentCounts]];
    }
    else{
        _lineChartView.minValue = 0;
        _lineChartView.maxValue = ceil(maxCalories / 48) * 48;
        if (_lineChartView.maxValue < 240)
            _lineChartView.maxValue = 240;
        [_lineChartView setXLabels:days];
        [_lineChartView setComponents:@[componentStandApp, componentSittingDown]];
    }
}

- (IBAction)shareOnFacebook:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

    if ([FBSession.activeSession isOpen]) {
        [self doShareOnFacebook];
    } else {
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
}

- (IBAction)editUserWeight:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please input  your weight (lbs)!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDecimalPad;
    alertTextField.text = [NSString stringWithFormat:@"%.1f", [[CountingEngine getInstance] userWeight]];
    [alert show];
}

- (IBAction)valueChangedOfSwitch:(id)sender {
    bTracker = _caloAndBreakSwitch.on;
    if (bTracker) {
        [_caloAndBreakSwitch setThumbTintColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    }
    else{
        [_caloAndBreakSwitch setThumbTintColor:[UIColor colorWithRed:58.0/255.0 green:134.0/255.0 blue:1.0 alpha:1.0]];
    }
    [self viewWillAppear:TRUE];
}

- (void)sessionStateChanged:(NSNotification*)notification {
    // A more complex app might check the state to see what the appropriate course of
    // action is, but our needs are simple, so just make sure our idea of the session is
    // up to date and repopulate the user's name and picture (which will fail if the session
    // has become invalid).
    [self doShareOnFacebook];
}

- (void)doShareOnFacebook {
    // get today burned calories
    NSString* message = nil;
    int calories = [[CountingEngine getInstance] caloriesOfDate:[NSDate date]];
    if (calories > 0)
        message = [NSString stringWithFormat:FACEBOOK_MESSAGE_BURNED, calories];
    else
        message = FACEBOOK_MESSAGE_NOBURNED;
    
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       FACEBOOK_URL,            @"link",
                                       FACEBOOK_PICTURE,        @"picture",
                                       FACEBOOK_NAME,           @"name",
                                       FACEBOOK_CAPTION,        @"caption",
                                       FACEBOOK_DESCRIPTION,    @"description",
                                       message,                 @"message",
                                       nil];
    
    [FBRequestConnection startWithGraphPath:@"me/feed"
                                 parameters:postParams
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              NSString *alertText;
                              if (error) {
                                  alertText = @"There was an error! Please try again.";
                              } else {
                                  alertText = @"Your progress has been posted successfully! Thank you!";
                              }
                              // Show the result in an alert
                              
                              [[[UIAlertView alloc] initWithTitle:@""
                                                          message:alertText
                                                         delegate:self
                                                cancelButtonTitle:@"OK!"
                                                otherButtonTitles:nil]
                               show];
                          }];
}

#pragma mark - alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // click OK
    if (buttonIndex == 1) {
        // get inputed weight
        NSString* weightText = [[alertView textFieldAtIndex:0] text];
        if (weightText && [weightText floatValue] > 0) {
            
            // set new user weight
            CountingEngine *engine = [CountingEngine getInstance];
            [engine setUserWeight:[weightText floatValue]];
            [_weightButton setTitle:[NSString stringWithFormat:@"%.1f lbs", [weightText floatValue]] forState:UIControlStateNormal];
            NSUserDefaults *saves = [NSUserDefaults standardUserDefaults];
            [saves setDouble:[weightText floatValue] forKey:@"userWeight"];
            [saves synchronize];
        } else {
            // retry input
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please input your weight (lbs)!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeDecimalPad;
            alertTextField.text = [NSString stringWithFormat:@"%.1f", [[CountingEngine getInstance] userWeight]];
            [alert show];
            return;
        }
    }
}

@end

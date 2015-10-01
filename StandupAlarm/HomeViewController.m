//
//  HomeViewController.m
//  StandupAlarm
//
//  Created by Albert Li on 4/28/13.
//
//

#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Config.h"
#import "CountingEngine.h"
#import "AppDelegate.h"
#import "ExerciseViewController.h"
#import "CountingViewController.h"

#define KProductIdentifier @"com.lyonel.standfreeapp.pid"

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize activeLabel;
UIAlertView * alertProgress, * alertPurchase;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activeLabel setHidden:YES];
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
    [iPhoneImage(@"homebg.png") drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    alertProgress = [[UIAlertView alloc] initWithTitle:nil message:@"Please input your weight (lbs)!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertProgress.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alertProgress textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDecimalPad;
    if (!checkEnableApp) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        skProduct = [[SKProduct alloc] init];
        [self fetchAvailableProducts];
        alertPurchase = [[UIAlertView alloc] initWithTitle:@"Confirm Your In - App Purchase" message:@"Thank you for using StandApp.To continue use, please purchase in the App Store for $0.99." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
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

    [self checkScheduledAlarm];
}

- (void)viewWillAppear:(BOOL)animated{
    if( isActive == YES ){
        [self.activeLabel setHidden:NO];
    }
    else{
        [self.activeLabel setHidden:YES];
    }
    [self.activeLabel setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated{
    if (!checkEnableApp) {
        if ( isTimeToCheck ) {
            [alertPurchase show];
        }
    }
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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)checkScheduledAlarm
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.localNotification) {
        int notificationType = [[appDelegate.localNotification.userInfo objectForKey:kNotificationTypeKey] intValue];
        
        if (notificationType == 10) {
            int alarmExercise = [[appDelegate.localNotification.userInfo objectForKey:kNotificationExerciseKey] intValue];
            if (alarmExercise == 0)
                [[CountingEngine getInstance] setCurrentActionRandomly];
            else
                [[CountingEngine getInstance] setCurrentActionAtIndex:alarmExercise % 1000 group:alarmExercise / 1000 - 1];
            
#ifdef FREEVERSION
            NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_Free_iPad" : @"MainStoryboard_Free_iPhone";
#else
            NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_iPad" : @"MainStoryboard_iPhone";
#endif
            if (isPhone568)
                storyboardName = [storyboardName stringByAppendingString:@"_568h"];
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
            
            ExerciseViewController* exerciseViewController = (ExerciseViewController*)[storyboard instantiateViewControllerWithIdentifier:@"exerciseViewController"];
            [exerciseViewController setScheduledExercise:YES];
            [self.navigationController pushViewController:exerciseViewController animated:YES];
        }
    }
}

- (IBAction)showProgress:(id)sender {
    CountingEngine *engine = [CountingEngine getInstance];
    if ([engine userWeight] == 0) {
        [alertProgress show];
        return;
    }

    [self performSegueWithIdentifier:@"showProgress" sender:self];
}

- (IBAction)intervalClicked:(id)sender {
    if (isActive) {
        //isActive = NO;
        if ([[CountingEngine getInstance] isReachedTarget]) {
            isActive = NO;
            [self performSegueWithIdentifier:@"home2selectInterval" sender:self];
        }
        else{
            [self performSegueWithIdentifier:@"home2NextBreak" sender:self];
        }
    }
    else{
        [self performSegueWithIdentifier:@"home2selectInterval" sender:self];
    }
}

#pragma mark - alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ( alertView == alertProgress) {
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
                NSUserDefaults *saves = [NSUserDefaults standardUserDefaults];
                [saves setDouble:[weightText floatValue] forKey:@"userWeight"];
                [saves synchronize];
                // show progress chart
                [self performSegueWithIdentifier:@"showProgress" sender:self];
            } else {
                // retry input
                [alertProgress show];
                return;
            }
        }
    }
    else if (alertView == alertPurchase){
        if (buttonIndex == 1) {//
            if (skProduct != nil) {
                [self purchaseMyProduct:skProduct];
            }
        }
        else{
            exit(0);
        }
    }
}

- (void) fetchAvailableProducts{
    NSSet *productIdentifiers = [NSSet setWithObject:KProductIdentifier];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (BOOL)canMakePurchases{
    return [SKPaymentQueue canMakePayments];
}

- (void)purchaseMyProduct:(SKProduct *)product{
    if([self canMakePurchases]){
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"About Purchase" message:@"Now it isn't available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark StoreKit Delegate

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = [response.products count];
    if( count > 0 ){
        validProducts = [[NSArray alloc] initWithArray:response.products];
        validProduct = [validProducts objectAtIndex:0];
        if ([validProduct.productIdentifier isEqualToString:KProductIdentifier]) {
            skProduct = validProduct;
        }
        else{
            skProduct = nil;
        }
    }
}

- (void)showPurchasing:(int)index{
    UIAlertView *alertView;
    if (index == 0) {
        alertView = [[UIAlertView alloc] initWithTitle:@"About Purchase" message:@"Now you are purchasing." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
    else if(index == 1){
        alertView = [[UIAlertView alloc] initWithTitle:@"About Purchase" message:@"You failed in purchasing. Retry it after" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
    else{
        alertView = [[UIAlertView alloc] initWithTitle:@"About Purchase" message:@"Thank you for purchasing." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
    [alertView show];
}

// called when the transaction status is updated
-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for (SKPaymentTransaction *transaction in transactions ){
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Please wait for purchasing.");
                checkEnableApp = FALSE;
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self showPurchasing:0];
                break;
            case SKPaymentTransactionStatePurchased:
                if ([transaction.payment.productIdentifier isEqualToString:KProductIdentifier]) {
                    NSLog(@"Purchased");
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    checkEnableApp = TRUE;
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"enableApp"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self showPurchasing:2];
                }
                break;
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                checkEnableApp = FALSE;
                [self showPurchasing:1];
                break;
            default:
                break;
        }
    }
}

@end

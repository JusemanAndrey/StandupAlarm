//
//  HomeViewController.h
//  StandupAlarm
//
//  Created by Albert Li on 4/28/13.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "GADBannerView.h"

@interface HomeViewController : UIViewController <UIAlertViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    GADBannerView *bannerView_;
    SKProduct *skProduct;
    SKProductsRequest *productsRequest;
    NSArray *validProducts;
}

@property (strong, nonatomic) IBOutlet UILabel *activeLabel;

- (IBAction)showProgress:(id)sender;
- (IBAction)intervalClicked:(id)sender;

@end

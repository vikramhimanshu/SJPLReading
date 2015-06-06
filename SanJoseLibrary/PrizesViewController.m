//
//  PrizesViewController.m
//  SanJoseLibrary
//
//  Created by Himanshu Vikram on 5/25/15.
//  Copyright (c) 2015 Himanshu Vikram. All rights reserved.
//

#import "PrizesViewController.h"
#import "ContainerViewController.h"

#import "ServiceRequest.h"
#import "PrizesFooterView.h"
#import "PrizeTypes.h"
#import "User.h"
#import "UserTypes.h"

@interface PrizesViewController ()

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) PrizeType *prizesForUser;

@property (strong, nonatomic) PrizeType *currentPrizes;

@property (weak, nonatomic) IBOutlet UILabel *readingLogLbl;
@property (weak, nonatomic) IBOutlet PrizesFooterView *prizeView;

@end

@implementation PrizesViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentUser = [(ContainerViewController *)self.parentViewController currentUser];
    self.readingLogLbl.text = [self userReadingHoursFormatedInHoursMinutes];
    
    ServiceRequest *sr = [ServiceRequest sharedRequest];
    [sr getUserTypesWithCompletionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error) {
        UserTypes *types = [[UserTypes alloc] userTypesWithProperties:(NSArray *)json];
        self.currentUser.userTypeName = [types nameForUserType:self.currentUser.userType];
        
        [sr getPrizeAndUserTypesWithCompletionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error) {
            PrizeTypes *prizes = [[PrizeTypes alloc] prizeTypesWithProperties:json[@"prizes"]];
            self.prizesForUser = [prizes prizesForUserType:self.currentUser.userType];
            
            if (response) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.prizeView setupViewWithPrizeType:self.prizesForUser
                                           user:self.currentUser];
                });
            }
        }];
    }];
}

- (NSString *)userReadingHoursFormatedInHoursMinutes
{
    NSString *returnValue = nil;
    
    NSInteger totalReadingMins = [self.currentUser.readingLog floatValue];
    NSInteger readingMins = totalReadingMins % 60;
    NSInteger readingHours = (totalReadingMins - readingMins)/60;
    
    if (readingHours > 0 && readingMins > 0)
    {
        returnValue = [NSString stringWithFormat:@"%ldhrs & %ldmins",(long)readingHours,(long)readingMins];
    }
    else if (readingMins <= 0)
    {
        returnValue = [NSString stringWithFormat:@"%ldhrs",(long)readingHours];
    }
    else if (readingHours <= 0)
    {
        returnValue = [NSString stringWithFormat:@"%ldmins",(long)readingMins];
    }
    
    return returnValue;
}

@end

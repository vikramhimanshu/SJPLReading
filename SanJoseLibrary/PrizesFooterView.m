//
//  PrizesFooterView.m
//  SanJoseLibrary
//
//  Created by Himanshu Tantia on 5/20/14.
//  Copyright (c) 2014 Himanshu Tantia. All rights reserved.
//

#import "PrizesFooterView.h"
#import "PrizeType.h"
#import "Prize.h"
#import "Utillities.h"
#import "User.h"

@interface PrizesFooterView ()

@property (weak, nonatomic) PrizeType *prizeType;

@property (weak, nonatomic) IBOutlet UIButton *prize1;
@property (weak, nonatomic) IBOutlet UIButton *prize2;
@property (weak, nonatomic) IBOutlet UIButton *prize3;
@property (weak, nonatomic) IBOutlet UILabel *prize1StateLbl;
@property (weak, nonatomic) IBOutlet UILabel *prize2StateLbl;
@property (weak, nonatomic) IBOutlet UILabel *prize3StateLbl;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end

@implementation PrizesFooterView

-(void)setupViewWithPrizeType:(PrizeType *)prizeType user:(User *)user
{
    self.prizeType = prizeType;
    self.title.text = @"Prizes";
    NSArray *userPrizes = user.prizes;
    Prize *p = [userPrizes objectAtIndex:0];
    NSString *imgName = [NSString stringWithFormat:@"%@_1_%d",user.userTypeName,p.state];
    self.prize1.tag = p.state;
    [self.prize1 setBackgroundImage:[UIImage imageNamed:imgName]
                           forState:UIControlStateNormal];
    if (p.state == 0) {
        self.prize1StateLbl.text = @"Click to play";
    } else if (p.state == 1) {
        self.prize1StateLbl.text = @"Ready to receive";
    } else if (p.state == 2) {
        self.prize1StateLbl.text = @"Collected!";
    }
    
    p = [userPrizes objectAtIndex:1];
    imgName = [NSString stringWithFormat:@"%@_2_%d",user.userTypeName,p.state];
    self.prize2.tag = p.state;
    [self.prize2 setBackgroundImage:[UIImage imageNamed:imgName]
                           forState:UIControlStateNormal];
    if (p.state == 0) {
        self.prize2StateLbl.text = @"Click to play";
    } else if (p.state == 1) {
        self.prize2StateLbl.text = @"Ready to receive";
    } else if (p.state == 2) {
        self.prize2StateLbl.text = @"Collected!";
    }

    p = [userPrizes objectAtIndex:2];
    imgName = [NSString stringWithFormat:@"%@_3_%d",user.userTypeName,p.state];
    self.prize3.tag = p.state;
    [self.prize3 setBackgroundImage:[UIImage imageNamed:imgName]
                           forState:UIControlStateNormal];
    if (p.state == 0) {
        self.prize3StateLbl.text = @"Click to play";
    } else if (p.state == 1) {
        self.prize3StateLbl.text = @"Ready to receive";
    } else if (p.state == 2) {
        self.prize3StateLbl.text = @"Collected!";
    }
}

- (IBAction)prizeButtonClicked:(UIButton *)sender
{
    NSString *commonMsg = nil;
    
    if (sender.tag==0) {
        commonMsg = [NSString stringWithFormat:@"Complete 4 squares in a row to win '##'."];
    } else if (sender.tag==1) {
        commonMsg = [NSString stringWithFormat:@"Congratulations! You have won '##'. Visit your local library to pick up the prize."];
    } else if (sender.tag==2) {
        commonMsg = [NSString stringWithFormat:@"Congratulations! You have collected '##'."];
    }
    
    if ([sender isEqual:self.prize1]) {
        commonMsg = [commonMsg stringByReplacingOccurrencesOfString:@"##"
                                                         withString:self.prizeType.prize1];
    } else if ([sender isEqual:self.prize2]) {
        commonMsg = [commonMsg stringByReplacingOccurrencesOfString:@"##"
                                                         withString:self.prizeType.prize2];
    } else if ([sender isEqual:self.prize3]) {
        commonMsg = [commonMsg stringByReplacingOccurrencesOfString:@"##"
                                                         withString:self.prizeType.prize3];
    }
    
    UIAlertView *alert = [Utillities alertViewWithTitle:@"Prize"
                                                message:commonMsg
                                               delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end

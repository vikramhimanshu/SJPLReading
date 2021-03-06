//
//  ReadingLogViewController.m
//  SanJoseLibrary
//
//  Created by Himanshu Tantia on 5/9/14.
//  Copyright (c) 2014 Himanshu Tantia. All rights reserved.
//

#import "ReadingLogViewController.h"
#import "ContainerViewController.h"
#import "User.h"
#import "ReadingLogCell.h"
#import "ServiceRequest.h"
#import "Utillities.h"

#import "PrizeType.h"
#import "PrizeTypes.h"
#import "Prize.h"


@interface ReadingLogViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *readingLogCollectionViewCells;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (weak, nonatomic) User *currentUser;
@property (weak, nonatomic) IBOutlet UICollectionView *readingLogCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *batteryFullImageView;

@property (nonatomic) BOOL shouldShowNextDesign;
@property (nonatomic) NSInteger currentReadingTracker;

@property (nonatomic) UINavigationItem* myNavigationItem;

@end

@implementation ReadingLogViewController

-(void)didReceiveMemoryWarning
{
    if (self.currentReadingTracker == MinReadingMinutes) {
        self.batteryFullImageView.hidden = NO;
        [self.readingLogCollectionViewCells removeAllObjects];
        self.readingLogCollectionViewCells = nil;
        [self.readingLogCollectionView removeFromSuperview];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentUser = [(ContainerViewController *)self.parentViewController currentUser];

    self.batteryFullImageView.hidden = YES;

    [self setupReadingLogCollectionView];
    [self setupReadingLogCollectionViewCells];
}

- (void)setupReadingLogCollectionView
{
    UIImage *background = [UIImage imageNamed:@"read_background"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:background];
    [backgroundView setFrame:self.readingLogCollectionView.frame];
    [backgroundView setContentMode:UIViewContentModeScaleToFill];
    [self.readingLogCollectionView registerClass:[UICollectionReusableView class]
                        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                               withReuseIdentifier:@"HeaderView"];
//    self.readingLogCollectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"read_background.png"]];
    self.readingLogCollectionView.backgroundView = backgroundView;
}

- (void)setupReadingLogCollectionViewCells
{
    if (self.readingLogCollectionViewCells) {
        [self.readingLogCollectionViewCells removeAllObjects];
        self.readingLogCollectionViewCells = nil;
    }
    self.readingLogCollectionViewCells = [[NSMutableArray alloc] initWithCapacity:30];
    NSInteger numberOfReadCells = self.currentReadingTracker/20;
    self.currentIndexPath = [NSIndexPath indexPathForItem:numberOfReadCells
                                                inSection:0];
    for (int i =0; i<[self.readingLogCollectionView numberOfItemsInSection:0]; i++)
    {
        @autoreleasepool {
            NSIndexPath *idxPath = [NSIndexPath indexPathForItem:i inSection:0];
            ReadingLogCell *cell = [self.readingLogCollectionView dequeueReusableCellWithReuseIdentifier:@"readingLogCell"
                                                                                        forIndexPath:idxPath];
            if (i < numberOfReadCells) {
                cell.imageView.image = [UIImage imageNamed:@"CHECKMARK"];
            }
            [self.readingLogCollectionViewCells addObject:cell];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createRightNavigationItem];
    [self.readingLogCollectionView reloadData];
    [self checkForReadingMileStones];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UINavigationItem *navItem = self.myNavigationItem;
    [navItem setRightBarButtonItem:nil animated:YES];
    [navItem setTitle:@""];
}

-(UINavigationItem *)myNavigationItem
{
    return self.parentViewController.parentViewController.navigationItem;
}

- (void)createRightNavigationItem
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 33)];
    
    UIButton *addMinsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [addMinsButton setTitle:@"+20m" forState:UIControlStateNormal];
    addMinsButton.frame = CGRectMake(0, 0, 50, 30);
    [addMinsButton addTarget:self
                      action:@selector(addReadingMinutes)
            forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *subMinsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    subMinsButton.frame = CGRectMake(55, 0, 45, 30);
    [subMinsButton setTitle:@"-20m" forState:UIControlStateNormal];
    [subMinsButton setTintColor:[UIColor redColor]];
    [subMinsButton addTarget:self
                      action:@selector(subtractReadingMinutes)
            forControlEvents:UIControlEventTouchUpInside];

    [view addSubview:addMinsButton];
    [view addSubview:subMinsButton];
    
    UIBarButtonItem *rightNavigationItemView = [[UIBarButtonItem alloc] initWithCustomView:view];
    UINavigationItem *navItem = self.myNavigationItem;
    [navItem setRightBarButtonItem:rightNavigationItemView animated:YES];
    [navItem setTitle:@"I read for"];
}

-(BOOL)shouldShowNextDesign
{
    _shouldShowNextDesign = NO;
    if ([self.currentUser.readingLog integerValue] > 0) {
        _shouldShowNextDesign = [self currentReadingTracker] == 0;
    }
    return _shouldShowNextDesign;
}

-(NSInteger)currentReadingTracker
{
    return [self.currentUser.readingLog integerValue] % 600;
}

-(NSIndexPath *)currentIndexPath
{
    if (!_currentIndexPath) {
        self.currentIndexPath = [NSIndexPath indexPathForItem:0
                                                    inSection:0];
    }
    return _currentIndexPath;
}

-(void)decrementIndexPath
{
    if (self.currentIndexPath.item > 0) {
        NSUInteger idx = self.currentIndexPath.item - 1;
        self.currentIndexPath = [NSIndexPath indexPathForItem:idx
                                                    inSection:self.currentIndexPath.section];
    }
}

-(void)incrementIndexPath
{
    NSUInteger idx = self.currentIndexPath.item + 1;
    if (idx < [self.readingLogCollectionView numberOfItemsInSection:0]) {
        self.currentIndexPath = [NSIndexPath indexPathForItem:idx
                                                    inSection:self.currentIndexPath.section];
    }
}

- (void)addReadingMinutes
{
    [self.currentUser incrementReadingLog];
    ReadingLogCell *cell = [self.readingLogCollectionViewCells objectAtIndex:self.currentIndexPath.item];
    cell.imageView.image = [UIImage imageNamed:@"CHECKMARK"];
    [self updateReadingLogRemote];
    [self incrementIndexPath];
}

- (void)subtractReadingMinutes
{
    if (self.currentReadingTracker > 0) {
        [self decrementIndexPath];
        [self.currentUser decrementReadingLog];
        ReadingLogCell *cell = [self.readingLogCollectionViewCells objectAtIndex:self.currentIndexPath.item];
        cell.imageView.image = nil;
        [self updateReadingLogRemote];
    }
}

-(void)updateReadingLogRemote
{
    [[ServiceRequest sharedRequest] updateReadingLogForUser:self.currentUser
    completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkForReadingMileStones];
        });
    }];
}

- (void)updateReadingLogCollectionView
{
    [self.readingLogCollectionView reloadItemsAtIndexPaths:@[self.currentIndexPath]];
}

- (void)checkForReadingMileStones
{
    if (self.shouldShowNextDesign)
    {
        NSString *imageName = [NSString stringWithFormat:@"Design%ld",(long)[self.currentUser nextDesignIndex]];
        self.batteryFullImageView.image = [UIImage imageNamed:imageName];
        self.batteryFullImageView.hidden = NO;
        self.readingLogCollectionView.hidden = YES;
    }
    else
    {
        self.batteryFullImageView.hidden = YES;
        self.readingLogCollectionView.hidden = NO;
        return;
    }
    
    if ([self.currentUser.readingLog integerValue] == 600)
    {
        ServiceRequest *sr = [ServiceRequest sharedRequest];
        [sr getPrizeAndUserTypesWithCompletionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error) {
            PrizeTypes *prizes = [[PrizeTypes alloc] prizeTypesWithProperties:json[@"prizes"]];
            PrizeType *prizesForUser = [prizes prizesForUserType:self.currentUser.userType];
            
            NSString *message = nil;
            NSMutableArray *won = [[self.currentUser.prizes valueForKeyPath:@"state"] mutableCopy];
            if ([won[2]  isEqual: @(1)]) {
                if (prizesForUser.prize2) {
                    message = [NSString stringWithFormat:@"You've won the following prize for completing 10 hours of reading: %@.\nKeep tracking your reading to earn more reading badges!",prizesForUser.prize2];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [Utillities showAlertWithTitle:@"Congratulations!"
                                       message:message
                                      delegate:self
                             cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            });
        }];
    }
    else if ([self shouldShowNextDesign])
    {
        [Utillities showAlertWithTitle:@"Congratulations!"
                               message:@"Keep tracking your reading to earn more reading badges!"
                              delegate:self
                     cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
}

#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupReadingLogCollectionViewCells];
        [self.readingLogCollectionView reloadData];
        self.batteryFullImageView.hidden = YES;
        self.readingLogCollectionView.hidden = NO;
    });
}

#pragma mark UICollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 30;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ReadingLogCell *cell = nil;
    if ([self.readingLogCollectionViewCells count]) {
        cell = [self.readingLogCollectionViewCells objectAtIndex:indexPath.item];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        CGRect frame = reusableview.frame;
        frame.origin.x = 5;
        frame.size.width = CGRectGetWidth(reusableview.frame)-10;
        UILabel *header = [[UILabel alloc] initWithFrame:frame];
        [header setLineBreakMode:NSLineBreakByWordWrapping];
        [header setNumberOfLines:0];
        [header setFont:[UIFont systemFontOfSize:14]];
        [header setText:@"For every 20 minutes you read, click '+20' Read for 10 hours to reveal special artwork and win a prize."];
        [reusableview addSubview:header];
        return reusableview;
    }
    return nil;
}


@end

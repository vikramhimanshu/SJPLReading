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

@interface ReadingLogViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>

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
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"read_background"]];
    [backgroundView setContentMode:UIViewContentModeScaleAspectFill];
    self.readingLogCollectionView.backgroundView = backgroundView;
}

- (void)setupReadingLogCollectionViewCells
{
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
    NSInteger idx = [self.currentUser.readingLog integerValue]/600;
    return idx == [self.currentUser nextDesignIndex];
}

-(NSInteger)currentReadingTracker
{
    _currentReadingTracker = labs([self.currentUser.readingLog integerValue]-[self.currentUser nextDesignIndex]*MinReadingMinutes);
    
    return _currentReadingTracker;
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
        dispatch_sync(dispatch_get_main_queue(), ^{
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
    if (self.shouldShowNextDesign) {
        NSString *imageName = [NSString stringWithFormat:@"Design%ld",(long)[self.currentUser nextDesignIndex]];
        self.batteryFullImageView.image = [UIImage imageNamed:imageName];
        self.batteryFullImageView.hidden = NO;
        self.readingLogCollectionView.hidden = YES;
        self.myNavigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        self.batteryFullImageView.hidden = YES;
        self.readingLogCollectionView.hidden = NO;
        self.myNavigationItem.rightBarButtonItem.enabled = YES;
        return;
    }
    
    if ([self.currentUser.readingLog integerValue] == 600) {
        [Utillities showAlertWithTitle:@"Congratulations!"
                               message:@"You've won a prize for completing 10 hours of reading!\nPlease log on to sjplsummer.org to see when you have earned prizes or visit your local San José Public Library."
                              delegate:self
                     cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
//    else {
//        [Utillities showAlertWithTitle:@"Congratulations!"
//                               message:@"Keep tracking your reading to earn more reading badges!"
//                              delegate:self
//                     cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//    }
}

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

@end

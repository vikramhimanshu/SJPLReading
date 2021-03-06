//
//  User.m
//  SanJoseLibrary
//
//  Created by Himanshu Tantia on 5/7/14.
//  Copyright (c) 2014 Himanshu Tantia. All rights reserved.
//

#import "User.h"
#import "Activity.h"

//static NSInteger const MinReadingMinutes = 600;
static NSInteger const MaxReadingMinutes = 18000;
static NSInteger const ReadingMinutesInterval = 20;

@implementation User {
    NSInteger _currentDesignIndex;
}

-(NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.id
                   forKey:@"id"];
    [encoder encodeObject:self.firstName
                   forKey:@"firstName"];
    [encoder encodeObject:self.lastName
                   forKey:@"lastName"];
    [encoder encodeObject:self.userType
                   forKey:@"userType"];
    [encoder encodeObject:self.readingLog
                   forKey:@"readingLog"];
    [encoder encodeObject:self.prizes
                   forKey:@"prizes"];
    [encoder encodeObject:self.activityGrid
                   forKey:@"activityGrid"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if((self = [super init]))
    {
        self.id = [decoder decodeObjectForKey:@"id"];
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.readingLog = [decoder decodeObjectForKey:@"readingLog"];
        self.userType = [decoder decodeObjectForKey:@"userType"];
        self.prizes = [decoder decodeObjectForKey:@"prizes"];
        self.activityGrid = [decoder decodeObjectForKey:@"activityGrid"];
    }
    return self;
}

-(NSNumber *)readingLog
{
    if ([_readingLog integerValue]>MaxReadingMinutes)
        _readingLog = [NSNumber numberWithInteger:MaxReadingMinutes];
    else if ([_readingLog integerValue]<0)
        _readingLog = [NSNumber numberWithInteger:0];
    
    return _readingLog;
}

-(NSInteger)nextDesignIndex
{
    float current = [self.readingLog floatValue];
    NSInteger index = ceil(current/600.0f);
    index = index % 5;
    if (index == 0) {
        index = 5;
    }
    if (_currentDesignIndex != index) {
        _currentDesignIndex = index;
    }
    return _currentDesignIndex;
}

-(void)incrementReadingLog
{
    NSInteger current = [self.readingLog integerValue];
    current = current + ReadingMinutesInterval;
    self.readingLog = [NSNumber numberWithInteger:current];
}

-(void)decrementReadingLog
{
    NSInteger current = [self.readingLog integerValue];
    current = current - ReadingMinutesInterval;
    self.readingLog = [NSNumber numberWithInteger:current];
}

-(void)updateActivity:(Activity *)userActivity atIndex:(NSInteger)cellIndex
{
    Activity *act = [self.activityGrid objectAtIndex:cellIndex];
    act.activity = userActivity.activity;
    act.notes = userActivity.notes;
    act.updatedAt = userActivity.updatedAt;
}

@end

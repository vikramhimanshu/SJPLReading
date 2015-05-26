//
//  UserTypes.m
//  SanJoseLibrary
//
//  Created by Himanshu Tantia on 5/7/14.
//  Copyright (c) 2014 Himanshu Tantia. All rights reserved.
//

#import "UIColor+SJPLColors.h"
#import "UserType.h"

@interface UserType ()

@end

@implementation UserType {
    NSString *internalDescription;
}

-(void)setDescription:(NSString *)description {
    internalDescription = description;
}

-(NSString *)description {
    return internalDescription;
}

-(UIColor *)color
{
    if ([_name caseInsensitiveCompare:@"READER"] == NSOrderedSame) {
        return [UIColor sjplYellowColor];
    }
    else if ([_name caseInsensitiveCompare:@"PRE-READER"] == NSOrderedSame)
    {
        return [UIColor sjplRedColor];
    }
    else if ([_name caseInsensitiveCompare:@"TEEN"] == NSOrderedSame)
    {
        return [UIColor sjplBlueColor];
    }
    else if ([_name caseInsensitiveCompare:@"ADULT"] == NSOrderedSame)
    {
        return [UIColor sjplGreenColor];
    }
    else if ([_name caseInsensitiveCompare:@"STAFF SJPL"] == NSOrderedSame)
    {
        return [UIColor sjplGrayColor];
    }
    else
    {
        return [UIColor colorWithBackgroundImage];
    }
}

@end

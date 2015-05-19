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

@property (nonatomic, strong) NSString *internalDescription;

@end

@implementation UserType

-(void)setDescription:(NSString *)description {
    self.internalDescription = description;
}

-(NSString *)description {
    return self.internalDescription;
}

-(UIColor *)color
{
    UIColor *color = [UIColor whiteColor];
    if ([_name isEqualToString:@"READER"]) {
        color = UIColorFromRGB(0xD5453A);
    }
    else if ([_name isEqualToString:@"PRE-READER"])
    {
        color = UIColorFromRGB(0xD08035);
    }
    else if ([_name isEqualToString:@"TEEN"])
    {
        color = UIColorFromRGB(0x257782);
    }
    else if ([_name isEqualToString:@"ADULT"])
    {
        color = UIColorFromRGB(0x2CA341);
    }
    else if ([_name isEqualToString:@"STAFF SJPL"])
    {
        color = UIColorFromRGB(0x6D6E70);
    }    
    return color;
}

@end

//
//  UIColor+SJPLColors.m
//  SanJoseLibrary
//
//  Created by Himanshu Vikram on 5/18/15.
//  Copyright (c) 2015 Himanshu Vikram. All rights reserved.
//

#import "UIColor+SJPLColors.h"

@implementation UIColor (SJPLColors)

+(UIColor *)colorWithBackgroundImage
{
    return [self colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

+(UIColor *)sjplRedColor
{
    return UIColorFromRGB(0xf7b1bb);
}

+(UIColor *)sjplGreenColor
{
    return UIColorFromRGB(0xadddd7);
}

+(UIColor *)sjplBlueColor
{
    return UIColorFromRGB(0xc2d6ee);
}

+(UIColor *)sjplGrayColor
{
    return UIColorFromRGB(0xf7b1bb);
}

+(UIColor *)sjplYellowColor
{
    return UIColorFromRGB(0xf7b1bb);
}

@end

//
//  UIColor+SJPLColors.h
//  SanJoseLibrary
//
//  Created by Himanshu Vikram on 5/18/15.
//  Copyright (c) 2015 Himanshu Vikram. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface UIColor (SJPLColors)

+(UIColor *)colorWithBackgroundImage;

+(UIColor *)sjplRedColor;
+(UIColor *)sjplGreenColor;
+(UIColor *)sjplBlueColor;
+(UIColor *)sjplGrayColor;
+(UIColor *)sjplYellowColor;

@end

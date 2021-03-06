//
//  Utillities.h
//  SanJoseLibrary
//
//  Created by Himanshu Tantia on 5/8/14.
//  Copyright (c) 2014 Himanshu Tantia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utillities : NSObject

+(void)showBasicInputError;
+(void)showBasicNetworkError;

+(UIAlertView *)alertViewWithTitle:(NSString *)title
                           message:(NSString *)msg
                          delegate:(id)delegate
                 cancelButtonTitle:(NSString *)cancelTitle
                 otherButtonTitles:(NSString *)otherTitles, ...;

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)msg
                  delegate:(id)delegate
         cancelButtonTitle:(NSString *)cancelTitle
         otherButtonTitles:(NSString *)otherTitles, ...;

@end

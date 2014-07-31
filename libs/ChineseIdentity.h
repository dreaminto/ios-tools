//
//  ChineseIdentity.h
//  com_dreaminto_libs
//
//  Created by pan peng on 14-7-27.
//  Copyright (c) 2014年 com.dreaminto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChineseIdentity : NSObject
{
    NSArray *_factor;
    NSArray *_verifyCodeKey;
    NSArray *_verifyCodeObj;
    NSDictionary *_verifyCode;
    NSArray *_areaCodeObj;
    NSArray *_areaCodeKey;
    NSDictionary *_areaCode;
}
- (BOOL)check:(NSString *) str;
@end

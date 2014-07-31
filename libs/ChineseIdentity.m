//
//  ChineseIdentity.m
//  com_dreaminto_libs
//
//  Created by pan peng on 14-7-27.
//  Copyright (c) 2014年 com.dreaminto. All rights reserved.
//
/*
 身份证的编码规则：
 1-6位：以2位为单位, 按层次表示中国各省（自治区、直辖市、特别行政区）、市（地区、自治州、盟）、县（自治县、市、市辖区、旗、自治旗）的名称。
 7-14位：出生日期。
 15-17位：顺序码。顺序码的奇数分配给男性, 偶数分配给女性。
 18位：检验位。
    公式：
    1、对前17位数字本体码加权求和。S = Sum(Ai*Wi),i=1...17
        Ai:身份证的号码数值
        Wi:第i位置的加权因子, 其对应的值依次为：7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2
    2、以11对计算结果取模。Y = mod(S, 11)
    3、根据模的值得到对应的校验码
        对应关系：
            Y值：0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
            校验码：1, 0, X, 9, 8, 7, 6, 5, 4, 3, 2
 
 */

#import "ChineseIdentity.h"

@implementation ChineseIdentity
- (id)init {
    self = [super init];
    if (self) {
        _factor = [NSArray arrayWithObjects:@7, @9, @10, @5, @8, @4, @2, @1, @6, @3, @7, @9, @10, @5, @8, @4, @2, nil];
        _verifyCodeKey = [NSArray arrayWithObjects:@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, nil];
        _verifyCodeObj = [NSArray arrayWithObjects:@1, @0, @"X", @9, @8, @7, @6, @5, @4, @3, @2, nil];
        _verifyCode = [NSDictionary dictionaryWithObjects:_verifyCodeObj forKeys:_verifyCodeKey];
        _areaCodeKey = [NSArray arrayWithObjects:@11, @12, @13, @14, @15, @21, @22, @23, @31, @32, @33, @34, @35, @36, @37, @41, @42, @43, @44, @45, @46, @50, @51, @52, @53, @54, @61, @62, @63, @64, @65, nil];
        _areaCodeObj = [NSArray arrayWithObjects:@"北京市", @"天津市", @"河北省", @"山西省", @"内蒙古自治区", @"辽宁省", @"吉林省", @"黑龙江省", @"上海市", @"江苏省", @"浙江省", @"安徽省", @"福建省", @"江西省", @"山东省", @"河南省", @"湖北省", @"湖南省", @"广东省", @"广西壮族自治区", @"海南省", @"重庆市", @"四川省", @"贵州省", @"云南省", @"西藏自治区", @"陕西省", @"甘肃省", @"青海省", @"宁夏回族自治区", @"新疆维吾尔自治区", nil];
        _areaCode = [NSDictionary dictionaryWithObjects:_areaCodeObj forKeys:_areaCodeKey];
    }
    
    return self;
}
- (BOOL)check:(NSString *)str {

    /**
     计算str长度：18, 15.本程序只支持18.
     判断地区编码是否符合
     判断出生日期是否合理, 目前还没有年龄大于200的人
     判断校验码
     */
    if ( str.length != 18 ) return NO;
    
    return [self checkAreaCode:str] && [self checkBirthday:str] && [self checkVerify:str];
    }


- (BOOL)checkAreaCode:(NSString *)str {
    NSRange subRange = NSMakeRange(0, 2);
    NSString *province = [str substringWithRange:subRange];
    if ( [_areaCode objectForKey:[NSNumber numberWithInt:[province integerValue]]] ) {
        return YES;
    }
    return NO;
}

/**
 闰年知识：
    公历年份是整百数的，必须是400的倍数才是闰年。例如：1900年的年份数1900是整百数，是4的倍数，但不是400的倍数，所以1900年不是闰年是平年。而2000年的年份数2000是整百数，是4的倍数，也是400的倍数，所以2000年是闰年。
    这是为什么呢？我们居住的地球总是绕着太阳旋转的。地球绕太阳转一圈需要365天5时48分46秒。我们把这一段长度称为“回归年”。为了使用方便，我们将365天作为公历平年的一年。这样平均每年要多出5小时48分46秒，累积4年就有23小时15分4秒，几乎接近一天的时间；如果累积400年，就会多出97天来，久而久之会出现寒暑颠倒，历法会失去实用价值。怎么办呢？唯一的办法是设置一年的闰年，每逢闰年的就比平年增加一天，成为366天。这样经过3333年才有一天的误差。那么，公历的闰年是怎么安排的呢？
 
    经过研究对公历的闰年设置作出这样的规定：凡非整百的公元纪年年数能被整除的定为闰年；而整百的公元年分要能被400整除的才能定为闰年。这样每400年中刚巧是97个闰年。2000年是逢百之年第二次闰年，第一次是1600年，下一次要到2400年了。
 */
- (BOOL)checkBirthday:(NSString *)str {
    NSRange subRange = NSMakeRange(6, 8);
//    NSString *birthday = [str substringWithRange:subRange];
    
    subRange.length = 4;
    subRange.location = 6;
    NSString *year = [str substringWithRange:subRange];
    
    subRange.length = 2;
    subRange.location = 10;
    NSString *month = [str substringWithRange:subRange];
    
    subRange.location = 12;
    NSString *day = [str substringWithRange:subRange];
//    NSLog(@"birthday:%@, year %@ month %@ day %@", birthday, year,month,day);
    
    int now = [NSDate timeIntervalSinceReferenceDate];
//    int beforNow200 = [[NSDate alloc] initWithTimeIntervalSinceNow:-200*366*24*60*60];
    
    NSString *birthdayStr = [NSString stringWithFormat:@"%@-%@-%@", year, month, day];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd";
    int birthdayTime = [[formatter dateFromString:birthdayStr] timeIntervalSinceReferenceDate];
    
    formatter.dateFormat = @"yyyy";
    NSString *nowYear = [formatter stringFromDate:[NSDate date]];
    int maxAge = 200;
    
    int dayInt = [day integerValue];
    int yearInt = [year integerValue];
    int age = [nowYear integerValue] - yearInt;
    
    //出生日期不能大于当前日期
    if (now<birthdayTime || age>maxAge) {
        return NO;
    }
    
    //判断大月日期不能大于31，小月日期不能大于30，2月根据是否闰年判断最大日期
    switch ([month integerValue]) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            if (dayInt>31) return NO;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            if (dayInt>30) return NO;
            break;
        case 2:
            if (
                (yearInt % 4 == 0 && yearInt % 100 !=0)
                || yearInt % 400 == 0 ) {
                if (dayInt>29) return NO;
            }
            else {
                if (dayInt>28) return NO;
            }
            break;
        default:
            break;
    }
    
    return YES;
}

- (BOOL)checkVerify:(NSString *)str {
    NSRange subRange = NSMakeRange(0, 1);
    int s = 0;
    for (int i=0; i<17; i++) {
        subRange.location = i;
        s += [[str substringWithRange:subRange] integerValue] * [_factor[i] integerValue];
    }
    int y = s % 11;
    NSString *verifyChar = [_verifyCode objectForKey:[NSNumber numberWithInt:y]];
    if ( [verifyChar isEqualToString:@"X"] ) {
        if ([verifyChar isEqual:[[str substringFromIndex:17] uppercaseString]]) return YES;
        else return NO;
    }
    else {
        if ([verifyChar isEqual:[str substringFromIndex:17]]) return YES;
        else return NO;

    }

    return NO;

}

@end

#ifndef ABOUTMETWEAK_H
#define ABOUTMETWEAK_H

#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <dlfcn.h>
#import <CoreFoundation/CoreFoundation.h>

// ==========================================
// 常數定義
// ==========================================
static const CGFloat kAMCardCornerRadius     = 24.0;
static const CGFloat kAMRowCardCornerRadius  = 16.0;
static const CGFloat kAMPadding              = 20.0;
static const CGFloat kAMCardSpacing          = 15.0;
static const CGFloat kAMMainCardHeight       = 220.0;
static const CGFloat kAMSmallCardHeight      = 90.0;
static const CGFloat kAMRowCardHeight        = 56.0;
static const CGFloat kAMRowCardGap           = 10.0;
static const NSInteger kAMValueLabelTag      = 1001;

// ==========================================
// 私有 API 宣告
// ==========================================
@interface PSSpecifier : NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *identifier;
- (void)performSetterWithValue:(id)value;
@end

@interface NSObject (PreferencesPrivate)
- (void)setDeviceName:(id)name specifier:(id)specifier;
@end

@interface PSListController : UIViewController
- (UITableView *)table;
- (NSMutableArray *)specifiers;
@end

@interface UIDevice (Private)
- (NSString *)buildVersion;
@end

// ==========================================
// AboutMeHeaderView — 自訂 Header 容器
// ==========================================
@interface AboutMeHeaderView : UIView
@end

// ==========================================
// AboutMeSystemInfo — 系統資訊工具
// ==========================================
@interface AboutMeSystemInfo : NSObject
+ (NSString *)sysInfoForKey:(CFStringRef)key;
+ (NSString *)realDeviceName;
+ (NSString *)deviceModelName;
+ (NSString *)hardwareModelCode;
+ (NSString *)maskedSerialFromFull:(NSString *)serial;
@end

// ==========================================
// AboutMeUIFactory — UI 元件工廠
// ==========================================
@interface AboutMeUIFactory : NSObject
+ (UIView *)rowCardWithFrame:(CGRect)frame
                    iconName:(NSString *)iconName
                       title:(NSString *)title
                       value:(NSString *)value;

+ (UIView *)mainGradientCardWithFrame:(CGRect)frame;
+ (UIView *)nameCardWithFrame:(CGRect)frame;
+ (UIView *)storageCardWithFrame:(CGRect)frame;
@end

// ==========================================
// AboutMeTweakManager — 互動邏輯管理
// ==========================================
@interface AboutMeTweakManager : NSObject
@property (nonatomic, weak) UILabel *nameLabelToUpdate;
@property (nonatomic, weak) UIViewController *currentVC;
@property (nonatomic, strong) PSSpecifier *nameSpecifier;
@property (nonatomic, weak) id aboutDataSource;

// 機型型號切換
@property (nonatomic, weak) UILabel *modelLabelToUpdate;
@property (nonatomic, copy) NSString *retailModelNumber;
@property (nonatomic, copy) NSString *hardwareModelNumber;
@property (nonatomic, assign) BOOL isShowingHardwareModel;

// 序號隱藏與複製
@property (nonatomic, weak) UILabel *serialLabelToUpdate;
@property (nonatomic, copy) NSString *serialNumberToCopy;
@property (nonatomic, copy) NSString *maskedSerialNumber;
@property (nonatomic, assign) BOOL isSerialMasked;

+ (instancetype)sharedInstance;
- (void)handleNameCardTap;
- (void)handleModelCardTap;
- (void)handleSerialCardTap;
- (void)handleSerialCardLongPress:(UILongPressGestureRecognizer *)gesture;
@end

#endif /* ABOUTMETWEAK_H */


#import "../Headers/AboutMeTweak.h"

@implementation AboutMeSystemInfo

// 使用 static 變數快取 dlopen 句柄，避免重複載入
+ (NSString *)sysInfoForKey:(CFStringRef)key {
    static void *gestalt = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_GLOBAL | RTLD_LAZY);
    });

    if (gestalt) {
        CFTypeRef (*MGCopyAnswer_func)(CFStringRef) =
            (CFTypeRef (*)(CFStringRef))dlsym(gestalt, "MGCopyAnswer");
        if (MGCopyAnswer_func) {
            CFTypeRef answer = MGCopyAnswer_func(key);
            if (answer) {
                if (CFGetTypeID(answer) == CFStringGetTypeID()) {
                    return (__bridge_transfer NSString *)answer;
                } else {
                    CFRelease(answer);
                }
            }
        }
    }
    return @"";
}

+ (NSString *)realDeviceName {
    NSString *savedCustomName = [[NSUserDefaults standardUserDefaults]
                                  stringForKey:@"AboutMeTweak_CustomDeviceName"];
    if (savedCustomName.length > 0) {
        return savedCustomName;
    }
    NSString *name = [self sysInfoForKey:CFSTR("UserAssignedDeviceName")];
    return (name.length > 0) ? name : [[UIDevice currentDevice] name];
}

+ (NSDictionary *)_loadModelsPlist {
    // 嘗試多個可能的安裝路徑
    NSArray *paths = @[
        @"/var/jb/Library/MobileSubstrate/DynamicLibraries/AboutMeTweakModels.plist",
        @"/Library/MobileSubstrate/DynamicLibraries/AboutMeTweakModels.plist",
    ];
    for (NSString *path in paths) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        if (dict) return dict;
    }
    return nil;
}

// 內嵌 fallback 字典，確保即使 plist 不存在也能正確顯示
+ (NSDictionary *)_builtinDisplayNames {
    static NSDictionary *names = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = @{
            // iPhone 8
            @"iPhone10,1" : @"iPhone 8",
            @"iPhone10,4" : @"iPhone 8",
            // iPhone 8 Plus
            @"iPhone10,2" : @"iPhone 8 Plus",
            @"iPhone10,5" : @"iPhone 8 Plus",
            // iPhone X
            @"iPhone10,3" : @"iPhone X",
            @"iPhone10,6" : @"iPhone X",
            // iPhone XR / XS / XS Max
            @"iPhone11,8" : @"iPhone XR",
            @"iPhone11,2" : @"iPhone XS",
            @"iPhone11,4" : @"iPhone XS Max",
            @"iPhone11,6" : @"iPhone XS Max",
            // iPhone 11 系列
            @"iPhone12,1" : @"iPhone 11",
            @"iPhone12,3" : @"iPhone 11 Pro",
            @"iPhone12,5" : @"iPhone 11 Pro Max",
            @"iPhone12,8" : @"iPhone SE (2nd)",
            // iPhone 12 系列
            @"iPhone13,1" : @"iPhone 12 mini",
            @"iPhone13,2" : @"iPhone 12",
            @"iPhone13,3" : @"iPhone 12 Pro",
            @"iPhone13,4" : @"iPhone 12 Pro Max",
            // iPhone 13 系列
            @"iPhone14,4" : @"iPhone 13 mini",
            @"iPhone14,5" : @"iPhone 13",
            @"iPhone14,2" : @"iPhone 13 Pro",
            @"iPhone14,3" : @"iPhone 13 Pro Max",
            @"iPhone14,6" : @"iPhone SE (3rd)",
            // iPhone 14 系列
            @"iPhone14,7" : @"iPhone 14",
            @"iPhone14,8" : @"iPhone 14 Plus",
            @"iPhone15,2" : @"iPhone 14 Pro",
            @"iPhone15,3" : @"iPhone 14 Pro Max",
            // iPhone 15 系列
            @"iPhone15,4" : @"iPhone 15",
            @"iPhone15,5" : @"iPhone 15 Plus",
            @"iPhone16,1" : @"iPhone 15 Pro",
            @"iPhone16,2" : @"iPhone 15 Pro Max",
            // iPhone 16 系列
            @"iPhone17,3" : @"iPhone 16",
            @"iPhone17,4" : @"iPhone 16 Plus",
            @"iPhone17,1" : @"iPhone 16 Pro",
            @"iPhone17,2" : @"iPhone 16 Pro Max",
        };
    });
    return names;
}

+ (NSString *)deviceModelName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machine = [NSString stringWithCString:systemInfo.machine
                                           encoding:NSUTF8StringEncoding];

    // 優先從外部 plist 查詢（方便日後擴充不需重新編譯）
    NSDictionary *plist = [self _loadModelsPlist];
    NSString *modelName = plist[@"displayNames"][machine];
    if (modelName) return modelName;

    // Fallback：使用內嵌字典
    modelName = [self _builtinDisplayNames][machine];
    return modelName ?: machine;
}

+ (NSString *)hardwareModelCode {
    NSString *regModel = [self sysInfoForKey:CFSTR("RegulatoryModelNumber")];
    if (regModel.length > 0) {
        return regModel;
    }

    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machine = [NSString stringWithCString:systemInfo.machine
                                           encoding:NSUTF8StringEncoding];

    NSDictionary *plist = [self _loadModelsPlist];
    NSString *code = plist[@"hardwareCodes"][machine];
    return code ?: machine;
}

+ (NSString *)maskedSerialFromFull:(NSString *)serial {
    if (!serial || serial.length <= 6) {
        return serial ?: @"Unknown";
    }
    NSString *prefix = [serial substringToIndex:3];
    NSString *suffix = [serial substringFromIndex:serial.length - 3];
    NSMutableString *dots = [NSMutableString string];
    for (NSUInteger i = 0; i < serial.length - 6; i++) {
        [dots appendString:@"•"];
    }
    return [NSString stringWithFormat:@"%@%@%@", prefix, dots, suffix];
}

@end


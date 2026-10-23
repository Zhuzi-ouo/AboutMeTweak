#import "Headers/AboutMeTweak.h"
#import <objc/runtime.h>

// ==========================================
// 已處理標記 — 防止 specifiers 被重複過濾
// ==========================================
static const void *kAMFilteredKey = &kAMFilteredKey;

static void removeHiddenSpecifiers(NSMutableArray *orig, id owner) {
    if (!orig || ![orig respondsToSelector:@selector(removeObjectsInArray:)]) return;

    // 使用 Associated Object 標記已過濾的陣列，避免 PSGAboutDataSource 和
    // PSListController 雙重 hook 導致重複處理
    if (objc_getAssociatedObject(orig, kAMFilteredKey)) return;
    objc_setAssociatedObject(orig, kAMFilteredKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    NSSet *hideIDs = [NSSet setWithArray:@[
        @"Device Name", @"Software Version", @"Model Name",
        @"Model Number", @"Serial Number", @"Name",
        @"SoftwareVersion", @"ProductModel", @"ProductModelNumber", @"SerialNumber"
    ]];
    NSSet *hideNames = [NSSet setWithArray:@[
        @"Name", @"名稱", @"iOS Version", @"iOS 版本",
        @"Model Name", @"機型名稱", @"Model Number", @"機型型號",
        @"Serial Number", @"序號"
    ]];

    NSMutableArray *toRemove = [NSMutableArray array];

    for (PSSpecifier *spec in orig) {
        NSString *specID   = ([spec respondsToSelector:@selector(identifier)]) ? spec.identifier : nil;
        NSString *specName = ([spec respondsToSelector:@selector(name)])       ? spec.name       : nil;

        // 擷取裝置名稱的 specifier 供後續使用
        if ((specID   && ([specID isEqualToString:@"Name"] || [specID isEqualToString:@"Device Name"])) ||
            (specName && ([specName isEqualToString:@"名稱"] || [specName isEqualToString:@"Name"]))) {
            [AboutMeTweakManager sharedInstance].nameSpecifier = spec;
            if (owner) {
                [AboutMeTweakManager sharedInstance].aboutDataSource = owner;
            }
        }

        BOOL shouldHide = (specID   && [hideIDs   containsObject:specID]) ||
                          (specName && [hideNames  containsObject:specName]);
        if (shouldHide) {
            [toRemove addObject:spec];
        }
    }

    if (toRemove.count > 0) {
        [orig removeObjectsInArray:toRemove];
    }
}

// 判斷當前控制器是否為「關於本機」頁面
static BOOL isAboutController(id self) {
    Class psg   = NSClassFromString(@"PSGAboutController");
    Class prefs = NSClassFromString(@"PrefsAboutController");
    return (psg && [self isKindOfClass:psg]) || (prefs && [self isKindOfClass:prefs]);
}

// ==========================================
// 攔截 iOS 現代版本的資料來源
// ==========================================
%hook PSGAboutDataSource
- (NSMutableArray *)specifiers {
    NSMutableArray *orig = %orig;
    removeHiddenSpecifiers(orig, self);
    return orig;
}
%end

// ==========================================
// 攔截設定列表控制器
// ==========================================
%hook PSListController

- (NSMutableArray *)specifiers {
    NSMutableArray *orig = %orig;
    if (isAboutController(self)) {
        removeHiddenSpecifiers(orig, self);
    }
    return orig;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (isAboutController(self) && (section == 0 || section == 1)) {
        return 0.01f;
    }
    return %orig;
}

- (void)viewDidLoad {
    %orig;

    if (!isAboutController(self)) return;

    [AboutMeTweakManager sharedInstance].currentVC = self;

    UITableView *tableView = [self table];
    if (!tableView) return;

    if (@available(iOS 15.0, *)) {
        tableView.sectionHeaderTopPadding = 0;
    }

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat contentWidth = screenWidth - (kAMPadding * 2);

    // Header 容器
    AboutMeHeaderView *headerContainer = [[AboutMeHeaderView alloc]
        initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
    headerContainer.backgroundColor = [UIColor clearColor];
    headerContainer.clipsToBounds = NO;

    // 1. 主漸層卡片
    CGRect mainCardFrame = CGRectMake(kAMPadding, kAMPadding, contentWidth, kAMMainCardHeight);
    UIView *mainCard = [AboutMeUIFactory mainGradientCardWithFrame:mainCardFrame];
    [headerContainer addSubview:mainCard];

    // 2. 中間雙卡片
    CGFloat smallCardWidth = (contentWidth - kAMCardSpacing) / 2;
    CGFloat smallCardY = kAMPadding + kAMMainCardHeight + kAMCardSpacing;

    UIView *nameCard = [AboutMeUIFactory nameCardWithFrame:
        CGRectMake(kAMPadding, smallCardY, smallCardWidth, kAMSmallCardHeight)];
    [headerContainer addSubview:nameCard];

    UIView *storageCard = [AboutMeUIFactory storageCardWithFrame:
        CGRectMake(kAMPadding + smallCardWidth + kAMCardSpacing, smallCardY,
                   smallCardWidth, kAMSmallCardHeight)];
    [headerContainer addSubview:storageCard];

    // 3. 底部列表卡片
    CGFloat rowCardY = smallCardY + kAMSmallCardHeight + kAMCardSpacing;

    // 機型型號卡片
    NSString *modelStr  = [AboutMeSystemInfo sysInfoForKey:CFSTR("ModelNumber")];
    NSString *regionStr = [AboutMeSystemInfo sysInfoForKey:CFSTR("RegionInfo")];
    NSString *fullModel = [NSString stringWithFormat:@"%@%@", modelStr ?: @"", regionStr ?: @""];
    if (fullModel.length == 0) fullModel = @"Unknown";

    UIView *modelCard = [AboutMeUIFactory rowCardWithFrame:
        CGRectMake(kAMPadding, rowCardY, contentWidth, kAMRowCardHeight)
        iconName:@"tag.fill" title:@"機型型號" value:fullModel];

    modelCard.userInteractionEnabled = YES;
    UITapGestureRecognizer *modelTap = [[UITapGestureRecognizer alloc]
        initWithTarget:[AboutMeTweakManager sharedInstance]
                action:@selector(handleModelCardTap)];
    [modelCard addGestureRecognizer:modelTap];

    AboutMeTweakManager *manager = [AboutMeTweakManager sharedInstance];
    manager.retailModelNumber   = fullModel;
    manager.hardwareModelNumber = [AboutMeSystemInfo hardwareModelCode];
    manager.isShowingHardwareModel = NO;
    manager.modelLabelToUpdate  = (UILabel *)[modelCard viewWithTag:kAMValueLabelTag];

    [headerContainer addSubview:modelCard];

    // 序號卡片
    CGFloat serialCardY = rowCardY + kAMRowCardHeight + kAMRowCardGap;

    NSString *serialStr = [AboutMeSystemInfo sysInfoForKey:CFSTR("SerialNumber")];
    if (serialStr.length == 0) serialStr = @"Unknown";

    NSString *maskedSerial = [AboutMeSystemInfo maskedSerialFromFull:serialStr];

    UIView *serialCard = [AboutMeUIFactory rowCardWithFrame:
        CGRectMake(kAMPadding, serialCardY, contentWidth, kAMRowCardHeight)
        iconName:@"barcode.viewfinder" title:@"序號" value:serialStr];
    serialCard.userInteractionEnabled = YES;

    UILongPressGestureRecognizer *serialLongPress = [[UILongPressGestureRecognizer alloc]
        initWithTarget:manager action:@selector(handleSerialCardLongPress:)];
    serialLongPress.minimumPressDuration = 0.4;
    [serialCard addGestureRecognizer:serialLongPress];

    UITapGestureRecognizer *serialTap = [[UITapGestureRecognizer alloc]
        initWithTarget:manager action:@selector(handleSerialCardTap)];
    [serialTap requireGestureRecognizerToFail:serialLongPress];
    [serialCard addGestureRecognizer:serialTap];

    manager.serialNumberToCopy  = serialStr;
    manager.maskedSerialNumber  = maskedSerial;
    manager.isSerialMasked      = NO;
    manager.serialLabelToUpdate = (UILabel *)[serialCard viewWithTag:kAMValueLabelTag];

    [headerContainer addSubview:serialCard];

    // 4. 動態計算總高度（含底部 padding）
    CGFloat finalHeight = serialCardY + kAMRowCardHeight + kAMPadding;

    CGRect containerFrame = headerContainer.frame;
    containerFrame.size.height = finalHeight;
    headerContainer.frame = containerFrame;

    tableView.tableHeaderView = headerContainer;
}

%end

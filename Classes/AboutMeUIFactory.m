#import "../Headers/AboutMeTweak.h"

@implementation AboutMeUIFactory

#pragma mark - 列表式卡片

+ (UIView *)rowCardWithFrame:(CGRect)frame
                    iconName:(NSString *)iconName
                       title:(NSString *)title
                       value:(NSString *)value {
    UIView *card = [[UIView alloc] initWithFrame:frame];
    card.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    card.layer.cornerRadius = kAMRowCardCornerRadius;

    UIImageView *iconView = [[UIImageView alloc]
        initWithImage:[UIImage systemImageNamed:iconName]];
    iconView.frame = CGRectMake(15, (frame.size.height - 22) / 2, 22, 22);
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.tintColor = [UIColor systemGrayColor];
    [card addSubview:iconView];

    UILabel *titleLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(45, 0, 100, frame.size.height)];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    titleLabel.textColor = [UIColor secondaryLabelColor];
    [card addSubview:titleLabel];

    UILabel *valueLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(120, 0, frame.size.width - 120 - 15, frame.size.height)];
    valueLabel.tag = kAMValueLabelTag;
    valueLabel.text = value ?: @"Unknown";
    valueLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    valueLabel.textColor = [UIColor labelColor];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.adjustsFontSizeToFitWidth = YES;
    [card addSubview:valueLabel];

    return card;
}

#pragma mark - 主漸層卡片

+ (UIView *)mainGradientCardWithFrame:(CGRect)frame {
    UIView *cardView = [[UIView alloc] initWithFrame:frame];
    cardView.layer.cornerRadius = kAMCardCornerRadius;
    cardView.clipsToBounds = YES;

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = cardView.bounds;
    gradientLayer.colors = @[
        (id)[UIColor colorWithRed:0.59 green:0.29 blue:0.18 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.89 green:0.69 blue:0.35 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.75 green:0.20 blue:0.36 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.43 green:0.29 blue:0.73 alpha:1.0].CGColor
    ];
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    [cardView.layer addSublayer:gradientLayer];

    // 機型名稱
    UILabel *modelLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(0, 25, frame.size.width, 20)];
    modelLabel.text = [AboutMeSystemInfo deviceModelName];
    modelLabel.textColor = [UIColor whiteColor];
    modelLabel.textAlignment = NSTextAlignmentCenter;
    modelLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [cardView addSubview:modelLabel];

    // "iOS" 大字
    UILabel *iosLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(0, 45, frame.size.width, 60)];
    iosLabel.text = @"iOS";
    iosLabel.textColor = [UIColor whiteColor];
    iosLabel.textAlignment = NSTextAlignmentCenter;
    iosLabel.font = [UIFont systemFontOfSize:60 weight:UIFontWeightBold];
    [cardView addSubview:iosLabel];

    // 版本號
    UILabel *versionLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(0, 105, frame.size.width, 25)];
    versionLabel.text = [[UIDevice currentDevice] systemVersion];
    versionLabel.textColor = [UIColor whiteColor];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    [cardView addSubview:versionLabel];

    // Build 膠囊
    NSString *buildVersion = @"Unknown";
    if ([[UIDevice currentDevice] respondsToSelector:@selector(buildVersion)]) {
        buildVersion = [[UIDevice currentDevice] buildVersion];
    }
    NSString *buildText = [NSString stringWithFormat:@"Build %@", buildVersion];
    UIFont *buildFont = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    CGSize textSize = [buildText sizeWithAttributes:@{NSFontAttributeName: buildFont}];
    CGFloat pillWidth = textSize.width + 30;

    UIView *pillView = [[UIView alloc]
        initWithFrame:CGRectMake((frame.size.width - pillWidth) / 2, 155, pillWidth, 32)];
    pillView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
    pillView.layer.cornerRadius = 16;
    pillView.clipsToBounds = YES;

    UILabel *buildLabel = [[UILabel alloc] initWithFrame:pillView.bounds];
    buildLabel.text = buildText;
    buildLabel.textColor = [UIColor whiteColor];
    buildLabel.textAlignment = NSTextAlignmentCenter;
    buildLabel.font = buildFont;

    [pillView addSubview:buildLabel];
    [cardView addSubview:pillView];

    return cardView;
}

#pragma mark - 裝置名稱卡片

+ (UIView *)nameCardWithFrame:(CGRect)frame {
    UIView *nameCard = [[UIView alloc] initWithFrame:frame];
    nameCard.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    nameCard.layer.cornerRadius = kAMRowCardCornerRadius;
    nameCard.userInteractionEnabled = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:[AboutMeTweakManager sharedInstance]
                action:@selector(handleNameCardTap)];
    [nameCard addGestureRecognizer:tap];

    UIImageView *deviceIcon = [[UIImageView alloc]
        initWithImage:[UIImage systemImageNamed:@"iphone"]];
    deviceIcon.frame = CGRectMake(15, 15, 16, 24);
    deviceIcon.contentMode = UIViewContentModeScaleAspectFit;
    deviceIcon.tintColor = [UIColor labelColor];
    [nameCard addSubview:deviceIcon];

    CGFloat contentWidth = frame.size.width - 30;

    UILabel *nameTitle = [[UILabel alloc]
        initWithFrame:CGRectMake(15, 45, contentWidth, 15)];
    nameTitle.text = @"裝置名稱";
    nameTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    nameTitle.textColor = [UIColor secondaryLabelColor];
    [nameCard addSubview:nameTitle];

    UILabel *nameValue = [[UILabel alloc]
        initWithFrame:CGRectMake(15, 62, contentWidth, 20)];
    nameValue.text = [AboutMeSystemInfo realDeviceName];
    nameValue.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    nameValue.textColor = [UIColor labelColor];
    nameValue.adjustsFontSizeToFitWidth = YES;
    [nameCard addSubview:nameValue];

    // 綁定到 Manager 以供後續更新
    [AboutMeTweakManager sharedInstance].nameLabelToUpdate = nameValue;

    return nameCard;
}

#pragma mark - 儲存空間卡片

+ (UIView *)storageCardWithFrame:(CGRect)frame {
    UIView *storageCard = [[UIView alloc] initWithFrame:frame];
    storageCard.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    storageCard.layer.cornerRadius = kAMRowCardCornerRadius;

    // 計算儲存空間
    NSDictionary *attrs = [[NSFileManager defaultManager]
        attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    long long totalSpace = [[attrs objectForKey:NSFileSystemSize] longLongValue];
    long long freeSpace  = [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    long long usedSpace  = totalSpace - freeSpace;
    double totalGB = (double)totalSpace / 1000000000.0;
    double usedGB  = (double)usedSpace / 1000000000.0;

    // 對齊常見規格容量
    long long displayTotalGB = 32;
    long long capacities[] = {32, 64, 128, 256, 512, 1024};
    for (int i = 0; i < 6; i++) {
        if (totalGB > capacities[i]) {
            displayTotalGB = (i + 1 < 6) ? capacities[i + 1] : capacities[i];
        }
    }

    CGFloat contentWidth = frame.size.width - 30;
    CGFloat progress = (CGFloat)usedGB / (CGFloat)displayTotalGB;

    // 進度條底色
    UIView *trackView = [[UIView alloc]
        initWithFrame:CGRectMake(15, 25, contentWidth, 6)];
    trackView.backgroundColor = [UIColor tertiarySystemFillColor];
    trackView.layer.cornerRadius = 3;
    [storageCard addSubview:trackView];

    // 進度條填充（漸層）
    UIView *fillView = [[UIView alloc]
        initWithFrame:CGRectMake(15, 25, contentWidth * progress, 6)];
    fillView.layer.cornerRadius = 3;
    fillView.clipsToBounds = YES;

    CAGradientLayer *barGradient = [CAGradientLayer layer];
    barGradient.frame = CGRectMake(0, 0, contentWidth, 6);
    barGradient.colors = @[
        (id)[UIColor systemOrangeColor].CGColor,
        (id)[UIColor systemPurpleColor].CGColor
    ];
    barGradient.startPoint = CGPointMake(0.0, 0.5);
    barGradient.endPoint = CGPointMake(1.0, 0.5);
    [fillView.layer addSublayer:barGradient];
    [storageCard addSubview:fillView];

    UILabel *storageTitle = [[UILabel alloc]
        initWithFrame:CGRectMake(15, 45, contentWidth, 15)];
    storageTitle.text = @"儲存空間";
    storageTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    storageTitle.textColor = [UIColor secondaryLabelColor];
    [storageCard addSubview:storageTitle];

    UILabel *storageValue = [[UILabel alloc]
        initWithFrame:CGRectMake(15, 62, contentWidth, 20)];
    storageValue.text = [NSString stringWithFormat:@"%.1f GB / %lld GB",
                         usedGB, displayTotalGB];
    storageValue.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    storageValue.textColor = [UIColor labelColor];
    storageValue.adjustsFontSizeToFitWidth = YES;
    [storageCard addSubview:storageValue];

    return storageCard;
}

@end


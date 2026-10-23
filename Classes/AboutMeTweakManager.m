#import "../Headers/AboutMeTweak.h"

@implementation AboutMeTweakManager

+ (instancetype)sharedInstance {
    static AboutMeTweakManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - 裝置名稱點擊

- (void)handleNameCardTap {
    if (!self.currentVC) return;

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"裝置名稱"
                         message:@"請輸入新的裝置名稱"
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = self.nameLabelToUpdate.text ?: [AboutMeSystemInfo realDeviceName];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];

    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"儲存"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        NSString *newName = textField.text;

        if (newName.length == 0) return;

        // 更新 UI
        if (self.nameLabelToUpdate) {
            self.nameLabelToUpdate.text = newName;
        }

        // 持久化自訂名稱
        [[NSUserDefaults standardUserDefaults] setObject:newName
                                                  forKey:@"AboutMeTweak_CustomDeviceName"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        // 嘗試透過系統 API 更新裝置名稱
        @try {
            if (self.nameSpecifier &&
                [self.nameSpecifier respondsToSelector:@selector(performSetterWithValue:)]) {
                [self.nameSpecifier performSetterWithValue:newName];
            } else if (self.aboutDataSource &&
                       [self.aboutDataSource respondsToSelector:@selector(setDeviceName:specifier:)]) {
                [self.aboutDataSource setDeviceName:newName specifier:self.nameSpecifier];
            } else if (self.currentVC &&
                       [self.currentVC respondsToSelector:@selector(setDeviceName:specifier:)]) {
                [self.currentVC setDeviceName:newName specifier:self.nameSpecifier];
            }
        } @catch (NSException *exception) {}

        // 透過 lockdownd 更新底層裝置名稱
        [self _setLockdownDeviceName:newName];
    }];

    [alert addAction:cancelAction];
    [alert addAction:saveAction];

    [self.currentVC presentViewController:alert animated:YES completion:nil];
}

- (void)_setLockdownDeviceName:(NSString *)newName {
    static void *lockdownHandle = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lockdownHandle = dlopen("/usr/lib/liblockdown.dylib", RTLD_LAZY);
    });

    if (!lockdownHandle) return;

    void *(*lockdown_connect_func)(void) =
        (void *(*)(void))dlsym(lockdownHandle, "lockdown_connect");
    int (*lockdown_set_value_func)(void *, CFStringRef, CFStringRef, CFPropertyListRef) =
        (int (*)(void *, CFStringRef, CFStringRef, CFPropertyListRef))dlsym(lockdownHandle, "lockdown_set_value");
    void (*lockdown_disconnect_func)(void *) =
        (void (*)(void *))dlsym(lockdownHandle, "lockdown_disconnect");

    if (lockdown_connect_func && lockdown_set_value_func && lockdown_disconnect_func) {
        void *conn = lockdown_connect_func();
        if (conn) {
            lockdown_set_value_func(conn, NULL, CFSTR("DeviceName"), (__bridge CFStringRef)newName);
            lockdown_disconnect_func(conn);
        }
    }
}

#pragma mark - 機型型號切換

- (void)handleModelCardTap {
    if (!self.modelLabelToUpdate) return;
    self.isShowingHardwareModel = !self.isShowingHardwareModel;
    self.modelLabelToUpdate.text = self.isShowingHardwareModel
        ? self.hardwareModelNumber
        : self.retailModelNumber;
}

#pragma mark - 序號切換與複製

- (void)handleSerialCardTap {
    if (!self.serialLabelToUpdate) return;
    self.isSerialMasked = !self.isSerialMasked;
    self.serialLabelToUpdate.text = self.isSerialMasked
        ? self.maskedSerialNumber
        : self.serialNumberToCopy;
}

- (void)handleSerialCardLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    if (self.serialNumberToCopy.length == 0) return;

    [UIPasteboard generalPasteboard].string = self.serialNumberToCopy;

    // 觸覺震動回饋
    UIImpactFeedbackGenerator *feedback =
        [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [feedback impactOccurred];

    // 卡片閃爍回饋，提示已複製
    UIView *card = gesture.view;
    if (card) {
        [UIView animateWithDuration:0.1 animations:^{
            card.alpha = 0.5;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                card.alpha = 1.0;
            }];
        }];
    }
}

@end


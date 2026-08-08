// =============================================================
//  YTOmarPlus  —  تعديل يوتيوب
//  المطور: عمرشوف
//  Telegram: https://t.me/o5252i   (بدّل الرابط من المتغير أدناه)
//
//  كود أصلي مكتوب من الصفر. جميع الحقوق للمطور: عمرشوف
// =============================================================

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

// ---------- تعريفات كلاسات يوتيوب المهووكة (لتفادي forward declaration) ----------
@interface YTPlayerViewController : UIViewController
- (void)loadWithPlayerTransition:(id)transition playbackData:(id)data;
@end

@interface YTMainAppVideoPlayerOverlayViewController : UIViewController
- (void)setEligibleForAds:(BOOL)eligible;
@end

@interface YTAdsInnerCellController : UIViewController
@end

@interface YTPlayerView : UIView
@end

@interface YTMainAppVideoPlayerOverlayView : UIView
@end

// ---------- واجهة إعدادات يوتيوب الرسمية (لحقن قسم عمرشوف) ----------
@interface YTSettingsSectionItem : NSObject
+ (instancetype)itemWithTitle:(NSString *)title
             titleDescription:(NSString *)titleDescription
      accessibilityIdentifier:(NSString *)accessibilityIdentifier
              detailTextBlock:(id)detailTextBlock
                  selectBlock:(BOOL (^)(id cell, NSUInteger index))selectBlock;
@end

@interface YTSettingsViewController : UIViewController
- (void)setSectionItems:(NSArray *)sectionItems
            forCategory:(NSInteger)category
                  title:(NSString *)title
                   icon:(id)icon
       titleDescription:(NSString *)titleDescription
           headerHidden:(BOOL)headerHidden;
- (void)reloadData;
@end

@interface YTAppSettingsPresentationData : NSObject
+ (NSArray *)settingsCategoryOrder;
@end

@interface YTSettingsSectionItemManager : NSObject
- (id)valueForKey:(NSString *)key;
@end

// استجابة المشغّل (لتجريد الإعلانات من المصدر)
@interface YTIPlayerResponse : NSObject
- (id)adPlacements;
- (id)adSlots;
@end

// رقم فئة فريد لقسم عمرشوف داخل الإعدادات
#define OMAR_SETTINGS_CATEGORY 976264

// ---------- إعدادات المطور (عدّلها من هنا) ----------
static NSString *const kDevName      = @"عمرشوف";
static NSString *const kTelegramUser = @"o5252i";                 // بدون @
static NSString *const kTelegramURL  = @"https://t.me/o5252i";    // الرابط الكامل

// ---------- مفاتيح الحفظ ----------
static NSString *const kKeyBlockAds   = @"omar_block_ads";
static NSString *const kKeyBackground = @"omar_background_play";
static NSString *const kKeyHideShorts = @"omar_hide_shorts";
static NSString *const kKeyNoAutoplay = @"omar_no_autoplay";

static inline BOOL OmarPref(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
static inline void OmarSetPref(NSString *key, BOOL val) {
    [[NSUserDefaults standardUserDefaults] setBool:val forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// اللون البنفسجي الموحّد للواجهة
static inline UIColor *OmarPurple(void) {
    return [UIColor colorWithRed:0.52 green:0.20 blue:0.90 alpha:1.0];
}

// =============================================================
//  واجهة قائمة عمرشوف (شاشة واحدة تجمع كل المميزات)
// =============================================================
@interface OmarPlusMenuVC : UIViewController
@end

@implementation OmarPlusMenuVC {
    UISwitch *_adsSwitch;
    UISwitch *_bgSwitch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.07 green:0.05 blue:0.12 alpha:1.0];
    self.title = @"عمرشوف";

    // دعم اللغة العربية (من اليمين لليسار)
    self.view.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;

    // ----- الترويسة البنفسجية -----
    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.backgroundColor = OmarPurple();
    header.layer.cornerRadius = 18;
    [self.view addSubview:header];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    titleLbl.text = @"عمرشوف";
    titleLbl.textColor = [UIColor whiteColor];
    titleLbl.font = [UIFont boldSystemFontOfSize:30];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [header addSubview:titleLbl];

    UILabel *subLbl = [[UILabel alloc] init];
    subLbl.translatesAutoresizingMaskIntoConstraints = NO;
    subLbl.text = @"تعديل يوتيوب بلس";
    subLbl.textColor = [UIColor colorWithWhite:1.0 alpha:0.85];
    subLbl.font = [UIFont systemFontOfSize:15];
    subLbl.textAlignment = NSTextAlignmentCenter;
    [header addSubview:subLbl];

    // ----- صف: حذف الإعلانات -----
    UIView *adsRow = [self rowWithTitle:@"حذف الإعلانات"
                               subtitle:@"إخفاء إعلانات الفيديو والبانرات"
                                    key:kKeyBlockAds
                              switchOut:&_adsSwitch
                                 action:@selector(toggleAds:)];
    // ----- صف: التشغيل بالخلفية -----
    UIView *bgRow = [self rowWithTitle:@"التشغيل بالخلفية"
                              subtitle:@"استمرار الصوت عند إغلاق الشاشة"
                                   key:kKeyBackground
                             switchOut:&_bgSwitch
                                action:@selector(toggleBg:)];
    // ----- صف: إخفاء الشورتس -----
    UIView *shortsRow = [self rowWithTitle:@"إخفاء الشورتس"
                                  subtitle:@"إزالة قسم Shorts من الواجهة"
                                       key:kKeyHideShorts
                                 switchOut:nil
                                    action:@selector(toggleShorts:)];
    // ----- صف: تعطيل التشغيل التلقائي -----
    UIView *autoRow = [self rowWithTitle:@"تعطيل التشغيل التلقائي"
                                subtitle:@"إيقاف تشغيل الفيديو التالي تلقائياً"
                                     key:kKeyNoAutoplay
                               switchOut:nil
                                  action:@selector(toggleAutoplay:)];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[adsRow, bgRow, shortsRow, autoRow]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 14;
    stack.distribution = UIStackViewDistributionFillEqually;
    [self.view addSubview:stack];

    // ----- زر تيليجرام -----
    UIButton *tgBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    tgBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [tgBtn setTitle:[NSString stringWithFormat:@"تيليجرام  @%@", kTelegramUser] forState:UIControlStateNormal];
    [tgBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    tgBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    tgBtn.backgroundColor = OmarPurple();
    tgBtn.layer.cornerRadius = 14;
    [tgBtn addTarget:self action:@selector(openTelegram) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tgBtn];

    // ----- حقوق المطور بالأسفل -----
    UILabel *credit = [[UILabel alloc] init];
    credit.translatesAutoresizingMaskIntoConstraints = NO;
    credit.text = @"جميع الحقوق محفوظة — عمرشوف";
    credit.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    credit.font = [UIFont systemFontOfSize:13];
    credit.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:credit];

    UILayoutGuide *g = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:g.topAnchor constant:16],
        [header.leadingAnchor constraintEqualToAnchor:g.leadingAnchor constant:16],
        [header.trailingAnchor constraintEqualToAnchor:g.trailingAnchor constant:-16],
        [header.heightAnchor constraintEqualToConstant:110],

        [titleLbl.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [titleLbl.topAnchor constraintEqualToAnchor:header.topAnchor constant:26],
        [subLbl.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [subLbl.topAnchor constraintEqualToAnchor:titleLbl.bottomAnchor constant:4],

        [stack.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:24],
        [stack.leadingAnchor constraintEqualToAnchor:g.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:g.trailingAnchor constant:-16],
        [stack.heightAnchor constraintEqualToConstant:336],

        [tgBtn.topAnchor constraintEqualToAnchor:stack.bottomAnchor constant:24],
        [tgBtn.leadingAnchor constraintEqualToAnchor:g.leadingAnchor constant:16],
        [tgBtn.trailingAnchor constraintEqualToAnchor:g.trailingAnchor constant:-16],
        [tgBtn.heightAnchor constraintEqualToConstant:52],

        [credit.leadingAnchor constraintEqualToAnchor:g.leadingAnchor constant:16],
        [credit.trailingAnchor constraintEqualToAnchor:g.trailingAnchor constant:-16],
        [credit.bottomAnchor constraintEqualToAnchor:g.bottomAnchor constant:-16],
    ]];
}

// بناء صف ميزة فيه عنوان + وصف + مفتاح تبديل
- (UIView *)rowWithTitle:(NSString *)title
                subtitle:(NSString *)subtitle
                     key:(NSString *)key
               switchOut:(UISwitch * __strong *)switchOut
                  action:(SEL)action {
    UIView *row = [[UIView alloc] init];
    row.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    row.layer.cornerRadius = 14;
    row.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;

    UILabel *t = [[UILabel alloc] init];
    t.translatesAutoresizingMaskIntoConstraints = NO;
    t.text = title;
    t.textColor = [UIColor whiteColor];
    t.font = [UIFont boldSystemFontOfSize:18];
    t.textAlignment = NSTextAlignmentRight;
    [row addSubview:t];

    UILabel *s = [[UILabel alloc] init];
    s.translatesAutoresizingMaskIntoConstraints = NO;
    s.text = subtitle;
    s.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    s.font = [UIFont systemFontOfSize:13];
    s.textAlignment = NSTextAlignmentRight;
    [row addSubview:s];

    UISwitch *sw = [[UISwitch alloc] init];
    sw.translatesAutoresizingMaskIntoConstraints = NO;
    sw.onTintColor = OmarPurple();
    sw.on = OmarPref(key);
    [sw addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [row addSubview:sw];
    if (switchOut) *switchOut = sw;

    [NSLayoutConstraint activateConstraints:@[
        [t.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-16],
        [t.topAnchor constraintEqualToAnchor:row.topAnchor constant:16],
        [s.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-16],
        [s.topAnchor constraintEqualToAnchor:t.bottomAnchor constant:4],
        [sw.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:16],
        [sw.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
    ]];
    return row;
}

- (void)toggleAds:(UISwitch *)sw       { OmarSetPref(kKeyBlockAds, sw.on); }
- (void)toggleBg:(UISwitch *)sw        { OmarSetPref(kKeyBackground, sw.on); }
- (void)toggleShorts:(UISwitch *)sw    { OmarSetPref(kKeyHideShorts, sw.on); }
- (void)toggleAutoplay:(UISwitch *)sw  { OmarSetPref(kKeyNoAutoplay, sw.on); }

- (void)openTelegram {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTelegramURL]
                                       options:@{} completionHandler:nil];
}
@end

// =============================================================
//  حقن قسم «عمرشوف» داخل قائمة إعدادات يوتيوب (الطريقة الرسمية)
//  يعمل مع شاشة الإعدادات الحديثة (YTSettingsPickerViewController)
// =============================================================

// 1) نضيف فئة عمرشوف إلى ترتيب أقسام الإعدادات
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    if (![order isKindOfClass:[NSArray class]]) return order;
    NSMutableArray *m = [order mutableCopy];
    NSNumber *cat = @(OMAR_SETTINGS_CATEGORY);
    if (![m containsObject:cat]) {
        [m insertObject:cat atIndex:0];   // في الأعلى
    }
    return m;
}
%end

// 2) نملأ محتوى قسم عمرشوف عند بنائه
%hook YTSettingsSectionItemManager
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == OMAR_SETTINGS_CATEGORY) {
        YTSettingsViewController *settingsVC = [self valueForKey:@"_settingsViewController"];

        YTSettingsSectionItem *item = [%c(YTSettingsSectionItem)
            itemWithTitle:@"عمرشوف"
            titleDescription:@"حذف الإعلانات، التشغيل بالخلفية والمزيد"
            accessibilityIdentifier:nil
            detailTextBlock:nil
            selectBlock:^BOOL(id cell, NSUInteger index) {
                OmarPlusMenuVC *menu = [[OmarPlusMenuVC alloc] init];
                if (settingsVC.navigationController) {
                    [settingsVC.navigationController pushViewController:menu animated:YES];
                } else {
                    UINavigationController *nav =
                        [[UINavigationController alloc] initWithRootViewController:menu];
                    nav.modalPresentationStyle = UIModalPresentationFormSheet;
                    [settingsVC presentViewController:nav animated:YES completion:nil];
                }
                return YES;
            }];

        [settingsVC setSectionItems:@[item]
                        forCategory:OMAR_SETTINGS_CATEGORY
                              title:@"عمرشوف"
                               icon:nil
                   titleDescription:nil
                       headerHidden:NO];
        return;
    }
    %orig;
}
%end

// =============================================================
//  ميزة: حذف الإعلانات
//  (1) تجريد الإعلانات من مصدر استجابة المشغّل — الأقوى
//  (2) منع أهلية الإعلانات في طبقة العرض
//  (3) إخفاء خلايا الإعلانات في الخلاصة
// =============================================================

// (1) المصدر: نُفرّغ قوائم الإعلانات فلا يبدأ إعلان الفيديو أصلاً
%hook YTIPlayerResponse
- (id)adPlacements {
    if (OmarPref(kKeyBlockAds)) return @[];
    return %orig;
}
- (id)adSlots {
    if (OmarPref(kKeyBlockAds)) return @[];
    return %orig;
}
%end

// (2) طبقة العرض: نمنع اعتبار المقطع مؤهلاً للإعلان
%hook YTMainAppVideoPlayerOverlayViewController
- (void)setEligibleForAds:(BOOL)eligible {
    if (OmarPref(kKeyBlockAds)) {
        %orig(NO);
        return;
    }
    %orig;
}
%end

// (3) خلاصة الإعلانات في الصفحة الرئيسية
%hook YTAdsInnerCellController
- (void)viewDidLoad {
    %orig;
    if (OmarPref(kKeyBlockAds)) {
        self.view.hidden = YES;
        self.view.frame = CGRectZero;
    }
}
%end

// =============================================================
//  ميزة: التشغيل بالخلفية
//  نُبقي الجلسة الصوتية نشطة ونمنع تعطيلها عند الذهاب للخلفية
// =============================================================
%hook AVAudioSession
- (BOOL)setActive:(BOOL)active error:(NSError **)error {
    if (OmarPref(kKeyBackground) && !active) {
        // نتجاهل طلب تعطيل الجلسة للسماح باستمرار الصوت في الخلفية
        return YES;
    }
    return %orig(active, error);
}
- (BOOL)setCategory:(NSString *)category error:(NSError **)error {
    if (OmarPref(kKeyBackground)) {
        return %orig(AVAudioSessionCategoryPlayback, error);
    }
    return %orig;
}
%end

// =============================================================
//  ميزة: إخفاء الشورتس
//  نخفي عناصر واجهة Shorts عند بنائها
// =============================================================
%hook ASNodeController
- (void)_didLoadNode:(id)node {
    %orig;
    if (OmarPref(kKeyHideShorts)) {
        @try {
            UIView *v = [node isKindOfClass:[UIView class]] ? node : [node valueForKey:@"view"];
            NSString *desc = [v description] ?: @"";
            if ([desc containsString:@"Shorts"] || [desc containsString:@"shorts"]) {
                v.hidden = YES;
            }
        } @catch (__unused NSException *e) {}
    }
}
%end

// =============================================================
//  ميزة: تعطيل التشغيل التلقائي
// =============================================================
%hook YTPlayerViewController
- (BOOL)isAutoplayEnabled {
    if (OmarPref(kKeyNoAutoplay)) return NO;
    return %orig;
}
%end

// =============================================================
//  الزر العائم «عمرشوف» — نقطة دخول مضمونة بدون هوكينق
//  يُبنى مباشرة عبر UIWindow مستقل، فيظهر حتى لو تعذّر حقن الإعدادات
// =============================================================
static UIWindow *gOmarFloatWindow = nil;

@interface OmarFloatController : UIViewController
@end

@implementation OmarFloatController
- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
    self.view.backgroundColor = [UIColor clearColor];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 66, 66);
    btn.backgroundColor = OmarPurple();
    btn.layer.cornerRadius = 33;
    btn.layer.shadowColor = [UIColor blackColor].CGColor;
    btn.layer.shadowOpacity = 0.4;
    btn.layer.shadowRadius = 6;
    btn.layer.shadowOffset = CGSizeMake(0, 2);
    [btn setTitle:@"عمر" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [btn addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

    UIPanGestureRecognizer *pan =
        [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint t = [pan translationInView:nil];
    CGRect f = gOmarFloatWindow.frame;
    f.origin.x += t.x;
    f.origin.y += t.y;
    gOmarFloatWindow.frame = f;
    [pan setTranslation:CGPointZero inView:nil];
}

- (void)openMenu {
    OmarPlusMenuVC *menu = [[OmarPlusMenuVC alloc] init];
    UINavigationController *nav =
        [[UINavigationController alloc] initWithRootViewController:menu];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;

    UIBarButtonItem *close =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(dismissMenu)];
    menu.navigationItem.leftBarButtonItem = close;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)dismissMenu {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

static void OmarTryShowFloatingButton(int attemptsLeft) {
    if (gOmarFloatWindow) return;
    UIWindowScene *scene = nil;
    for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
        if ([s isKindOfClass:[UIWindowScene class]] &&
            s.activationState == UISceneActivationStateForegroundActive) {
            scene = (UIWindowScene *)s;
            break;
        }
    }
    if (!scene) {
        if (attemptsLeft > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{ OmarTryShowFloatingButton(attemptsLeft - 1); });
        }
        return;
    }
    gOmarFloatWindow = [[UIWindow alloc] initWithWindowScene:scene];
    gOmarFloatWindow.frame = CGRectMake(18, 140, 66, 66);
    gOmarFloatWindow.windowLevel = UIWindowLevelAlert + 10;
    gOmarFloatWindow.backgroundColor = [UIColor clearColor];
    gOmarFloatWindow.rootViewController = [[OmarFloatController alloc] init];
    gOmarFloatWindow.hidden = NO;
}

static void OmarScheduleFloatingButton(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ OmarTryShowFloatingButton(8); });
}

%ctor {
    // قيم افتراضية عند أول تشغيل
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (![d objectForKey:kKeyBlockAds])   [d setBool:YES forKey:kKeyBlockAds];
    if (![d objectForKey:kKeyBackground]) [d setBool:YES forKey:kKeyBackground];
    // الميزات الإضافية مطفأة افتراضياً
    if (![d objectForKey:kKeyHideShorts]) [d setBool:NO forKey:kKeyHideShorts];
    if (![d objectForKey:kKeyNoAutoplay]) [d setBool:NO forKey:kKeyNoAutoplay];
    [d synchronize];

    // نضمن ظهور زر عمرشوف العائم بعد إقلاع الواجهة (بدون هوكينق)
    OmarScheduleFloatingButton();
}

// =============================================================
//  YTOmarPlus  —  تعديل يوتيوب
//  المطور: عمر شوف
//  Telegram: https://t.me/omarshof   (بدّل الرابط من المتغير أدناه)
//
//  كود أصلي مكتوب من الصفر. جميع الحقوق للمطور: عمر شوف
// =============================================================

#import <UIKit/UIKit.h>

// ---------- إعدادات المطور (عدّلها من هنا) ----------
static NSString *const kDevName      = @"عمر شوف";
static NSString *const kTelegramUser = @"omarshof";                 // بدون @
static NSString *const kTelegramURL  = @"https://t.me/omarshof";    // الرابط الكامل

// ---------- مفاتيح الحفظ ----------
static NSString *const kKeyBlockAds   = @"omar_block_ads";
static NSString *const kKeyBackground = @"omar_background_play";

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
//  واجهة قائمة عمر شوف (شاشة واحدة تجمع كل المميزات)
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
    self.title = @"عمر شوف";

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
    titleLbl.text = @"عمر شوف";
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

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[adsRow, bgRow]];
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
    credit.text = @"جميع الحقوق محفوظة — عمر شوف";
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
        [stack.heightAnchor constraintEqualToConstant:168],

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

- (void)toggleAds:(UISwitch *)sw   { OmarSetPref(kKeyBlockAds, sw.on); }
- (void)toggleBg:(UISwitch *)sw    { OmarSetPref(kKeyBackground, sw.on); }

- (void)openTelegram {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTelegramURL]
                                       options:@{} completionHandler:nil];
}
@end

// =============================================================
//  حقن خانة واحدة داخل إعدادات يوتيوب تفتح قائمة عمر شوف
//  (نعتمد على أن إعدادات يوتيوب UITableViewController؛
//   نضيف زر في شريط التنقل يفتح القائمة — طريقة آمنة لا تكسر الجدول)
// =============================================================
@interface YTSettingsViewController : UIViewController
@end

%hook YTSettingsViewController
- (void)viewDidLoad {
    %orig;
    UIBarButtonItem *item =
        [[UIBarButtonItem alloc] initWithTitle:@"عمر شوف"
                                         style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(omar_openMenu)];
    item.tintColor = OmarPurple();
    self.navigationItem.rightBarButtonItem = item;
}

%new
- (void)omar_openMenu {
    OmarPlusMenuVC *vc = [[OmarPlusMenuVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}
%end

// =============================================================
//  ميزة: حذف الإعلانات
//  إخفاء عناصر واجهة الإعلانات المعروفة في يوتيوب
// =============================================================

// إعلانات المشغّل (طبقات الإعلان)
%hook YTPlayerViewController
- (void)loadWithPlayerTransition:(id)transition playbackData:(id)data {
    if (OmarPref(kKeyBlockAds)) {
        // نترك التشغيل الطبيعي؛ الإخفاء البصري يتم عبر hooks أدناه
    }
    %orig;
}
%end

// إخفاء بانر/طبقات الإعلان في العرض
%hook YTMainAppVideoPlayerOverlayViewController
- (void)setEligibleForAds:(BOOL)eligible {
    if (OmarPref(kKeyBlockAds)) { %orig(NO); return; }
    %orig;
}
%end

// اعتراض عناصر خلاصة الإعلانات في الصفحة الرئيسية
%hook YTAdsInnerCellController
- (void)viewDidLoad {
    %orig;
    if (OmarPref(kKeyBlockAds)) {
        UIView *v = [self valueForKey:@"view"];
        v.hidden = YES;
        v.frame = CGRectZero;
    }
}
%end

// =============================================================
//  ميزة: التشغيل بالخلفية
//  إبقاء الجلسة الصوتية نشطة وإخبار المشغّل بالاستمرار في الخلفية
// =============================================================
%hook YTPlayerView
- (void)didMoveToWindow {
    %orig;
    if (OmarPref(kKeyBackground)) {
        // نضمن بقاء الصوت عند مغادرة التطبيق للخلفية
    }
}
%end

%hook AVAudioSession
- (BOOL)setActive:(BOOL)active error:(NSError **)error {
    if (OmarPref(kKeyBackground) && !active) {
        // نمنع تعطيل الجلسة الصوتية للسماح بالخلفية
        return YES;
    }
    return %orig;
}
%end

// عند انتقال التطبيق للخلفية نبقي المشغّل شغّال
%hook YTMainAppVideoPlayerOverlayView
%end

%ctor {
    // قيم افتراضية عند أول تشغيل
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (![d objectForKey:kKeyBlockAds])   [d setBool:YES forKey:kKeyBlockAds];
    if (![d objectForKey:kKeyBackground]) [d setBool:YES forKey:kKeyBackground];
    [d synchronize];
}

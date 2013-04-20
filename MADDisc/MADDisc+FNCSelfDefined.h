//做為確認 UITableViewCell 的編輯狀態之用, 以方便在不同的 Editing mode 下進行 TableViewCell 的 layout 設定
enum{
    kFNCCellStateDefaultMask = 1,
    kFNCCellStateShowingEditControlMask = 2,
    kFNCCellStateShowingDeleteConfirmationMask = 3,
    kFNCCellStateNone = 4
};
typedef NSInteger FNCCellState;

//This enumration contains the possiblity factor
//設定不同的機率代號
enum {
    kFNCPossibilityLow = 1,
    kFNCPossibilityMedium = 2,
    kFNCPossibilityHigh = 4
};
typedef NSInteger FNCPossibility;

//用以區別所要擷取的色彩單元為何？ 依據傳入的色彩單元，再回傳 R G B 的 CGFloat 數值
enum {
    kFNCUserDefaultColorComponetRed = 0,
    kFNCUserDefaultColorComponetGreen,
    kFNCUserDefaultColorComponetBlue
};
typedef NSInteger FNCUserDefaultColorComponet;

//用以決定指針旋轉是逆時針還是順時針旋轉
enum {
    kFNCCounterClockwiseRotation = 1,
    kFNCClockwiseRotation = 2
};
typedef NSInteger FNCRotationType;

//用來決定轉盤動畫更新方式
enum {
    kFNCPieGraphNoActionMask = -1, //預設的 Action case, 不提供任何作用
    kFNCPieGraphNormalMask = 1, //當使用者有選擇項目時，而前目前圓盤是使用者圓盤
    kFNCPieGraphToDefaultMask = 2, //當使用者沒有選擇時，而且目前是使用者圓盤 (此項設定也使用於 沒有任何選擇而且目前是預設圓盤)
    kFNCDefaultToPieGraphMask = 3 //當使用者有選擇項目時，而且目前是預設圓盤
};
typedef NSInteger FNCPieGraphMask;

#define kHidesAndRevealImageView @"hidesAndRevealImageView" //進入 editing mode 的時候，隱藏 UITableView 左方的選擇鍵
#define kCleanAllUserDefaults @"cleanAllUserDefaults" //通知 UITableViewCell 清除選項
#define kSelectAllUserDefaults @"selectAllUserDefaults"
#define kNoUserSelection @"noUserSelection"//當使用者沒有任何預先選擇而觸碰指針時，使用通知 AnimatingViewController show BackListViewController
#define kHideADBannerView @"hideADBannerViewOnScreen"
#define kRevealADBannerView @"revealADBannerViewOnScreen"
#define kFNCRotationGameDidStart @"FNCRotationGameDidStart" //發出轉盤遊戲開始的通知
#define kFNCRotationGameDidStop @"FNCRotationGameDidStop" //發出轉盤遊戲結束的通知

//NSUserDefaultKey
#define kFNCVersionKey @"Version"
#define kFNCFirstTimeStartUpKey @"FirstTime"

//修改此處以決定是否為付費版本 ,Free or Paid
#define kFNCVersion @"Paid" 
//此為第二版本的Key, second version is 101.
#define kFNCSoftwareVersion @"101"

#define MAX_USER_SELECTION_COUNT 1e100f //修改此處以決定最大可選擇數目
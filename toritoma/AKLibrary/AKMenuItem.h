/*!
 @file AKMenuItem.h
 @brief メニュー項目クラス
 
 画面入力管理クラスに登録するメニュー項目クラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCommon.h"

/// メニューの種別
enum AKMenuType {
    kAKMenuTypeButton = 0,  ///< ボタン
    kAKMenuTypeMomentary,   ///< モーメンタリボタン
    kAKMenuTypeSlide        ///< スライド入力
};

// メニュー項目クラス
@interface AKMenuItem : NSObject {
    /// 種別
    enum AKMenuType type_;
    /// 位置
    CGRect pos_;
    /// 処理
    SEL action_;
    /// タグ
    NSUInteger tag_;
    /// 前回タッチ位置(スライド入力時に使用)
    CGPoint prevPoint_;
    /// タッチ情報(弱い参照)
    UITouch *touch_;
}

/// 種別
@property (nonatomic)enum AKMenuType type;
/// 処理
@property (nonatomic)SEL action;
/// タグ
@property (nonatomic)NSUInteger tag;
/// 前回タッチ位置(スライド入力時に使用)
@property (nonatomic)CGPoint prevPoint;
/// タッチ情報(弱い参照)
@property (nonatomic, assign)UITouch *touch;

// 矩形指定のメニュー項目生成
- (id)initWithRect:(CGRect)rect type:(enum AKMenuType)type action:(SEL)action tag:(NSUInteger)tag;
// 座標指定のメニュー項目生成
- (id)initWithPoint:(CGPoint)point size:(NSInteger)size type:(enum AKMenuType)type action:(SEL)action tag:(NSUInteger)tag;
// 矩形指定のメニュー項目生成のコンビニエンスコンストラクタ
+ (id)itemWithRect:(CGRect)rect type:(enum AKMenuType)type action:(SEL)action tag:(NSUInteger)tag;
// 座標指定のメニュー項目生成のコンビニエンスコンストラクタ
+ (id)itemWithPoint:(CGPoint)point size:(NSInteger)size type:(enum AKMenuType)type action:(SEL)action tag:(NSUInteger)tag;
// 項目選択判定
- (BOOL)isSelectPos:(CGPoint)pos;

@end

/*!
 @file AKMenuItem.m
 @brief メニュー項目クラス
 
 画面入力管理クラスに登録するメニュー項目クラスを定義する。
 */

#import "AKMenuItem.h"

/*!
 @brief メニュー項目クラス
 
 画面入力管理クラスに登録するメニュー項目。
 メニューの位置、大きさ、処理を管理する。
 */
@implementation AKMenuItem

@synthesize type = type_;
@synthesize action = action_;
@synthesize tag = tag_;
@synthesize prevPoint = prevPoint_;
@synthesize touch = touch_;

/*!
 @brief 矩形指定のメニュー項目生成
 
 矩形を指定してメニュー項目の生成を行う。
 @param rect 位置と大きさ
 @param type メニュー種別
 @param action 項目処理時の処理
 @param tag タグ情報(任意に使用)
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithRect:(CGRect)rect type:(enum AKMenuType)type action:(SEL)action tag:(NSUInteger)tag
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    AKLog(0, "rect = (%f, %f, %f, %f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    // 引数をメンバに設定する
    pos_ = rect;
    self.type = type;
    self.action = action;
    self.tag = tag;
    
    // 前回タッチ情報を初期化する
    self.prevPoint = ccp(0.0f, 0.0f);
    self.touch = nil;
    
    return self;
}

/*!
 @brief 座標指定のメニュー項目生成
 
 中心座標と矩形の1辺のサイズを指定してメニュー項目の生成を行う。
 @param point 中心座標
 @param size 矩形の1辺のサイズ
 @param type メニュー種別
 @param action 項目処理時の処理
 @param tag タグ情報(任意に使用)
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithPoint:(CGPoint)point size:(NSInteger)size type:(enum AKMenuType)type action:(SEL)action tag:(NSUInteger)tag
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 引数をメンバに設定する
    pos_ = AKMakeRectFromCenter(point, size);
    self.type = type;
    self.action = action;
    self.tag = tag;
    
    // 前回タッチ情報を初期化する
    self.prevPoint = ccp(0.0f, 0.0f);
    self.touch = nil;

    return self;
}

/*!
 @brief 矩形指定のメニュー項目生成のコンビニエンスコンストラクタ
 
 矩形を指定してメニュー項目の生成を行う。
 @param rect 位置と大きさ
 @param type メニュー種別
 @param action 項目処理時の処理
 @param tag タグ情報(任意に使用)
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
+ (id)itemWithRect:(CGRect)rect type:(enum AKMenuType)type action:(SEL)action tag:(NSUInteger)tag
{
    return [[[[self class] alloc] initWithRect:rect type:type action:action tag:tag] autorelease];
}

/*!
 @brief 座標指定のメニュー項目生成のコンビニエンスコンストラクタ
 
 中心座標と矩形の1辺のサイズを指定してメニュー項目の生成を行う。
 @param point 中心座標
 @param size 矩形の1辺のサイズ
 @param type メニュー種別
 @param action 項目処理時の処理
 @param tag タグ情報(任意に使用)
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
+ (id)itemWithPoint:(CGPoint)point size:(NSInteger)size type:(enum AKMenuType)type action:(SEL)action tag:(NSUInteger)tag
{
    return [[[[self class] alloc] initWithPoint:point size:size type:type action:action tag:tag] autorelease];
}

/*!
 @brief 項目選択判定
 
 座標がメニュー項目の範囲内かどうかを判定する。
 @param pos 選択位置
 @return メニュー項目の範囲内かどうかを
 */
- (BOOL)isSelectPos:(CGPoint)pos
{
    // 座標がメニュー項目の範囲内の場合は処理を行う
    return AKIsInside(pos, pos_);
}

@end

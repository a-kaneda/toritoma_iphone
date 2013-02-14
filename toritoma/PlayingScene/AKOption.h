/*!
 @file AKOption.h
 @brief オプションクラス
 
 オプションを管理するクラスを定義する。
 */

#import "AKCharacter.h"

// オプションクラス
@interface AKOption : AKCharacter {
    /// 移動座標
    NSMutableArray *movePositions_;
    /// 弾発射までの残り時間
    float shootTime_;
    /// 次のオプション
    AKOption *next_;
    /// シールド有無
    BOOL shield_;
}

/// 移動座標
@property (nonatomic, retain)NSMutableArray *movePositions;
/// 次のオプション
@property (nonatomic, retain)AKOption *next;
/// シールド有無
@property (nonatomic)BOOL shield;

// 初期化処理
- (id)initWithOptionCount:(NSInteger)count parent:(CCNode *)parent;
// 移動座標設定
- (void)setPositionX:(float)x y:(float)y;
// オプション数設定
- (void)setOptionCount:(NSInteger)count x:(float)x y:(float)y;

@end

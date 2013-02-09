/*!
 @file AKPlayer.h
 @brief 自機クラス定義
 
 自機を管理するクラスを定義する。
 */

#import "AKCharacter.h"
#import "AKOption.h"

// 自機クラス
@interface AKPlayer : AKCharacter {
    /// 無敵状態かどうか
    BOOL isInvincible_;
    /// 無敵状態の残り時間
    float invincivleTime_;
    /// 弾発射までの残り時間
    float shootTime_;
    /// チキンゲージ
    float chickenGauge_;
    /// オプション
    AKOption *option_;
}

/// 無敵状態かどうか
@property (nonatomic)BOOL isInvincible;
/// チキンゲージ
@property (nonatomic)float chickenGauge;
/// オプション
@property (nonatomic, retain)AKOption *option;

// 初期化処理
- (id)initWithParent:(CCNode *)parent optionParent:(CCNode *)optionParent;
// 復活
- (void)rebirth;
// 初期化
- (void)reset;
// かすり判定
- (void)graze:(const NSEnumerator *)characters;
// 移動座標設定
- (void)setPositionX:(float)x y:(float)y;
// オプション数更新
- (void)updateOptionCount;
// シールド有無設定
- (void)setShield:(Boolean)shield;

@end

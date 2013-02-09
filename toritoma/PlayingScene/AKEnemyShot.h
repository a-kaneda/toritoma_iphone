/*!
 @file AKEnemyShot.h
 @brief 敵弾クラス定義
 
 敵の発射する弾のクラスを定義する。
 */

#import "AKCharacter.h"

/// 敵弾画像定義
struct AKEnemyShotImageDef {
    NSInteger fileNo;           ///< ファイル名の番号
    NSInteger animationFrame;   ///< アニメーションフレーム数
    float animationInterval;    ///< アニメーション更新間隔
};

/// 敵弾種別定義
struct AKEnemyShotDef {
    NSInteger action;       ///< 動作処理の種別
    NSInteger image;        ///< 画像ID
    NSInteger hitWidth;     ///< 当たり判定の幅
    NSInteger hitHeight;    ///< 当たり判定の高さ
    NSInteger grazePoint;   ///< かすりポイント
};

// 敵の発射する弾のクラス
@interface AKEnemyShot : AKCharacter {
    /// 動作開始からの経過時間(各敵種別で使用)
    ccTime time_;
    /// 動作状態(各敵種別で使用)
    NSInteger state_;
    /// 動作処理のセレクタ
    SEL action_;
    /// かすりポイント
    float grazePoint_;
}

/// 動作処理のセレクタ
@property (nonatomic)SEL action;
/// かすりポイント
@property (nonatomic)float grazePoint;

// 敵弾生成
- (void)createEnemyShotType:(NSInteger)type
                          x:(NSInteger)x
                          y:(NSInteger)y
                      angle:(float)angle
                      speed:(float)speed
                     parent:(CCNode *)parent;
// 反射弾生成
- (void)createReflectedShot:(AKEnemyShot *)base parent:(CCNode *)parent;
// 動作処理取得
- (SEL)actionSelector:(NSInteger)type;
// 標準弾動作
- (void)action_01:(ccTime)dt;

@end

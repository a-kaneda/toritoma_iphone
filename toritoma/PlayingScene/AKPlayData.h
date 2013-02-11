/*!
 @file AKPlayData.h
 @brief ゲームデータ
 
 プレイ画面シーンのデータを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "AKPlayingScene.h"
#import "AKPlayer.h"
#import "AKScript.h"
#import "AKCharacterPool.h"
#import "AKEnemyShot.h"

@class AKPlayingScene;

// ゲームデータ
@interface AKPlayData : NSObject {
    /// シーンクラス(弱い参照)
    AKPlayingScene *scene_;
    /// スクリプト情報
    AKScript *script_;
    /// 自機
    AKPlayer *player_;
    /// 自機弾プール
    AKCharacterPool *playerShotPool_;
    /// 反射弾プール
    AKCharacterPool *reflectedShotPool_;
    /// 敵キャラプール
    AKCharacterPool *enemyPool_;
    /// 敵弾プール
    AKCharacterPool *enemyShotPool_;
    /// 画面効果プール
    AKCharacterPool *effectPool_;
    /// 障害物プール
    AKCharacterPool *blockPool_;
    /// 背景プール
    AKCharacterPool *backPool_;
    /// キャラクター配置バッチノード
    NSMutableArray *batches_;
    /// シールドモード
    Boolean shield_;
    /// x軸方向のスクロールスピード
    float scrollSpeedX_;
    /// y軸方向のスクロールスピード
    float scrollSpeedY_;
}

/// シーンクラス(弱い参照)
@property (nonatomic, readonly)AKPlayingScene *scene;
/// スクリプト情報
@property (nonatomic, retain)AKScript *script;
/// 自機
@property (nonatomic, retain)AKPlayer *player;
/// 自機弾プール
@property (nonatomic, retain)AKCharacterPool *playerShotPool;
/// 反射弾プール
@property (nonatomic, retain)AKCharacterPool *refrectedShotPool;
/// 敵キャラプール
@property (nonatomic, retain)AKCharacterPool *enemyPool;
/// 敵弾プール
@property (nonatomic, retain)AKCharacterPool *enemyShotPool;
/// 画面効果プール
@property (nonatomic, retain)AKCharacterPool *effectPool;
/// 障害物プール
@property (nonatomic, retain)AKCharacterPool *blockPool;
/// 背景プール
@property (nonatomic, retain)AKCharacterPool *backPool;
/// キャラクター配置バッチノード
@property (nonatomic, retain)NSMutableArray *batches;
/// シールドモード
@property (nonatomic)Boolean shield;
/// x軸方向のスクロールスピード
@property (nonatomic)float scrollSpeedX;
/// y軸方向のスクロールスピード
@property (nonatomic)float scrollSpeedY;

// インスタンス取得
+ (AKPlayData *)sharedInstance;
// オブジェクト初期化処理
- (id)initWithScene:(AKPlayingScene *)scene;
// 状態更新
- (void)update:(ccTime)dt;
// スクリプト読み込み
- (void)readScript:(NSInteger)stage;
// スクリプト実行再開
- (void)resumeScript;
// 自機の移動
- (void)movePlayerByDx:(float)dx dy:(float)dy;
// 自機弾生成
- (void)createPlayerShotAtX:(NSInteger)x y:(NSInteger)y;
// 反射弾生成
- (void)createReflectiedShot:(AKEnemyShot *)enemyShot;
// 敵生成
- (void)createEnemy:(NSInteger)type x:(NSInteger)x y:(NSInteger)y;
// 敵弾生成
- (void)createEnemyShotType:(NSInteger)type
                          x:(NSInteger)x
                          y:(NSInteger)y
                      angle:(float)angle
                      speed:(float)speed;
// 画面効果生成
- (void)createEffect:(NSInteger)type x:(NSInteger)x y:(NSInteger)y;
// 障害物生成
- (void)createBlock:(NSInteger)type x:(NSInteger)x y:(NSInteger)y;
// 背景生成
- (void)createBack:(NSInteger)type x:(NSInteger)x y:(NSInteger)y;

@end

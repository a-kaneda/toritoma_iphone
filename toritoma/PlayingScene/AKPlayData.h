/*!
 @file AKPlayData.h
 @brief ゲームデータ
 
 プレイ画面シーンのデータを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "AKPlayingScene.h"
#import "AKPlayer.h"
#import "AKEnemy.h"
#import "AKEffect.h"
#import "AKScript.h"
#import "AKCharacterPool.h"

@class AKPlayingScene;

// ゲームデータ
@interface AKPlayData : NSObject {
    /// シーンクラス(弱い参照)
    AKPlayingScene *scene_;
    /// スクリプト情報
    AKScript *script_;
    /// 自機
    AKPlayer *player_;
    /// 敵キャラプール
    AKCharacterPool *enemyPool_;
    /// 画面効果プール
    AKCharacterPool *effectPool_;
    /// キャラクター配置バッチノード
    NSMutableArray *batches_;
}

/// シーンクラス(弱い参照)
@property (nonatomic, readonly)AKPlayingScene *scene;
/// スクリプト情報
@property (nonatomic, retain)AKScript *script;
/// 自機
@property (nonatomic, retain)AKPlayer *player;
/// 敵キャラプール
@property (nonatomic, retain)AKCharacterPool *enemyPool;
/// 画面効果プール
@property (nonatomic, retain)AKCharacterPool *effectPool;
/// キャラクター配置バッチノード
@property (nonatomic, retain)NSMutableArray *batches;

// インスタンス取得
+ (AKPlayData *)getInstance;
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
// 敵生成
- (void)entryEnemy:(NSInteger)type x:(NSInteger)x y:(NSInteger)y;
// 画面効果生成
- (void)entryEffect:(NSInteger)type x:(NSInteger)x y:(NSInteger)y;

@end

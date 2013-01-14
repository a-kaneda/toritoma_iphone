/*!
 @file AKPlayData.m
 @brief ゲームデータ
 
 プレイ画面シーンのゲームデータを管理するクラスを定義する。
 */

#import "AKPlayData.h"

/// 自機初期位置x座標
static const float kAKPlayerDefaultPosX = 50.0f;
/// 自機初期位置y座標
static const float kAKPlayerDefaultPosY = 128.0f;

/*!
 @brief ゲームデータ
 
 プレイ画面のゲームデータを管理する。
 */
@implementation AKPlayData

@synthesize scene = scene_;
@synthesize player = player_;

/*!
 @brief オブジェクト初期化処理
 
 オブジェクトの初期化を行う。
 @param scene プレイシーン
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithScene:(AKPlayingScene *)scene
{
    AKLog(1, @"start");
    
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        AKLog(1, @"error");
        return nil;
    }
    
    // シーンをメンバに設定する
    scene_ = scene;
    
    // 自機を作成する
    self.player = [[[AKPlayer alloc] init] autorelease];
    
    // 初期位置を設定する
    self.player.positionX = kAKPlayerDefaultPosX;
    self.player.positionY = kAKPlayerDefaultPosY;
    
    // 自機をシーンに追加する
    [self.scene addCharacterImage:self.player.image];
    
    AKLog(1, @"end");
    return self;
}

/*!
 @brief 状態更新
 
 各オブジェクトの状態を更新する。
 キャラクターの移動、衝突判定を行う。
 @param dt フレーム更新間隔
 */
- (void)update:(ccTime)dt
{
    // 自機を更新する
    [self.player move:dt];
}

/*!
 @brief 自機の移動
 
 自機を移動する。
 @param dx x座標の移動量
 @param dy y座標の移動量
 */
- (void)movePlayerByDx:(float)dx dy:(float)dy
{
    // x方向に移動する
    self.player.positionX = AKRangeCheckF(self.player.positionX + dx,
                                          0.0f,
                                          [AKScreenSize stageSize].width);
    
    // y方向に移動する
    self.player.positionY = AKRangeCheckF(self.player.positionY + dy,
                                          0.0f,
                                          [AKScreenSize stageSize].height);
}
@end

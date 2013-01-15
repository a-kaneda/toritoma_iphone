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
@synthesize script = script_;
@synthesize player = player_;

/*!
 @brief インスタンス取得
 
 インスタンスを取得する。
 現在のシーンがプレイシーン以外の場合はnilを返す。
 @return ゲームデータクラスのインスタンス
 */
+ (AKPlayData *)getInstance
{
    // 実行中のシーンを取得する
    CCScene *scene = [[CCDirector sharedDirector] runningScene];
    
    // ゲームプレイシーンでゲームプレイ中の場合は一時停止状態にする
    if ([scene isKindOfClass:[AKPlayingScene class]]) {
        
        // プレイデータクラスをシーンから取得して返す
        return ((AKPlayingScene *)scene).data;
    }
    
    // 現在実行中のシーンがゲームプレイシーンでない場合はエラー
    NSAssert(0, @"ゲームプレイ中以外にゲームシーンクラスの取得が行われた");
    return nil;
}

/*!
 @brief オブジェクト初期化処理
 
 オブジェクトの初期化を行う。
 @param scene プレイシーン
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithScene:(AKPlayingScene *)scene
{
    AKLog(1, @"start");
    
    // スーパークラスの初期化処理を行う
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
    // スクリプトを実行する
    [self.script update:dt];
    
    // 自機を更新する
    [self.player move:dt];
}

/*!
 @brief スクリプト読み込み
 
 スクリプトファイルを読み込む。
 @param stage ステージ番号
 */
- (void)readScript:(NSInteger)stage
{
    // スクリプトファイルを読み込む
    self.script = [AKScript scriptWithStageNo:stage];
    
    // 最初の待機まで命令を実行する
    [self.script update:0.0f];
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

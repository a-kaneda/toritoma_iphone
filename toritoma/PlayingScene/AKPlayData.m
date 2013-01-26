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
/// 敵キャラの同時出現最大数
static const NSInteger kAKMaxEnemyCount = 32;
/// 画面効果の同時出現最大数
static const NSInteger kAKMaxEffectCount = 64;
/// キャラクターテクスチャアトラス定義ファイル名
static NSString *kAKTextureAtlasDefFile = @"Character.plist";
/// キャラクターテクスチャアトラスファイル名
static NSString *kAKTextureAtlasFile = @"Character.png";

/// キャラクター配置のz座標
enum AKCharacterPositionZ {
    kAKCharaPosZBack = 0,   ///< 背景
    kAKCharaPosZPlayerShot, ///< 自機弾
    kAKCharaPosZPlayer,     ///< 自機
    kAKCharaPosZOption,     ///< オプション
    kAKCharaPosZEnemy,      ///< 敵
    kAKCharaPosZEffect,     ///< 爆発効果
    kAKCharaPosZEnemyShot,  ///< 敵弾
    kAKCharaPosZWall,       ///< 障害物
    kAKCharaPosZCount       ///< z座標種別の数
};

/*!
 @brief ゲームデータ
 
 プレイ画面のゲームデータを管理する。
 */
@implementation AKPlayData

@synthesize scene = scene_;
@synthesize script = script_;
@synthesize player = player_;
@synthesize enemyPool = enemyPool_;
@synthesize effectPool = effectPool_;
@synthesize batches = batches_;

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
    
    // バッチノード配列を作成する
    self.batches = [NSMutableArray arrayWithCapacity:kAKCharaPosZCount];
    
    // テクスチャアトラスを読み込む
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kAKTextureAtlasDefFile textureFilename:kAKTextureAtlasFile];
    
    // 各z座標用にバッチノードを作成する
    for (int i = 0; i < kAKCharaPosZCount; i++) {
        
        // バッチノードをファイルから作成する
        CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:kAKTextureAtlasFile];
        
        // 配列に保存する
        [self.batches addObject:batch];
        
        // シーンに配置する
        [scene.characterLayer addChild:batch z:i];
    }
    
    // 自機を作成する
    self.player = [[[AKPlayer alloc] init] autorelease];
    
    // 初期位置を設定する
    self.player.positionX = kAKPlayerDefaultPosX;
    self.player.positionY = kAKPlayerDefaultPosY;
    
    // 自機をバッチノードに追加する
    [[self.batches objectAtIndex:kAKCharaPosZPlayer] addChild:self.player.image];
    
    // 敵キャラプールを作成する
    self.enemyPool = [[[AKCharacterPool alloc] initWithClass:[AKEnemy class] Size:kAKMaxEnemyCount] autorelease];
    
    // 画面効果プールを作成する
    self.effectPool = [[[AKCharacterPool alloc] initWithClass:[AKEffect class] Size:kAKMaxEffectCount] autorelease];
    
    AKLog(1, @"end");
    return self;
}

/*!
 @brief オブジェクト解放処理
 
 オブジェクトの解放を行う。
 */
- (void)dealloc
{
    AKLog(1, @"start");
    
    // メンバを解放する
    self.player = nil;
    self.enemyPool = nil;
    self.effectPool = nil;
    for (CCNode *node in [self.batches objectEnumerator]) {
        [node removeFromParentAndCleanup:YES];
    }
    self.batches = nil;
    
    // スーパークラスの処理を行う
    [super dealloc];
    
    AKLog(1, @"end");
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
    
    // 敵を更新する
    for (AKEnemy *enemy in [self.enemyPool.pool objectEnumerator]) {
        if (enemy.isStaged) {
            AKLog(0, @"enemy move start.");
            [enemy move:dt];
        }
    }
    
    // 画面効果を更新する
    for (AKEffect *effect in [self.effectPool.pool objectEnumerator]) {
        if (effect.isStaged) {
            [effect move:dt];
        }
    }
    
    // 自機が無敵状態でない場合は当たり判定処理を行う
    if (!self.player.isInvincible) {
        
        // 自機と敵の当たり判定処理を行う
        [self.player hit:[self.enemyPool.pool objectEnumerator]];
    }
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
 @brief スクリプト実行再開
 
 停止中のスクリプト実行を再会する。
 ボスを倒した時などに呼び出す。
 */
- (void)resumeScript
{
    [self.script resume];
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

/*!
 @brief 敵生成
 
 敵キャラを生成する。
 @param type 敵種別
 @param x x座標
 @param y y座標
 */
- (void)entryEnemy:(NSInteger)type x:(NSInteger)x y:(NSInteger)y
{
    // プールから未使用のメモリを取得する
    AKEnemy *enemy = [self.enemyPool getNext];
    if (enemy == nil) {
        // 空きがない場合は処理終了
        NSAssert(0, @"敵プールに空きなし");
        return;
    }
    
    // 敵を生成する
    [enemy createEnemyType:type x:x y:y parent:[self.batches objectAtIndex:kAKCharaPosZEnemy]];
}

/*!
 @brief 画面効果生成
 
 画面効果を生成する。
 @param type 画面効果種別
 @param x x座標
 @param y y座標
 */
- (void)entryEffect:(NSInteger)type x:(NSInteger)x y:(NSInteger)y
{    
    // プールから未使用のメモリを取得する
    AKEffect *effect = [self.effectPool getNext];
    if (effect == nil) {
        // 空きがない場合は処理終了
        NSAssert(0, @"画面効果プールに空きなし");
        return;
    }
    
    // 敵を生成する
    [effect createEffectType:type x:x y:y parent:[self.batches objectAtIndex:kAKCharaPosZEffect]];
}

@end

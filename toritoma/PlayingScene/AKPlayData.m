/*
 * Copyright (c) 2013 Akihiro Kaneda.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1.Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   2.Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   3.Neither the name of the Monochrome Soft nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
/*!
 @file AKPlayData.m
 @brief ゲームデータ
 
 プレイ画面シーンのゲームデータを管理するクラスを定義する。
 */

#import "AKPlayData.h"
#import "AKPlayerShot.h"
#import "AKEnemy.h"
#import "AKEffect.h"
#import "AKBlock.h"
#import "AKBack.h"

/// 自機初期位置x座標
static const float kAKPlayerDefaultPosX = 50.0f;
/// 自機初期位置y座標
static const float kAKPlayerDefaultPosY = 128.0f;
/// 自機弾の同時出現最大数
static const NSInteger kAKMaxPlayerShotCount = 128;
/// 敵キャラの同時出現最大数
static const NSInteger kAKMaxEnemyCount = 32;
/// 敵弾の同時出現最大数
static const NSInteger kAKMaxEnemyShotCount = 256;
/// 画面効果の同時出現最大数
static const NSInteger kAKMaxEffectCount = 64;
/// 障害物の同時出現最大数
static const NSInteger kAKMaxBlockCount = 64;
/// 背景の同時出現最大数
static const NSInteger kAKMaxBackCount = 128;
/// シールドによるゲージ消費率
static const float kAKChickenGaugeUseSpeed = 50.0f;
/// キャラクターテクスチャアトラス定義ファイル名
NSString *kAKTextureAtlasDefFile = @"Character.plist";
/// キャラクターテクスチャアトラスファイル名
NSString *kAKTextureAtlasFile = @"Character.png";
/// ステージクリア後の待機時間
static const float kAKStageClearWaitTime = 5.0f;
/// 初期残機
static const NSInteger kAKInitialLife = 2;
/// 自機復活待機時間
static const float kAKRebirthInterval = 1.0f;

/// キャラクター配置のz座標
enum AKCharacterPositionZ {
    kAKCharaPosZBack = 0,   ///< 背景
    kAKCharaPosZPlayerShot, ///< 自機弾
    kAKCharaPosZOption,     ///< オプション
    kAKCharaPosZPlayer,     ///< 自機
    kAKCharaPosZEnemy,      ///< 敵
    kAKCharaPosZEffect,     ///< 爆発効果
    kAKCharaPosZEnemyShot,  ///< 敵弾
    kAKCharaPosZBlock,      ///< 障害物
    kAKCharaPosZCount       ///< z座標種別の数
};

/*!
 @brief ゲームデータ
 
 プレイ画面のゲームデータを管理する。
 */
@implementation AKPlayData

@synthesize scene = scene_;
@synthesize life = life_;
@synthesize script = script_;
@synthesize player = player_;
@synthesize playerShotPool = playerShotPool_;
@synthesize refrectedShotPool = reflectedShotPool_;
@synthesize enemyPool = enemyPool_;
@synthesize enemyShotPool = enemyShotPool_;
@synthesize effectPool = effectPool_;
@synthesize blockPool = blockPool_;
@synthesize backPool = backPool_;
@synthesize batches = batches_;
@synthesize shield = shield_;
@synthesize scrollSpeedX = scrollSpeedX_;
@synthesize scrollSpeedY = scrollSpeedY_;
@synthesize boss = boss_;

/*!
 @brief インスタンス取得
 
 インスタンスを取得する。
 現在のシーンがプレイシーン以外の場合はnilを返す。
 @return ゲームデータクラスのインスタンス
 */
+ (AKPlayData *)sharedInstance
{
    // 実行中のシーンを取得する
    CCScene *scene = [[CCDirector sharedDirector] runningScene];
    
    // ゲームプレイシーンでゲームプレイ中の場合は一時停止状態にする
    if ([scene isKindOfClass:[AKPlayingScene class]]) {
        
        // プレイデータクラスをシーンから取得して返す
        return ((AKPlayingScene *)scene).data;
    }
    
    // 現在実行中のシーンがゲームプレイシーンでない場合はエラー
    AKLog(kAKLogPlayData_0, @"ゲームプレイ中以外にゲームシーンクラスの取得が行われた");
    NSAssert(NO, @"ゲームプレイ中以外にゲームシーンクラスの取得が行われた");
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
    AKLog(kAKLogPlayData_1, @"start");
    
    // スーパークラスの初期化処理を行う
    self = [super init];
    if (!self) {
        AKLog(kAKLogPlayData_0, @"error");
        return nil;
    }
    
    // シーンをメンバに設定する
    scene_ = scene;
    
    // テクスチャアトラスを読み込む
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kAKTextureAtlasDefFile textureFilename:kAKTextureAtlasFile];
    
    // メンバオブジェクトを生成する
    [self createMember];
    
    // ゲームデータを初期化する
    [self clearPlayData];
        
    AKLog(kAKLogPlayData_1, @"end");
    return self;
}

/*!
 @brief メンバオブジェクト生成処理
 
 メンバオブジェクトを生成する。
 */
- (void)createMember
{
    // バッチノード配列を作成する
    self.batches = [NSMutableArray arrayWithCapacity:kAKCharaPosZCount];
    
    // 各z座標用にバッチノードを作成する
    for (int i = 0; i < kAKCharaPosZCount; i++) {
        
        // バッチノードをファイルから作成する
        CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:kAKTextureAtlasFile];
        
        // 配列に保存する
        [self.batches addObject:batch];
        
        // シーンに配置する
        [self.scene.characterLayer addChild:batch z:i];
    }
    
    // 自機を作成する
    self.player = [[[AKPlayer alloc] initWithParent:[self.batches objectAtIndex:kAKCharaPosZPlayer]
                                       optionParent:[self.batches objectAtIndex:kAKCharaPosZOption]] autorelease];
    
    // 自機弾プールを作成する
    self.playerShotPool = [[[AKCharacterPool alloc] initWithClass:[AKPlayerShot class] Size:kAKMaxPlayerShotCount] autorelease];
    
    // 反射弾プールを作成する
    self.refrectedShotPool = [[[AKCharacterPool alloc] initWithClass:[AKEnemyShot class] Size:kAKMaxEnemyShotCount] autorelease];
    
    // 敵キャラプールを作成する
    self.enemyPool = [[[AKCharacterPool alloc] initWithClass:[AKEnemy class] Size:kAKMaxEnemyCount] autorelease];
    
    // 敵弾プールを作成する
    self.enemyShotPool = [[[AKCharacterPool alloc] initWithClass:[AKEnemyShot class] Size:kAKMaxEnemyShotCount] autorelease];
    
    // 画面効果プールを作成する
    self.effectPool = [[[AKCharacterPool alloc] initWithClass:[AKEffect class] Size:kAKMaxEffectCount] autorelease];
    
    // 障害物プールを作成する
    self.blockPool = [[[AKCharacterPool alloc] initWithClass:[AKBlock class] Size:kAKMaxBlockCount] autorelease];
    
    // 背景プールを作成する
    self.backPool = [[[AKCharacterPool alloc] initWithClass:[AKBack class] Size:kAKMaxBackCount] autorelease];    
}

/*!
 @brief 初期値設定処理
 
 ゲームデータに初期値を設定する。
 */
- (void)clearPlayData
{
    // 自機の初期位置を設定する
    self.player.positionX = kAKPlayerDefaultPosX;
    self.player.positionY = kAKPlayerDefaultPosY;
    
    // シールドは無効状態で初期化する
    self.shield = NO;
    
    // スクロールスピードは0で初期化する
    self.scrollSpeedX = 0.0f;
    self.scrollSpeedY = 0.0f;
    
    // 残機の初期値を設定する
    self.life = kAKInitialLife;
    
    // その他のメンバを初期化する
    stage_ = 0;
    clearWait_ = 0.0f;
    rebirthWait_ = 0.0f;
    boss_ = nil;    
}

/*!
 @brief オブジェクト解放処理
 
 オブジェクトの解放を行う。
 */
- (void)dealloc
{
    AKLog(kAKLogPlayData_1, @"start");
    
    // メンバを解放する
    self.player = nil;
    self.boss = nil;
    self.playerShotPool = nil;
    self.refrectedShotPool = nil;
    self.enemyPool = nil;
    self.enemyShotPool = nil;
    self.effectPool = nil;
    self.blockPool = nil;
    self.backPool = nil;
    for (CCNode *node in [self.batches objectEnumerator]) {
        [node removeFromParentAndCleanup:YES];
    }
    self.batches = nil;
    
    // スーパークラスの処理を行う
    [super dealloc];
    
    AKLog(kAKLogPlayData_1, @"end");
}

/*!
 @brief 残機設定
 
 残機を設定する。
 画面の残機表示の更新も行う。
 @param life 残機
 */
- (void)setLife:(NSInteger)life
{
    // メンバに設定する
    life_ = life;
    
    // シーンの残機表示の更新を行う
    self.scene.life.lifeCount = life;
}

/*!
 @brief シールドモード設定
 
 シールドモードの有効無効を設定する。
 画面のシールドボタンの表示も切り替える。
 @param shield シールドモードが有効かどうか
 */
- (void)setShield:(BOOL)shield
{
    // メンバに設定する
    shield_ = shield;
    
    // シーンのシールドボタンの表示を切り替える
    [self.scene setShieldButtonSelected:shield];
    
    // 自機・オプションに対してシールド有無を設定する
    // オプションは自機の処理の中で設定される
    [self.player setShield:shield];
}

/*!
 @brief 状態更新
 
 各オブジェクトの状態を更新する。
 キャラクターの移動、衝突判定を行う。
 @param dt フレーム更新間隔
 */
- (void)update:(ccTime)dt
{
    // クリア後の待機中の場合はスクリプトを実行しない
    if (clearWait_ > 0.0f) {
        
        // 待機時間をカウントする
        clearWait_ -= dt;
        
        // 待機時間が経過した場合は次のステージへと進める
        if (clearWait_ < 0.0f) {
            
            AKLog(kAKLogPlayData_1, @"ステージクリア後の待機時間経過");
            
            // 次のステージのスクリプトを読み込む
            [self readScript:stage_ + 1];
            
            // 待機時間をリセットする
            clearWait_ = 0.0f;
        }
    }
    // ステージ実行中の場合はスクリプトの実行を行う
    else {
        // スクリプトを実行する
        if ([self.script update:dt]) {
            
            AKLog(kAKLogPlayData_1, @"ステージ%dクリア", stage_);
            
            // スクリプトをすべて実行した場合はクリア後の待機時間を設定する
            clearWait_ = kAKStageClearWaitTime;
        }
    }
    
    // 自機が破壊されている場合は復活までの時間をカウントする
    if (!self.player.isStaged) {
        
        rebirthWait_ -= dt;
        
        // 復活までの時間が経過している場合は自機を復活する
        if (rebirthWait_ < 0) {
            
            // 自機を復活させる
            [self.player rebirth];
        }
    }
    
    // 背景を更新する
    for (AKBack *back in [self.backPool.pool objectEnumerator]) {
        if (back.isStaged) {
            [back move:dt];
        }
    }
    
    // 障害物を更新する
    for (AKBlock *block in [self.blockPool.pool objectEnumerator]) {
        if (block.isStaged) {
            [block move:dt];
        }
    }
    
    // 自機を更新する
    [self.player move:dt];
    
    // 自機弾を更新する
    for (AKPlayerShot *playerShot in [self.playerShotPool.pool objectEnumerator]) {
        if (playerShot.isStaged) {
            [playerShot move:dt];
        }
    }
    
    // 反射弾を更新する
    for (AKEnemyShot *refrectedShot in [self.refrectedShotPool.pool objectEnumerator]) {
        if (refrectedShot.isStaged) {
            [refrectedShot move:dt];
        }
    }
    
    // 敵を更新する
    for (AKEnemy *enemy in [self.enemyPool.pool objectEnumerator]) {
        if (enemy.isStaged) {
            AKLog(kAKLogPlayData_1, @"enemy move start.");
            [enemy move:dt];
        }
    }
    
    // 敵弾を更新する
    for (AKEnemyShot *enemyShot in [self.enemyShotPool.pool objectEnumerator]) {
        if (enemyShot.isStaged) {
            [enemyShot move:dt];
        }
    }
    
    // 画面効果を更新する
    for (AKEffect *effect in [self.effectPool.pool objectEnumerator]) {
        if (effect.isStaged) {
            [effect move:dt];
        }
    }
    
    // 障害物の当たり判定を行う
    for (AKBlock *block in [self.blockPool.pool objectEnumerator]) {
        if (block.isStaged) {
            
            // 自機との当たり判定を行う
            [block checkHit:[NSArray arrayWithObject:self.player]];
            
            // 自機弾との当たり判定を行う
            [block checkHit:[self.playerShotPool.pool objectEnumerator]];
            
            // 敵との当たり判定を行う
            [block checkHit:[self.enemyPool.pool objectEnumerator]];
            
            // 敵弾との当たり判定を行う
            [block checkHit:[self.enemyShotPool.pool objectEnumerator]];
        }
    }
    
    // 敵と自機弾、反射弾の当たり判定を行う
    for (AKEnemy *enemy in [self.enemyPool.pool objectEnumerator]) {
        
        // 自機弾との当たり判定を行う
        [enemy checkHit:[self.playerShotPool.pool objectEnumerator]];
        
        // 反射弾との当たり判定を行う
        [enemy checkHit:[self.refrectedShotPool.pool objectEnumerator]];
    }
    
    // シールド有効時、反射の判定を行う
    if (self.shield) {
        
        // オプションを取得する
        AKOption *option = self.player.option;
        
        // 各オプションに対して当たり判定を行う
        while (option != nil && option.isStaged) {
            
            AKLog(kAKLogPlayData_1, @"反射判定");
            
            // 敵弾との当たり判定を行う
            [option checkHit:[self.enemyShotPool.pool objectEnumerator]];
            
            // 次のオプションを取得する
            option = option.next;
        }
    }
    
    // 自機が無敵状態でない場合は当たり判定処理を行う
    if (!self.player.isInvincible) {
        
        // 自機と敵弾のかすり判定処理を行う
        [self.player graze:[self.enemyShotPool.pool objectEnumerator]];
        
        // 自機と敵の当たり判定処理を行う
        [self.player checkHit:[self.enemyPool.pool objectEnumerator]];
        
        // 自機と敵弾の当たり判定処理を行う
        [self.player checkHit:[self.enemyShotPool.pool objectEnumerator]];
    }
    
    // ボスが登場している場合
    if (self.boss != nil) {
        
        // ボスが倒された(いなくなった)場合、スクリプトの読み込みを再開する
        if (!self.boss.isStaged) {
            
            AKLog(kAKLogPlayData_1, @"ボス撃破");
            
            // スクリプトの読み込みを再開する
            [self.script resume];
            
            // ボスを削除する
            self.boss = nil;
        }
    }
    
    // シールドが有効な場合はチキンゲージを減少させる
    if (self.shield) {
        self.player.chickenGauge -= kAKChickenGaugeUseSpeed * dt;
        
        // チキンゲージがなくなった場合は強制的にシールドを無効にする
        if (self.player.chickenGauge < 0.0f) {
            self.player.chickenGauge = 0.0f;
            self.shield = NO;
        }
    }
    
    // チキンゲージの溜まっている比率を更新する
    self.scene.chickenGauge.percent = self.player.chickenGauge;
    
    // チキンゲージからオプション個数を決定する
    [self.player updateOptionCount];
}

/*!
 @brief スクリプト読み込み
 
 スクリプトファイルを読み込む。
 @param stage ステージ番号
 */
- (void)readScript:(NSInteger)stage
{
    // ステージ番号をメンバに設定する
    stage_ = stage;
    
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
    // 移動先の座標を設定する
    [self.player setPositionX:AKRangeCheckF(self.player.positionX + dx,
                                            0.0f,
                                            [AKScreenSize stageSize].width)
                            y:AKRangeCheckF(self.player.positionY + dy,
                                            0.0f,
                                            [AKScreenSize stageSize].height)];
}

/*!
 @brief 自機弾生成
 
 自機弾を生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 */
- (void)createPlayerShotAtX:(NSInteger)x y:(NSInteger)y
{
    // プールから未使用のメモリを取得する
    AKPlayerShot *playerShot = [self.playerShotPool getNext];
    if (playerShot == nil) {
        // 空きがない場合は処理終了する
        AKLog(kAKLogPlayData_0, @"自機弾プールに空きなし");
        NSAssert(NO, @"自機弾プールに空きなし");
        return;
    }
    
    // 自機弾を生成する
    [playerShot createPlayerShotAtX:x y:y parent:[self.batches objectAtIndex:kAKCharaPosZPlayerShot]];
}

/*!
 @brief 反射弾生成
 
 反射弾を生成する。
 @param enemyShot 反射する敵弾
 */
- (void)createReflectiedShot:(AKEnemyShot *)enemyShot
{
    AKLog(kAKLogPlayData_1, @"反射弾生成");
    
    // プールから未使用のメモリを取得する
    AKEnemyShot *reflectedShot = [self.refrectedShotPool getNext];
    if (reflectedShot == nil) {
        // 空きがない場合は処理終了する
        AKLog(kAKLogPlayData_0, @"反射弾プールに空きなし");
        NSAssert(NO, @"反射弾プールに空きなし");
        return;
    }
    
    // 反射する敵弾を元に反射弾を生成する
    [reflectedShot createReflectedShot:enemyShot parent:[self.batches objectAtIndex:kAKCharaPosZPlayerShot]];
}

/*!
 @brief 敵生成
 
 敵キャラを生成する。
 @param type 敵種別
 @param x x座標
 @param y y座標
 */
- (void)createEnemy:(NSInteger)type x:(NSInteger)x y:(NSInteger)y isBoss:(BOOL)isBoss
{
    // プールから未使用のメモリを取得する
    AKEnemy *enemy = [self.enemyPool getNext];
    if (enemy == nil) {
        // 空きがない場合は処理終了する
        AKLog(kAKLogPlayData_0, @"敵プールに空きなし");
        NSAssert(NO, @"敵プールに空きなし");
        return;
    }
    
    // ボスキャラの場合はメンバに設定する
    if (isBoss) {
        self.boss = enemy;
    }
    
    // 敵を生成する
    [enemy createEnemyType:type x:x y:y parent:[self.batches objectAtIndex:kAKCharaPosZEnemy]];
}

/*!
 @brief 敵弾生成
 
 敵の弾を生成する。
 @param type 種別
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param angle 進行方向
 @param speed スピード
 */
- (void)createEnemyShotType:(NSInteger)type
                          x:(NSInteger)x
                          y:(NSInteger)y
                      angle:(float)angle
                      speed:(float)speed
{
    // プールから未使用のメモリを取得する
    AKEnemyShot *enemyShot = [self.enemyShotPool getNext];
    if (enemyShot == nil) {
        // 空きがない場合は処理終了する
        AKLog(kAKLogPlayData_0, @"敵弾プールに空きなし");
        NSAssert(NO, @"敵弾プールに空きなし");
        return;
    }
    
    // 敵弾を生成する
    [enemyShot createEnemyShotType:type
                                 x:x
                                 y:y
                             angle:angle
                             speed:speed
                            parent:[self.batches objectAtIndex:kAKCharaPosZEnemyShot]];
}

/*!
 @brief 画面効果生成
 
 画面効果を生成する。
 @param type 画面効果種別
 @param x x座標
 @param y y座標
 */
- (void)createEffect:(NSInteger)type x:(NSInteger)x y:(NSInteger)y
{    
    // プールから未使用のメモリを取得する
    AKEffect *effect = [self.effectPool getNext];
    if (effect == nil) {
        // 空きがない場合は処理終了する
        AKLog(kAKLogPlayData_0, @"画面効果プールに空きなし");
        NSAssert(NO, @"画面効果プールに空きなし");
        return;
    }
    
    // 画面効果を生成する
    [effect createEffectType:type
                           x:x
                           y:y
                      parent:[self.batches objectAtIndex:kAKCharaPosZEffect]];
}

/*!
 @brief 障害物生成
 
 障害物を生成する。
 @param type 障害物種別
 @param x x座標
 @param y y座標
 */
- (void)createBlock:(NSInteger)type x:(NSInteger)x y:(NSInteger)y
{
    // プールから未使用のメモリを取得する
    AKBlock *block = [self.blockPool getNext];
    if (block == nil) {
        // 空きがない場合は処理終了する
        AKLog(kAKLogPlayData_0, @"障害物プールに空きなし");
        NSAssert(NO, @"障害物プールに空きなし");
        return;
    }
    
    // 障害物を生成する
    [block createBlockType:type
                         x:x
                         y:y
                    parent:[self.batches objectAtIndex:kAKCharaPosZBlock]];
}

/*!
 @brief 背景生成
 
 背景物を生成する。
 @param type 障害物種別
 @param x x座標
 @param y y座標
 */
- (void)createBack:(NSInteger)type x:(NSInteger)x y:(NSInteger)y
{
    // プールから未使用のメモリを取得する
    AKBack *back = [self.backPool getNext];
    if (back == nil) {
        // 空きがない場合は処理終了する
        AKLog(kAKLogPlayData_0, @"背景プールに空きなし");
        NSAssert(NO, @"背景プールに空きなし");
        return;
    }
    
    // 背景を生成する
    [back createBackType:type
                       x:x
                       y:y
                  parent:[self.batches objectAtIndex:kAKCharaPosZBack]];
}

/*!
 @brief 失敗時処理
 
 失敗した時の処理を行う。
 */
- (void)miss
{
    // 残機がまだ残っている場合は残機を一つ減らして復活処理を行う
    if (self.life) {
        
        // シールドをオフにする
        self.shield = NO;
        
        // 残機をひとつ減らす
        self.life = self.life - 1;
                
        // 自機復活待機時間を設定する
        rebirthWait_ = kAKRebirthInterval;
    }
    // [TODO]残機が残っていない場合はゲームオーバーとする
    else {
        
    }
}
@end

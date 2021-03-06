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
#import "AKHiScoreFile.h"

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
static const NSInteger kAKMaxBlockCount = 128;
/// キャラクターテクスチャアトラス定義ファイル名
NSString *kAKTextureAtlasDefFile = @"Character.plist";
/// キャラクターテクスチャアトラスファイル名
NSString *kAKTextureAtlasFile = @"Character.png";
/// ハイスコアファイル名
static NSString *kAKDataFileName = @"hiscore.dat";
/// ハイスコアファイルのエンコードキー名
static NSString *kAKDataFileKey = @"hiScoreData";
/// ステージクリア後の待機時間
static const float kAKStageClearWaitTime = 5.0f;
/// 初期残機
static const NSInteger kAKInitialLife = 2;
/// 自機復活待機フレーム数
static const NSInteger kAKRebirthInterval = 60;
/// エクステンドするスコア
static const NSInteger kAKExtendScore = 50000;
/// ステージの数
static const NSInteger kAKStageCount = 5;
/// ゲームクリア時のツイートのフォーマットのキー
static NSString *kAKGameClearTweetKey = @"GameClearTweet";
/// ゲームオーバー時のツイートのフォーマットのキー
static NSString *kAKGameOverTweetKey = @"GameOverTweet";

/// キャラクター配置のz座標
enum AKCharacterPositionZ {
    kAKCharaPosZBlock = 0,  ///< 障害物
    kAKCharaPosZPlayerShot, ///< 自機弾
    kAKCharaPosZOption,     ///< オプション
    kAKCharaPosZPlayer,     ///< 自機
    kAKCharaPosZEnemy,      ///< 敵
    kAKCharaPosZEffect,     ///< 爆発効果
    kAKCharaPosZEnemyShot,  ///< 敵弾
    kAKCharaPosZCount       ///< z座標種別の数
};

/*!
 @brief ゲームデータ
 
 プレイ画面のゲームデータを管理する。
 */
@implementation AKPlayData

@synthesize scene = scene_;
@synthesize life = life_;
@synthesize tileMap = tileMap_;
@synthesize player = player_;
@synthesize playerShotPool = playerShotPool_;
@synthesize refrectedShotPool = reflectedShotPool_;
@synthesize enemyPool = enemyPool_;
@synthesize enemyShotPool = enemyShotPool_;
@synthesize effectPool = effectPool_;
@synthesize blockPool = blockPool_;
@synthesize batches = batches_;
@synthesize shield = shield_;
@synthesize scrollSpeedX = scrollSpeedX_;
@synthesize scrollSpeedY = scrollSpeedY_;

#pragma mark オブジェクト初期化

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
    
    // スクロールスピード・位置は0で初期化する
    self.scrollSpeedX = 0.0f;
    self.scrollSpeedY = 0.0f;
    
    // 残機の初期値を設定する
    self.life = kAKInitialLife;
    
    // ハイスコアをファイルから読み込む
    [self readHiScore];
    
    // その他のメンバを初期化する
    stage_ = 0;
    score_ = 0;
    clearWait_ = 0;
    rebirthWait_ = 0;
}

#pragma mark オブジェクト解放

/*!
 @brief オブジェクト解放処理
 
 オブジェクトの解放を行う。
 */
- (void)dealloc
{
    AKLog(kAKLogPlayData_1, @"start");
    
    // メンバを解放する
    self.player = nil;
    self.playerShotPool = nil;
    self.refrectedShotPool = nil;
    self.enemyPool = nil;
    self.enemyShotPool = nil;
    self.effectPool = nil;
    self.blockPool = nil;
    for (CCNode *node in [self.batches objectEnumerator]) {
        [node removeFromParentAndCleanup:YES];
    }
    self.batches = nil;
    
    // スーパークラスの処理を行う
    [super dealloc];
    
    AKLog(kAKLogPlayData_1, @"end");
}

#pragma mark アクセサ

/*!
 @brief 自機の位置情報取得
 
 自機の位置情報を取得する。
 @return 自機の位置情報
 */
- (CGPoint)playerPosition
{
    return ccp(self.player.positionX, self.player.positionY);
}

/*!
 @brief 障害物キャラクター取得
 
 障害物キャラクターを取得する。
 @return 障害物キャラクター
 */
- (NSArray *)blocks
{
    return self.blockPool.pool;
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

#pragma mark ファイルアクセス

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
    self.tileMap = [AKTileMap scriptWithStageNo:stage layer:self.scene.backgroundLayer];
    
    // 初期表示の1画面分の処理を行う
    [self.tileMap update:self];
}

/*!
 @brief ハイスコアファイル読込
 
 ハイスコアファイルを読み込む。
 */
- (void)readHiScore
{
    AKLog(kAKLogPlayData_1, @"start");
    
    // HOMEディレクトリのパスを取得する
    NSString *homeDir = NSHomeDirectory();
    
    // Documentsディレクトリへのパスを作成する
    NSString *docDir = [homeDir stringByAppendingPathComponent:@"Documents"];
    
    // ファイルパスを作成する
    NSString *filePath = [docDir stringByAppendingPathComponent:kAKDataFileName];
    
    // ファイルを読み込む
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    AKLog(kAKLogPlayData_1 && data == nil, @"ファイル読み込み失敗");
    
    // ファイルが読み込めた場合はデータを取得する
    if (data != nil) {
        
        // ファイルからデコーダーを生成する
        NSKeyedUnarchiver *decoder = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
        
        // ハイスコアをデコードする
        AKHiScoreFile *hiScore = [decoder decodeObjectForKey:kAKDataFileKey];
        
        // デコードを完了する
        [decoder finishDecoding];
        
        // メンバに読み込む
        hiScore_ = hiScore.hiscore;
        
        AKLog(kAKLogPlayData_1, @"hiScore_=%d", hiScore_);
    }
}

/*!
 @brief ハイスコアファイル書込
 
 ハイスコアファイルを書き込む。
 */
- (void)writeHiScore
{
    AKLog(kAKLogPlayData_1, @"start hiScore=%d", hiScore_);
    
    // HOMEディレクトリのパスを取得する
    NSString *homeDir = NSHomeDirectory();
    
    // Documentsディレクトリへのパスを作成する
    NSString *docDir = [homeDir stringByAppendingPathComponent:@"Documents"];
    
    // ファイルパスを作成する
    NSString *filePath = [docDir stringByAppendingPathComponent:kAKDataFileName];
    
    // ハイスコアファイルオブジェクトを生成する
    AKHiScoreFile *hiScore = [[[AKHiScoreFile alloc] init] autorelease];
    
    // ハイスコアを設定する
    hiScore.hiscore = hiScore_;
    
    // エンコーダーを生成する
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *encoder = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    
    // ファイル内容をエンコードする
    [encoder encodeObject:hiScore forKey:kAKDataFileKey];
    
    // エンコードを完了する
    [encoder finishEncoding];
    
    // ファイルを書き込む
    [data writeToFile:filePath atomically:YES];
    
    // Game Centerにスコアを送信する
    [[AKGameCenterHelper sharedHelper] reportHiScore:score_];
}

#pragma mark シーンクラスからのデータ操作用

/*!
 @brief 状態更新
 
 各オブジェクトの状態を更新する。
 キャラクターの移動、衝突判定を行う。
 */
- (void)update
{
    // クリア後の待機中の場合はスクリプトを実行しない
    if (clearWait_ > 0) {
        
        // 自機が破壊されている場合は復活するまで処理しない
        // 自機が存在する場合のみ待機時間のカウントとステージクリア処理を行う
        if (!self.player.isStaged) {
            
            // 待機時フレーム数をカウントする
            clearWait_--;
            
            // 待機フレーム数が経過した場合は次のステージへと進める
            if (clearWait_ <= 0) {
                
                AKLog(kAKLogPlayData_1, @"ステージクリア後の待機時間経過");
                
                // ステージクリアの実績をGame Centerへ送信する
                [[AKGameCenterHelper sharedHelper] reportStageClear:stage_];
                
                // ステージを進める
                stage_++;
                
                // 次のステージのスクリプトを読み込む
                [self readScript:stage_];
                
                // 待機フレーム数をリセットする
                clearWait_ = 0;
            }
        }
    }
    
    // TODO:クリア時の処理を作成する
    
    // 復活待機フレーム数が設定されている場合はフレーム数をカウントする
    if (rebirthWait_ > 0) {
        
        rebirthWait_--;
        
        // 復活までのフレーム数が経過している場合は自機を復活する
        if (rebirthWait_ <= 0) {
            
            // 自機を復活させる
            [self.player rebirth];
        }
    }
    
    // マップを更新する
    [self.tileMap update:self];
    
    // 障害物を更新する
    for (AKBlock *block in [self.blockPool.pool objectEnumerator]) {
        if (block.isStaged) {
            [block move:self];
        }
    }
    
    // 自機を更新する
    [self.player move:self];
    
    // 自機弾を更新する
    for (AKPlayerShot *playerShot in [self.playerShotPool.pool objectEnumerator]) {
        if (playerShot.isStaged) {
            [playerShot move:self];
        }
    }
    
    // 反射弾を更新する
    for (AKEnemyShot *refrectedShot in [self.refrectedShotPool.pool objectEnumerator]) {
        if (refrectedShot.isStaged) {
            [refrectedShot move:self];
        }
    }
    
    // 敵を更新する
    for (AKEnemy *enemy in [self.enemyPool.pool objectEnumerator]) {
        if (enemy.isStaged) {
            AKLog(kAKLogPlayData_2, @"enemy move start.");
            [enemy move:self];
        }
    }
    
    // 敵弾を更新する
    for (AKEnemyShot *enemyShot in [self.enemyShotPool.pool objectEnumerator]) {
        if (enemyShot.isStaged) {
            [enemyShot move:self];
        }
    }
    
    // 画面効果を更新する
    for (AKEffect *effect in [self.effectPool.pool objectEnumerator]) {
        if (effect.isStaged) {
            [effect move:self];
        }
    }
    
    // 障害物の当たり判定を行う
    for (AKBlock *block in [self.blockPool.pool objectEnumerator]) {
        if (block.isStaged) {
            
            // 自機との当たり判定を行う
            [block checkHit:[NSArray arrayWithObject:self.player] data:self];
            
            // 自機弾との当たり判定を行う
            [block checkHit:[self.playerShotPool.pool objectEnumerator] data:self];
            
            // 敵は移動処理の中で障害物との当たり判定を処理しているので
            // ここでは処理しない。
//            [block checkHit:[self.enemyPool.pool objectEnumerator] data:self];
            
            // 敵弾との当たり判定を行う
            [block checkHit:[self.enemyShotPool.pool objectEnumerator] data:self];
        }
    }
    
    // 敵と自機弾、反射弾の当たり判定を行う
    for (AKEnemy *enemy in [self.enemyPool.pool objectEnumerator]) {
        
        // 自機弾との当たり判定を行う
        [enemy checkHit:[self.playerShotPool.pool objectEnumerator] data:self];
        
        // 反射弾との当たり判定を行う
        [enemy checkHit:[self.refrectedShotPool.pool objectEnumerator] data:self];
    }
    
    // シールド有効時、反射の判定を行う
    if (self.shield) {
        
        // オプションを取得する
        AKOption *option = self.player.option;
        
        // 各オプションに対して当たり判定を行う
        while (option != nil && option.isStaged) {
            
            AKLog(kAKLogPlayData_1, @"反射判定");
            
            // 敵弾との当たり判定を行う
            [option checkHit:[self.enemyShotPool.pool objectEnumerator] data:self];
            
            // 次のオプションを取得する
            option = option.next;
        }
    }
    
    // 自機が無敵状態でない場合は当たり判定処理を行う
    if (!self.player.isInvincible) {
        
        // 自機と敵弾のかすり判定処理を行う
        [self.player graze:[self.enemyShotPool.pool objectEnumerator]];
        
        // 自機と敵の当たり判定処理を行う
        [self.player checkHit:[self.enemyPool.pool objectEnumerator] data:self];
        
        // 自機と敵弾の当たり判定処理を行う
        [self.player checkHit:[self.enemyShotPool.pool objectEnumerator] data:self];
    }
    
    // シールドが有効な場合はチキンゲージを減少させる
    if (self.shield) {
        self.player.chickenGauge--;
        
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
 @brief 自機の移動
 
 自機を移動する。
 @param dx x座標の移動量
 @param dy y座標の移動量
 */
- (void)movePlayerByDx:(float)dx dy:(float)dy
{
    AKLog(kAKLogPlayData_3, @"x=%f dx=%f width=%f y=%f dy=%f height=%f",
          self.player.positionX, dx, kAKStageSize.width,
          self.player.positionY, dy, kAKStageSize.height);
    
    // 移動先の座標を設定する
    [self.player setPositionX:AKRangeCheckF(self.player.positionX + dx,
                                            0.0f,
                                            kAKStageSize.width)
                            y:AKRangeCheckF(self.player.positionY + dy,
                                            0.0f,
                                            kAKStageSize.height)
                         data:self];
}

/*!
 @brief ツイートメッセージの作成
 
 ツイートメッセージを作成する。
 進行したステージ数と獲得したスコアから文字列を作成する。
 @return ツイートメッセージ
 */
- (NSString *)makeTweet
{
    NSString *tweet = nil;
    
    // 全ステージクリアの場合と途中でゲームオーバーになった時でツイート内容を変更する。
    if (stage_ > kAKStageCount) {
        NSString *format = NSLocalizedString(kAKGameClearTweetKey, @"ゲームクリア時のツイート");
        tweet = [NSString stringWithFormat:format, score_];
    }
    else {
        NSString *format = NSLocalizedString(kAKGameOverTweetKey, @"ゲームオーバー時のツイート");
        tweet = [NSString stringWithFormat:format, stage_, score_];
    }
    
    // Twitterでは同じ内容のツイートは連続して投稿できない。
    // テスト時はこれを回避するため、末尾に現在日時を付加して同じ内容にならないようにする。
#ifdef DEBUG
    return [NSString stringWithFormat:@"%@ %@", tweet, [[NSDate date] description]];
#else
    return tweet;
#endif
}
/*!
 @brief ゲーム再開
 
 一時停止中の状態からゲームを再会する。
 */
- (void)resume
{
    // すべてのキャラクターのアニメーションを再開する
    // 自機
    [self.player.image resumeSchedulerAndActions];
    
    // 自機弾
    for (AKCharacter *character in self.playerShotPool.pool.objectEnumerator) {
        [character.image resumeSchedulerAndActions];
    }
    
    // 敵
    for (AKCharacter *character in self.enemyPool.pool.objectEnumerator) {
        [character.image resumeSchedulerAndActions];
    }
    
    // 敵弾
    for (AKCharacter *character in self.enemyShotPool.pool.objectEnumerator) {
        [character.image resumeSchedulerAndActions];
    }
    
    // 画面効果
    for (AKCharacter *character in self.effectPool.pool.objectEnumerator) {
        [character.image resumeSchedulerAndActions];
    }
}

/*!
 @brief ポーズ
 
 プレイ中の状態からゲームを一時停止する。
 */
- (void)pause
{
    // すべてのキャラクターのアニメーションを停止する
    // 自機
    [self.player.image pauseSchedulerAndActions];
    
    // 自機弾
    for (AKCharacter *character in [self.playerShotPool.pool objectEnumerator]) {
        [character.image pauseSchedulerAndActions];
    }
    
    // 敵
    for (AKCharacter *character in [self.enemyPool.pool objectEnumerator]) {
        [character.image pauseSchedulerAndActions];
    }
    
    // 敵弾
    for (AKCharacter *character in [self.enemyShotPool.pool objectEnumerator]) {
        [character.image pauseSchedulerAndActions];
    }
    
    // 画面効果
    for (AKCharacter *character in [self.effectPool.pool objectEnumerator]) {
        [character.image pauseSchedulerAndActions];
    }
}

#pragma mark キャラクタークラスからのデータ操作用

/*!
 @brief デバイス座標からタイル座標の取得
 
 デバイススクリーン座標からマップ座標へ、マップ座標からタイルの座標へ変換する。
 @param devicePosition デバイススクリーン座標
 @return タイルの座標
 */
- (CGPoint)tilePositionFromDevicePosition:(CGPoint)devicePosition
{
    // デバイススクリーン座標からマップ座標を取得する
    CGPoint mapPosition = [self.tileMap mapPositionFromDevicePosition:devicePosition];
    
    // マップ座標からタイルの座標を取得する
    return [self.tileMap tilePositionFromMapPosition:mapPosition];
}

/*!
 @brief 自機弾生成
 
 自機弾を生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 */
- (void)createPlayerShotAtX:(NSInteger)x y:(NSInteger)y
{
    AKLog(kAKLogPlayData_1, @"自機弾生成");
    
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
 @param progress 倒した時に進む進行度
 */
- (void)createEnemy:(NSInteger)type x:(NSInteger)x y:(NSInteger)y progress:(NSInteger)progress
{
    AKLog(kAKLogPlayData_1, @"敵生成");

    // プールから未使用のメモリを取得する
    AKEnemy *enemy = [self.enemyPool getNext];
    if (enemy == nil) {
        // 空きがない場合は処理終了する
        AKLog(kAKLogPlayData_0, @"敵プールに空きなし");
        NSAssert(NO, @"敵プールに空きなし");
        return;
    }
    
    // 敵を生成する
    [enemy createEnemyType:type x:x y:y progress:progress parent:[self.batches objectAtIndex:kAKCharaPosZEnemy]];
}

/*!
 @brief 敵弾インスタンスの取得
 
 敵弾プールから次のインスタンスを取得する。
 @return 敵弾インスタンス
 */
- (AKEnemyShot *)getEnemyShot
{
    // プールから未使用のメモリを取得する
    AKEnemyShot *enemyShot = [self.enemyShotPool getNext];
    
    AKLog(kAKLogPlayData_0 && enemyShot == nil, @"敵弾プールに空きなし");
    NSAssert(enemyShot, @"敵弾プールに空きなし");
    
    return enemyShot;
}

/*!
 @brief 敵弾配置ノードの取得
 
 敵弾を配置するノードを取得する。
 @return 敵弾配置ノード
 */
- (CCNode *)getEnemyShotParent
{
    return [self.batches objectAtIndex:kAKCharaPosZEnemyShot];
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
    AKLog(kAKLogPlayData_1, @"画面効果生成");

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
 @param x 前回作成した背景/障害物からのx方向の距離
 @param y 前回作成した背景/障害物からのy方向の距離
 */
- (void)createBlock:(NSInteger)type x:(float)x y:(float)y
{
    AKLog(kAKLogPlayData_1, @"障害物生成");
    
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
    // 残機が残っていない場合はゲームオーバーとする
    else {
        [self.scene gameOver];
    }
}

/*!
 @brief スコア加算
 
 スコアを加算する。ハイスコアを超えている場合はハイスコアも合わせて更新する。
 スコア、ハイスコアの表示を更新する。
 @param score スコア増加量
 */
- (void)addScore:(NSInteger)score
{
    // エクステンドの判定を行う
    // ゲームオーバー時にはエクステンドしない(相打ちによってスコアが入った時)
    if ((int)(score_ / kAKExtendScore) < (int)((score_ + score) / kAKExtendScore) &&
        !self.scene.isGameOver) {
        
        AKLog(kAKLogPlayData_1, @"エクステンド:score_=%d score=%d しきい値=%d", score_, score, kAKExtendScore);
        
        // TODO:エクステンドの効果音を鳴らす
        
        // 残機の数を増やす
        self.life = self.life + 1;
        
        // TODO:実績を解除する
    }
    
    // スコアを加算する
    score_ += score;
    
    // スコア表示を更新する
    [self.scene setScoreLabel:score_];
    
    // ハイスコアを更新している場合はハイスコアを設定する
    if (score_ > hiScore_) {
        
        // ハイスコアにスコアの値を設定する
        hiScore_ = score_;
    }
}

/*!
 @brief 進行度を進める
 
 進行度を進める。
 @param progress 進行度
 */
- (void)addProgress:(NSInteger)progress
{
    self.tileMap.progress += progress;
}
@end

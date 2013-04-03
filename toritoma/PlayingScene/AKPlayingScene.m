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
 @file AKPlayingScene.m
 @brief プレイシーンの定義
 
 プレイシーンクラスを定義する。
 */

#import "AKPlayingScene.h"

/// レイヤーのz座標、タグの値にも使用する
enum {
    kAKLayerPosZBack = 0,   ///< 背景レイヤー
    kAKLayerPosZCharacter,  ///< キャラクターレイヤー
    kAKLayerPosZFrame,      ///< 枠レイヤー
    kAKLayerPosZInfo,       ///< 情報レイヤー
    kAKLayerPosZResult,     ///< ステージクリアレイヤー
    kAKLayerPosZInterface   ///< インターフェースレイヤー
};

/// 情報レイヤーに配置するノードのタグ
enum {
    kAKInfoTagChickenGauge = 0, ///< チキンゲージ
    kAKInfoTagLife,             ///< 残機
    kAKInfoTagScore,            ///< スコア
    kAKInfoTagHiScore,          ///< ハイスコア
};

/// 自機移動をスライド量の何倍にするか
static const float kAKPlayerMoveVal = 1.8f;
/// 開始ステージ番号
static const NSInteger kAKStartStage = 1;
/// チキンゲージ配置位置、下からの座標
static const float kAKChickenGaugePosFromBottomPoint = 18.0f;
/// 残機表示の位置、ステージ座標x座標
static const float kAKLifePosXOfStage = 4.0f;
/// 残機表示の位置、ステージ座標y座標
static const float kAKLifePosYOfStage = 272.0f;
/// スコアの表示位置、ステージ座標y座標
static const float kAKScorePosYOfStage = 272.0f;
/// スコア表示のフォーマット
static NSString *kAKScoreFormat = @"SCORE:%06d";
/// ゲームオーバー時の待機時間
static const float kAKGameOverWaitTime = 1.0f;

// プライベートメソッド宣言
@interface AKPlayingScene ()
// ゲーム再開
- (void)resume;
// 終了メニュー表示
- (void)viewQuitMenu;
// 一時停止メニュー表示
- (void)viewPauseMenu;
@end

/*!
 @brief プレイシーンクラス
 
 プレイ中画面のシーンを管理する。
 */
@implementation AKPlayingScene

@synthesize data = data_;
@synthesize state = state_;

#pragma mark オブジェクト初期化

/*!
 @brief オブジェクト初期化処理
 
 オブジェクトの初期化を行う。
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    AKLog(kAKLogPlayingScene_1, @"start");
    
    // スーパークラスの処理を行う
    self = [super init];
    if (!self) {
        AKLog(kAKLogPlayingScene_0, @"error");
        return nil;
    }
    
    // テクスチャアトラスを読み込む
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kAKControlTextureAtlasDefFile textureFilename:kAKControlTextureAtlasFile];

    // 背景レイヤーを作成する
    [self createBackGround];

    // キャラクターレイヤーを作成する
    [self createCharacterLayer];
    
    // 情報レイヤーを作成する
    [self createInfoLayer];
    
    // インターフェースレイヤーを作成する
    [self createInterface];
    
    // 枠レイヤーを作成する
    [self createFrame];
    
    // 状態をシーン読み込み前に設定する
    self.state = kAKGameStatePreLoad;
    
    // スリープ時間を初期化する
    sleepTime_ = 0.0f;
    
    // ゲームデータを生成する
    self.data = [[[AKPlayData alloc] initWithScene:self] autorelease];

    // 更新処理開始
    [self scheduleUpdate];
    
    AKLog(kAKLogPlayingScene_1, @"end");
    return self;
}

/*!
 @brief 背景レイヤー作成
 
 背景レイヤーを作成する。
 */
- (void)createBackGround
{
    // 背景レイヤーを作成する
    [self addChild:AKCreateBackColorLayer() z:kAKLayerPosZBack tag:kAKLayerPosZBack];    
}

/*!
 @brief キャラクターレイヤー作成
 
 キャラクターレイヤーを作成する。
 */
- (void)createCharacterLayer
{
    // キャラクターを配置するレイヤーを作成する
    CCLayer *characterLayer = [CCLayer node];
    
    // キャラクターレイヤーを画面に配置する
    [self addChild:characterLayer z:kAKLayerPosZCharacter tag:kAKLayerPosZCharacter];
}

/*!
 @brief 情報レイヤー作成
 
 情報レイヤーを作成する。レイヤーに配置するものも作成する。
 */
- (void)createInfoLayer
{
    // 情報レイヤーを作成する
    CCLayer *infoLayer = [CCLayer node];
    
    // 情報レイヤーを画面に配置する
    [self addChild:infoLayer z:kAKLayerPosZInfo tag:kAKLayerPosZInfo];
    
    // チキンゲージを作成する
    AKChickenGauge *chickenGauge = [AKChickenGauge node];
    
    // チキンゲージを情報レイヤーに配置する
    [infoLayer addChild:chickenGauge z:0 tag:kAKInfoTagChickenGauge];
    
    // チキンゲージの座標を設定する
    chickenGauge.position = ccp([AKScreenSize center].x,
                                [AKScreenSize positionFromBottomPoint:kAKChickenGaugePosFromBottomPoint]);
    
    // 残機表示を作成する
    AKLife *life = [AKLife node];
    
    // 残機表示を情報レイヤーに配置する
    [infoLayer addChild:life z:0 tag:kAKInfoTagLife];
    
    // 残機表示の座標を設定する
    life.position = ccp([AKScreenSize xOfStage:kAKLifePosXOfStage] + self.life.width / 2,
                        [AKScreenSize yOfStage:kAKLifePosYOfStage]);
    
    // スコア表示の文字列を作成する
    NSString *scoreString = [NSString stringWithFormat:kAKScoreFormat, 0];
    
    // スコア表示を作成する
    AKLabel *scoreLabel = [AKLabel labelWithString:scoreString
                                         maxLength:scoreString.length
                                           maxLine:1
                                             frame:kAKLabelFrameNone];
    
    // スコア表示を情報レイヤーに配置する
    [infoLayer addChild:scoreLabel z:0 tag:kAKInfoTagScore];
    
    // スコア表示の座標を設定する
    scoreLabel.position = ccp([AKScreenSize center].x,
                              [AKScreenSize yOfStage:kAKScorePosYOfStage]);
    
    AKLog(kAKLogPlayingScene_1, @"scoreLabel.position=(%f, %f)", scoreLabel.position.x, scoreLabel.position.y);
}

/*!
 @brief インターフェースレイヤー作成
 
 インターフェースレイヤーを作成する。レイヤーに配置するものも作成する。
 */
- (void)createInterface
{
    // インターフェースレイヤーを作成する
    AKPlayingSceneIF *interfaceLayer = [AKPlayingSceneIF node];
    
    // インターフェースレイヤーを画面に配置する
    [self addChild:interfaceLayer z:kAKLayerPosZInterface tag:kAKLayerPosZInterface];
}

/*!
 @brief 枠レイヤー作成
 
 枠レイヤーを作成する。
 */
- (void)createFrame
{
    AKLog(kAKLogPlayingScene_1, @"screen=(%f, %f) stage=(%f, %f)",
          [AKScreenSize screenSize].width,
          [AKScreenSize screenSize].height,
          [AKScreenSize stageSize].width,
          [AKScreenSize stageSize].height);
    
    // 左側の枠の座標を作成する
    float x = 0.0f;
    float y = 0.0f;
    float w = ([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2.0f;
    float h = [AKScreenSize screenSize].height;
    
    AKLog(kAKLogPlayingScene_1, @"左:(%f, %f, %f, %f)", x, y, w, h);
    
    // 左側の枠レイヤーを作成する
    [self addChild:AKCreateColorLayer(kAKColorLittleDark, CGRectMake(x, y, w, h))
                 z:kAKLayerPosZFrame
               tag:kAKLayerPosZFrame];
    

    // 右側の枠の座標を作成する
    x = [AKScreenSize center].x + [AKScreenSize stageSize].width / 2.0f;
    y = 0.0f;
    w = ([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2.0f;
    h = [AKScreenSize screenSize].height;
    
    AKLog(kAKLogPlayingScene_1, @"右:(%f, %f, %f, %f)", x, y, w, h);
    
    // 右側の枠レイヤーを作成する
    [self addChild:AKCreateColorLayer(kAKColorLittleDark, CGRectMake(x, y, w, h))
                 z:kAKLayerPosZFrame
               tag:kAKLayerPosZFrame];
    

    // 下側の枠の座標を作成する
    x = ([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2.0f;
    y = 0.0f;
    w = [AKScreenSize screenSize].width;
    h = [AKScreenSize yOfStage:0.0f];
    
    AKLog(kAKLogPlayingScene_1, @"下:(%f, %f, %f, %f)", x, y, w, h);
    
    // 下側の枠レイヤーを作成する
    [self addChild:AKCreateColorLayer(kAKColorLittleDark, CGRectMake(x, y, w, h))
                 z:kAKLayerPosZFrame
               tag:kAKLayerPosZFrame];
    
    // 上側の枠の座標を作成する
    x = ([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2.0f;
    y = [AKScreenSize yOfStage:0.0f] + [AKScreenSize stageSize].height;
    w = [AKScreenSize screenSize].width;
    h = [AKScreenSize yOfStage:0.0f];
    
    AKLog(kAKLogPlayingScene_1, @"上:(%f, %f, %f, %f)", x, y, w, h);
    
    // 高さがある場合は上側の枠レイヤーを作成する
    if (h > 0.0f) {
        [self addChild:AKCreateColorLayer(kAKColorLittleDark, CGRectMake(x, y, w, h))
                     z:kAKLayerPosZFrame
                   tag:kAKLayerPosZFrame];
    }
}

#pragma mark オブジェクト解放

/*!
 @brief オブジェクト解放処理
 
 メンバの解放を行う。
 */
- (void)dealloc
{
    AKLog(kAKLogPlayingScene_1, @"start");
    
    // メンバを解放する
    self.data = nil;
    
    // 未使用のスプライトフレームを解放する
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];

    // スーパークラスの処理を行う
    [super dealloc];

    AKLog(kAKLogPlayingScene_1, @"end");
}

#pragma mark アクセサ

/*!
 @brief ゲームプレイの状態設定
 
 ゲームプレイの状態を設定する。
 インターフェースの有効項目を変更する。
 @param state ゲームプレイの状態
 */
- (void)setState:(enum AKGameState)state
{
    // メンバに設定する
    state_ = state;
    
    // インターフェースの有効項目を変更する
    switch (state) {
        case kAKGameStatePlaying:   // プレイ中
            self.interfaceLayer.enableTag = kAKMenuTagPlaying;
            break;
            
        case kAKGameStatePause:     // 一時停止中
            self.interfaceLayer.enableTag = kAKMenuTagPause;
            break;
            
        case kAKGameStateQuitMenu:  // 終了メニュー
            self.interfaceLayer.enableTag = kAKMenuTagQuit;
            break;
            
        case kAKGameStateGameOver:  // ゲームオーバー
            self.interfaceLayer.enableTag = kAKMenuTagGameOver;
            break;
            
        default:                    // その他
            self.interfaceLayer.enableTag = 0;
            break;
    }
    
    // Root Viewを取得する
    AKNavigationController *viewController = (AKNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;

    // 広告バナーの表示・非表示を切り替える
    switch (state) {
        case kAKGameStatePreLoad:   // ゲームシーン読み込み前
        case kAKGameStatePlaying:   // プレイ中
            AKLog(kAKLogPlayingScene_1, @"広告バナーを非表示にする。:state=%d", state);
            // プレイ中は広告バナーを非表示にする
            [viewController hiddenAdBanner];
            break;
            
        case kAKGameStateStart:     // ゲーム開始時
        case kAKGameStateWait:      // アクション待機中
        case kAKGameStateSleep:     // スリープ処理中
            // 現在の状態を維持する
            break;
            
        default:                    // その他
            AKLog(kAKLogPlayingScene_1, @"広告バナーを表示する。:state=%d", state);
            // 広告バナーを表示する
            [viewController viewAdBanner];
            break;
    }
}

/*!
 @brief キャラクターレイヤー取得
 
 キャラクターレイヤーを取得する。
 @return キャラクターレイヤー
 */
- (CCLayer *)characterLayer
{
    NSAssert([self getChildByTag:kAKLayerPosZCharacter] != nil, @"レイヤーが作成されていない");
    return (CCLayer *)[self getChildByTag:kAKLayerPosZCharacter];
}

/*!
 @brief 情報レイヤー取得
 
 情報レイヤーを取得する。
 @return 情報レイヤー
 */
- (CCLayer *)infoLayer
{
    NSAssert([self getChildByTag:kAKLayerPosZInfo] != nil, @"レイヤーが作成されていない");
    return (CCLayer *)[self getChildByTag:kAKLayerPosZInfo];
}

/*!
 @brief インターフェースレイヤー取得
 
 インターフェースレイヤーを取得する。
 @return インターフェースレイヤー
 */
- (AKPlayingSceneIF *)interfaceLayer
{
    NSAssert([self getChildByTag:kAKLayerPosZInterface] != nil, @"レイヤーが作成されていない");
    return (AKPlayingSceneIF *)[self getChildByTag:kAKLayerPosZInterface];
}

/*!
 @brief チキンゲージ取得
 
 チキンゲージを取得する。
 @return チキンゲージ
 */
- (AKChickenGauge *)chickenGauge
{
    NSAssert([self.infoLayer getChildByTag:kAKInfoTagChickenGauge] != nil, @"ノードが作成されていない");
    return (AKChickenGauge *)[self.infoLayer getChildByTag:kAKInfoTagChickenGauge];
}

/*!
 @brief 残機表示取得
 
 残機表示取得を取得する。
 @return 残機表示取得
 */
- (AKLife *)life
{
    NSAssert([self.infoLayer getChildByTag:kAKInfoTagLife] != nil, @"ノードが作成されていない");
    return (AKLife *)[self.infoLayer getChildByTag:kAKInfoTagLife];
}

/*!
 @brief スコア表示取得
 
 スコア表示取得を取得する。
 @return スコア表示取得
 */
- (AKLabel *)score
{
    NSAssert([self.infoLayer getChildByTag:kAKInfoTagScore] != nil, @"ノードが作成されていない");
    return (AKLabel *)[self.infoLayer getChildByTag:kAKInfoTagScore];
}

/*!
 @brief ゲームオーバーかどうか
 
 ゲームオーバーかどうかを返す。
 現在の状態がゲームオーバー、または次の状態がゲームオーバーの場合はYESを返す。
 @return ゲームオーバーかどうか
 */
- (BOOL)isGameOver
{
    // 現在の状態がゲームオーバー、または次の状態がゲームオーバーの場合はYESを返す
    if (self.state == kAKGameStateGameOver || nextState_ == kAKGameStateGameOver) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark イベント処理

/*!
 @brief トランジション終了時の処理
 
 トランジション終了時の処理。
 トランジション途中でBGM再生等が行われないようにするため、
 トランジション終了後にゲーム開始の状態にする。
 */
- (void)onEnterTransitionDidFinish
{
    // ゲーム状態を開始時に変更する。
    self.state = kAKGameStateStart;
    
    // スーパークラスの処理を実行する
    [super onEnterTransitionDidFinish];
}

/*!
 @brief 自機の移動
 
 スライド入力によって自機を移動する。
 @param object メニュー項目
 */
- (void)movePlayer:(id)object
{
    NSAssert([object isKindOfClass:[AKMenuItem class]], @"メニュー項目のクラスが違う");
    
    // メニュー項目クラスにキャストする
    AKMenuItem *item = (AKMenuItem *)object;
    
    // 画面上のタッチ位置を取得する
    CGPoint locationInView = [item.touch locationInView:[item.touch view]];
    
    // cocos2dの座標系に変換する
    CGPoint location = [[CCDirector sharedDirector] convertToGL:locationInView];
    
    AKLog(kAKLogPlayingScene_2, @"prev=(%f, %f) location=(%f, %f)", item.prevPoint.x, item.prevPoint.y, location.x, location.y);
    
    // 自機を移動する
    [self.data movePlayerByDx:(location.x - item.prevPoint.x) * kAKPlayerMoveVal
                           dy:(location.y - item.prevPoint.y) * kAKPlayerMoveVal];
}

/*!
 @brief シールドボタン選択処理
 
 シールドボタン選択時にシールドを有効にする。
 選択解除時にシールドを解除する。
 @param object メニュー項目
 */
- (void)touchShieldButton:(id)object
{
    NSAssert([object isKindOfClass:[AKMenuItem class]], @"メニュー項目のクラスが違う");
    
    // メニュー項目クラスにキャストする
    AKMenuItem *item = (AKMenuItem *)object;
    
    // タッチのフェーズによって処理を分ける
    switch (item.touch.phase) {
        case UITouchPhaseBegan:     // タッチ開始
            // シールドモードを有効にする
            self.data.shield = YES;
            break;
            
        case UITouchPhaseCancelled: // タッチ取り消し
        case UITouchPhaseEnded:     // タッチ終了
            // シールドモードを無効にする
            self.data.shield = NO;
            break;
            
        default:                    // その他は無処理
            break;
    }
}

/*!
 @brief ポーズボタン選択処理
 
 ポーズボタン選択時の処理。一時停止メニューを表示し、ゲームの状態を一時停止状態に遷移する。
 @param object メニュー項目
 */
- (void)touchPauseButton:(id)object
{
    // [TODO]BGMを一時停止する
//    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];    

    // [TODO]一時停止効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKPauseSE];

    // ゲーム状態を一時停止に変更する
    self.state = kAKGameStatePause;
    
    // プレイデータのポーズ処理を行う
    [self.data pause];
}

/*!
 @brief 再開ボタン選択処理
 
 再開ボタン選択時の処理。再開ボタンをブリンクし、アクション完了時にゲーム再開処理が呼ばれるようにする。
 */
- (void)touchResumeButton:(id)object
{
    // 他の処理が動作しないように待機状態にする
    self.state = kAKGameStateWait;
    
    // ボタンのブリンクアクションを作成する
    CCBlink *blink = [CCBlink actionWithDuration:0.2f blinks:2];
    CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(resume)];
    CCSequence *action = [CCSequence actions:blink, callFunc, nil];
    
    // ボタンを取得する
    CCNode *button = self.interfaceLayer.resumeButton;
    
    // ブリンクアクションを開始する
    [button runAction:action];
    
    // [TODO]一時停止効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKPauseSE];
}

/*!
 @brief 終了ボタン選択処理
 
 終了ボタンが選択された時の処理を行う。
 効果音を鳴らし、終了ボタンをブリンクし、アクション完了時に終了メニュー表示処理が呼ばれるようにする。
 @param object メニュー項目
 */
- (void)touchQuitButton:(id)object
{
    // 他の処理が動作しないように待機状態にする
    self.state = kAKGameStateWait;
    
    // ボタンのブリンクアクションを作成する
    CCBlink *blink = [CCBlink actionWithDuration:0.2f blinks:2];
    CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(viewQuitMenu)];
    CCSequence *action = [CCSequence actions:blink, callFunc, nil];
    
    // ボタンを取得する
    CCNode *button = self.interfaceLayer.quitButton;
    
    // ブリンクアクションを開始する
    [button runAction:action];
    
    // [TODO]メニュー選択時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
}

/*!
 @brief 終了メニューYESボタン選択処理
 
 終了メニューでYESボタンが選択された時の処理を行う。
 効果音を鳴らし、タイトルシーンへと遷移する。
 @param object メニュー項目
 */
- (void)touchQuitYesButton:(id)object
{
    AKLog(kAKLogPlayingScene_1, @"start");
    
    // ハイスコアをファイルに保存する
    [self.data writeHiScore];
    
    // タイトルシーンへの遷移を作成する
    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:0.5f scene:[AKTitleScene node]];
    
    // タイトルシーンへと遷移する
    [[CCDirector sharedDirector] replaceScene:transition];    
}

/*!
 @brief 終了メニューNOボタン選択
 
 終了メニューのNOボタン選択時の処理。
 NOボタンをブリンクし、アクション完了時に一時停止メニュー表示処理が呼ばれるようにする。
 */
- (void)touchQuitNoButton:(id)object
{
    // 他の処理が動作しないように待機状態にする
    self.state = kAKGameStateWait;
    
    // ボタンのブリンクアクションを作成する
    CCBlink *blink = [CCBlink actionWithDuration:0.2f blinks:2];
    CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(viewPauseMenu)];
    CCSequence *action = [CCSequence actions:blink, callFunc, nil];
    
    // ボタンを取得する
    CCNode *button = self.interfaceLayer.quitNoButton;
    
    // ブリンクアクションを開始する
    [button runAction:action];
    
    // [TODO]メニュー選択時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
}

/*!
 @brief ツイートボタン選択処理
 
 ツイートボタンが選択された時の処理を行う。
 
 */
- (void)touchTweetButton:(id)object
{
    // [TODO]メニュー選択時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // ツイートビューを表示する
    [[AKTwitterHelper sharedHelper] viewTwitterWithInitialString:[data_ makeTweet]];
}

/*!
 @brief 更新処理
 
 ゲームの状態によって、更新処理を行う。
 @param dt フレーム更新間隔
 */
- (void)update:(ccTime)dt
{
    // ゲームの状態によって処理を分岐する
    switch (self.state) {
        case kAKGameStateStart:     // ゲーム開始時
            [self updateStart:dt];
            break;
            
        case kAKGameStatePlaying:   // プレイ中
            [self updatePlaying:dt];
            break;
            
        case kAKGameStateSleep:     // スリープ中
            [self updateSleep:dt];
            break;
            
        default:
            // その他の状態のときは変化はないため、無処理とする
            break;
    }
    
}

#pragma mark 更新処理

/*!
 @brief ゲーム開始時の更新処理
 
 ステージ定義ファイルを読み込み、敵を配置する。
 @param dt フレーム更新間隔
 */
- (void)updateStart:(ccTime)dt
{
    AKLog(kAKLogPlayingScene_1, @"start");
    
    // 開始ステージのスクリプトを読み込む
    [self.data readScript:kAKStartStage];
    
    // 状態をプレイ中へと進める
    self.state = kAKGameStatePlaying;
}

/*!
 @brief プレイ中の更新処理
 
 各キャラクターの移動処理、衝突判定を行う。
 @param dt フレーム更新間隔
 */
- (void)updatePlaying:(ccTime)dt
{
    // ゲームデータの更新を行う
    [self.data update:dt];
}

/*!
 @brief スリープ処理中の更新処理
 
 スリープ時間が経過したあと、次の状態へ遷移する。
 ゲームオーバーへの遷移の場合は遷移するまでプレイ中の状態更新を行う。
 @param dt フレーム更新間隔
 */
- (void)updateSleep:(ccTime)dt
{
    // スリープ時間をカウントする
    sleepTime_ -= dt;
    
    // スリープ時間が経過した時に次の状態へ遷移する
    if (sleepTime_ < 0.0f) {
        
        self.state = nextState_;
    }
    // まだスリープ時間が残っている場合
    else {
        
        // ゲームオーバーへの遷移の場合はプレイ中の状態を更新する
        if (nextState_ == kAKGameStateGameOver) {
            [self updatePlaying:dt];
        }
    }
}

#pragma mark AKPlayDataからのシーン操作用

/*!
 @brief シールドボタン表示切替
 
 シールドボタンの表示を選択・非選択状態で切り替えを行う。
 @param seleted 選択状態かどうか
 */
- (void)setShieldButtonSelected:(BOOL)selected
{
    [self.interfaceLayer setShieldButtonSelected:selected];
}

/*!
 @brief スコアラベル更新
 
 スコアラベルの文字列を更新する。
 @param score スコア
 */
- (void)setScoreLabel:(NSInteger)score
{
    // ラベルに設定する文字列を作成する
    NSString *string = [NSString stringWithFormat:kAKScoreFormat, score];
    
    // ラベルの文字列を変更する
    [self.score setString:string];
}

/*!
 @brief ゲームオーバー
 
 ゲームオーバー時はBGMをOFFにし、一定時間待機する。
 待機後はゲームオーバーのラベルとコントロールを有効にする。
 ここでは状態を待機中、次の状態をゲームオーバーに設定する。
 */
- (void)gameOver
{
    AKLog(kAKLogPlayingScene_1, @"start");
    
    // 状態を待機中へ遷移する
    self.state = kAKGameStateSleep;
    
    // 待機後の状態をゲームオーバーに設定する
    nextState_ = kAKGameStateGameOver;
    
    // 待機時間を設定する
    sleepTime_ = kAKGameOverWaitTime;

    AKLog(kAKLogPlayingScene_1, @"end");
}

#pragma mark プライベートメソッド 

/*!
 @brief ゲーム再開
 
 一時停止中の状態からゲームを再会する。
 */
- (void)resume
{
    // 一時停止中から以外の変更の場合はエラー
    NSAssert(self.state == kAKGameStateWait, @"状態遷移異常");
    
    // [TODO]一時停止したBGMを再開する
//    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    
    // ゲーム状態をプレイ中に変更する
    self.state = kAKGameStatePlaying;
    
    // プレイデータのゲーム再開処理を行う
    [self.data resume];
}

/*!
 @brief 終了メニュー表示
 
 ゲームの状態を終了メニュー表示中に遷移する。
 */
- (void)viewQuitMenu
{
    // ゲーム状態を終了メニュー表示中に遷移する
    self.state = kAKGameStateQuitMenu;
}

/*!
 @brief 一時停止メニュー表示
 
 ゲームの状態を一時停止中に遷移する。
 */
- (void)viewPauseMenu
{
    // ゲーム状態を一時停止中に遷移する
    self.state = kAKGameStatePause;
}
@end

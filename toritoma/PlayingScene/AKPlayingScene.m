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
#import "AppDelegate.h"

/// レイヤーのz座標、タグの値にも使用する
enum {
    kAKLayerPosZBack = 0,   ///< 背景レイヤー
    kAKLayerPosZCharacter,  ///< キャラクターレイヤー
    kAKLayerPosZFrameBack,  ///< 枠背景レイヤー
    kAKLayerPosZFrameBar,   ///< 枠棒レイヤー
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

//======================================================================
// 動作に関する定数
//======================================================================
/// 自機移動をスライド量の何倍にするか
static const float kAKPlayerMoveVal = 1.8f;
/// 開始ステージ番号
static const NSInteger kAKStartStage = 1;
/// ゲームオーバー時の待機フレーム数
static const NSInteger kAKGameOverWaitFrame = 60;

//======================================================================
// コントロールの表示に関する定数
//======================================================================
/// チキンゲージ配置位置、下からの座標
static const float kAKChickenGaugePosFromBottomPoint = 12.0f;
/// 残機表示の位置、ステージ座標x座標
static const float kAKLifePosXOfStage = 4.0f;
/// 残機表示の位置、ステージ座標y座標
static const float kAKLifePosYOfStage = 272.0f;
/// スコアの表示位置、ステージ座標y座標
static const float kAKScorePosYOfStage = 272.0f;
/// スコア表示のフォーマット
static NSString *kAKScoreFormat = @"SCORE:%06d";

//======================================================================
// 枠の表示に関する定数
//======================================================================
/// 枠背景1ブロックのサイズ
static const NSInteger kAKFrameBackSize = 32;
/// 枠棒1ブロックのサイズ
static const NSInteger kAKFrameBarSize = 8;
/// 枠背景の画像名
static NSString *kAKFrameBackName = @"FrameBack.png";
/// 枠棒左の画像名
static NSString *kAKFrameBarLeft = @"FrameLeft.png";
/// 枠棒右の画像名
static NSString *kAKFrameBarRight = @"FrameRight.png";
/// 枠棒上の画像名
static NSString *kAKFrameBarTop = @"FrameTop.png";
/// 枠棒下の画像名
static NSString *kAKFrameBarBottom = @"FrameBottom.png";
/// 枠棒左上の画像名
static NSString *kAKFrameBarLeftTop = @"FrameLeftTop.png";
/// 枠棒左下の画像名
static NSString *kAKFrameBarLeftBottom = @"FrameLeftBottom.png";
/// 枠棒右上の画像名
static NSString *kAKFrameBarRightTop = @"FrameRightTop.png";
/// 枠棒右下の画像名
static NSString *kAKFrameBarRightBottom = @"FrameRightBottom.png";

// プライベートメソッド宣言
@interface AKPlayingScene ()
// 背景レイヤー作成
- (void)createBackGround;
// キャラクターレイヤー作成
- (void)createCharacterLayer;
// 情報レイヤー作成
- (void)createInfoLayer;
// インターフェースレイヤー作成
- (void)createInterface;
// 枠レイヤー作成
- (void)createFrame;
// 枠背景作成
- (void)createFrameBack;
// 枠の棒作成
- (void)createFrameBar;
// 枠ブロック配置
- (void)createFrameBlockAtNode:(CCNode *)node name:(NSString *)name size:(NSInteger)size rect:(CGRect)rect;
// ツイートボタン選択処理
- (void)touchTweetButton:(id)object;
// ゲーム開始時の更新処理
- (void)updateStart;
// プレイ中の更新処理
- (void)updatePlaying;
// スリープ処理中の更新処理
- (void)updateSleep;
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

#pragma mark オブジェクト生成/解放

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
    
    // スリープフレーム数を初期化する
    sleepFrame_ = 0;
    
    // ゲームデータを生成する
    self.data = [[[AKPlayData alloc] initWithScene:self] autorelease];

    // 更新処理開始
    [self scheduleUpdate];
    
    AKLog(kAKLogPlayingScene_1, @"end");
    return self;
}

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
    
    // AppDelegateを取得する
    NSAssert([[[UIApplication sharedApplication] delegate] isKindOfClass:[AppController class]], @"");
    AppController *app = (AppController *)[[UIApplication sharedApplication] delegate];
    
    // バックグラウンドで実行中にプレイ中に遷移した場合はバックグラウンド移行処理を行う
    if (app.isBackGround && state == kAKGameStatePlaying) {
        AKLog(kAKLogPlayingScene_0, @"バックグラウンドで実行中にプレイ中に遷移した");
        [self onDidEnterBackground];
    }
}

/*!
 @brief 背景レイヤー取得
 
 背景レイヤーを取得する。
 @return 背景レイヤー
 */
- (CCLayer *)backgroundLayer
{
    NSAssert([self getChildByTag:kAKLayerPosZBack] != nil, @"レイヤーが作成されていない");
    return (CCLayer *)[self getChildByTag:kAKLayerPosZBack];
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
 @brief バックグラウンド移行処理
 
 バックグラウンドに移行したときの処理を行う。
 ゲームプレイ中にバックグラウンドに移行したときは一時停止する。
 */
- (void)onDidEnterBackground
{
    // ゲームプレイ中の場合は一時停止状態にする
    if (self.state == kAKGameStatePlaying) {
        
        // TODO:BGMを一時停止する
//    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        
        // ゲーム状態を一時停止に変更する
        self.state = kAKGameStatePause;
        
        // プレイデータのポーズ処理を行う
        [self.data pause];
    }
    
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
    // TODO:BGMを一時停止する
//    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];    

    // TODO:一時停止効果音を鳴らす
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
    
    // TODO:一時停止効果音を鳴らす
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
    
    // TODO:メニュー選択時の効果音を鳴らす
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
    
    // TODO:メニュー選択時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
}

/*!
 @brief ツイートボタン選択処理
 
 ツイートボタンが選択された時の処理を行う。
 
 */
- (void)touchTweetButton:(id)object
{
    // TODO:メニュー選択時の効果音を鳴らす
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
            [self updateStart];
            break;
            
        case kAKGameStatePlaying:   // プレイ中
            [self updatePlaying];
            break;
            
        case kAKGameStateSleep:     // スリープ中
            [self updateSleep];
            break;
            
        default:
            // その他の状態のときは変化はないため、無処理とする
            break;
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
    
    // 待機フレーム数を設定する
    sleepFrame_ = kAKGameOverWaitFrame;

    AKLog(kAKLogPlayingScene_1, @"end");
}

#pragma mark プライベートメソッド_インスタンス初期化

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
    
    // 枠の背景を作成する
    [self createFrameBack];
    
    // 枠の棒を作成する
    [self createFrameBar];
}

/*!
 @brief 枠背景作成
 
 枠の背景部分を作成する。
 */
- (void)createFrameBack
{
    // 枠の背景用バッチノードを作成する
    CCSpriteBatchNode *frameBackBatch = [CCSpriteBatchNode batchNodeWithFile:kAKControlTextureAtlasFile];
    
    // ブロックサイズをデバイスに合わせて計算する
    NSInteger frameBackSize = [AKScreenSize deviceLength:kAKFrameBackSize];
    
    // 左側の枠の座標を作成する
    CGRect rect = CGRectMake(0.0f,
                             0.0f,
                             ([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2.0f,
                             [AKScreenSize screenSize].height);
    
    // 右端揃えにするため、ブロックのはみ出している分だけ左にずらす
    if ((NSInteger)rect.size.width % frameBackSize > 0) {
        rect.origin.x -= frameBackSize - (NSInteger)rect.size.width % frameBackSize;
        rect.size.width += frameBackSize - (NSInteger)rect.size.width % frameBackSize;
    }
    
    // ステージの下端に揃えるため、ブロックのはみ出している分だけ下にずらす
    if ((NSInteger)[AKScreenSize yOfStage:0.0f] % frameBackSize > 0) {
        rect.origin.y -= frameBackSize - (NSInteger)[AKScreenSize yOfStage:0.0f] % frameBackSize;
        rect.size.height += frameBackSize - (NSInteger)[AKScreenSize yOfStage:0.0f] % frameBackSize;
    }
    
    // 枠背景のブロックを配置する
    [self createFrameBlockAtNode:frameBackBatch name:kAKFrameBackName size:frameBackSize rect:rect];
    
    // 右側の枠の座標を作成する
    rect = CGRectMake([AKScreenSize center].x + [AKScreenSize stageSize].width / 2,
                      0.0f,
                      ([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2,
                      [AKScreenSize screenSize].height);
    
    // ステージの下端に揃えるため、ブロックのはみ出している分だけ下にずらす
    if ((NSInteger)[AKScreenSize yOfStage:0.0f] % frameBackSize > 0) {
        rect.origin.y -= frameBackSize - (NSInteger)[AKScreenSize yOfStage:0.0f] % frameBackSize;
        rect.size.height += frameBackSize - (NSInteger)[AKScreenSize yOfStage:0.0f] % frameBackSize;
    }

    // 枠背景のブロックを配置する
    [self createFrameBlockAtNode:frameBackBatch name:kAKFrameBackName size:frameBackSize rect:rect];
    
    // 下側の枠の座標を作成する
    rect = CGRectMake(([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2.0f,
                      0.0f,
                      [AKScreenSize screenSize].width,
                      [AKScreenSize yOfStage:0.0f]);
    
    // 上端揃えにするため、ブロックのはみ出している分だけ下にずらす
    if ((NSInteger)rect.size.height % frameBackSize > 0) {
        rect.origin.y -= frameBackSize - (NSInteger)rect.size.height % frameBackSize;
        rect.size.height += frameBackSize - (NSInteger)rect.size.height % frameBackSize;
    }
    
    // 枠背景のブロックを配置する
    [self createFrameBlockAtNode:frameBackBatch name:kAKFrameBackName size:frameBackSize rect:rect];
    
    // 上側の枠の座標を作成する
    rect = CGRectMake(([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2.0f,
                      [AKScreenSize yOfStage:0.0f] + [AKScreenSize stageSize].height,
                      [AKScreenSize screenSize].width,
                      [AKScreenSize screenSize].height - [AKScreenSize stageSize].height - [AKScreenSize yOfStage:0.0f]);
    
    // 高さがある場合は上側の枠レイヤーを作成する
    if (rect.size.height > 0.0f) {
        [self createFrameBlockAtNode:frameBackBatch name:kAKFrameBackName size:frameBackSize rect:rect];
    }
    
    // 枠の背景用バッチノードをシーンに配置する
    [self addChild:frameBackBatch z:kAKLayerPosZFrameBack tag:kAKLayerPosZFrameBack];
}

/*!
 @brief 枠棒作成
 
 枠の棒の部分を作成する。
 */
- (void)createFrameBar
{
    // 枠の棒用バッチノードを作成する
    CCSpriteBatchNode *frameBarBatch = [CCSpriteBatchNode batchNodeWithFile:kAKControlTextureAtlasFile];
    
    // ブロックサイズをデバイスに合わせて計算する
    NSInteger frameBarSize = [AKScreenSize deviceLength:kAKFrameBarSize];
    
    // 左側の棒の位置を決定する
    CGRect rect = CGRectMake([AKScreenSize xOfStage:0.0f] - frameBarSize,
                             [AKScreenSize yOfStage:0.0f],
                             frameBarSize,
                             [AKScreenSize stageSize].height);
    
    // 左側の棒を配置する
    [self createFrameBlockAtNode:frameBarBatch name:kAKFrameBarLeft size:frameBarSize rect:rect];
    
    // 右側の棒の位置を決定する
    rect = CGRectMake([AKScreenSize xOfStage:0.0f] + [AKScreenSize stageSize].width,
                      [AKScreenSize yOfStage:0.0f],
                      frameBarSize,
                      [AKScreenSize stageSize].height);
    
    // 右側の棒を配置する
    [self createFrameBlockAtNode:frameBarBatch name:kAKFrameBarRight size:frameBarSize rect:rect];
    
    // 下側の棒の位置を決定する
    rect = CGRectMake([AKScreenSize xOfStage:0.0f],
                      [AKScreenSize yOfStage:0.0f] - frameBarSize,
                      [AKScreenSize stageSize].width,
                      frameBarSize);
    
    // 下側の棒を配置する
    [self createFrameBlockAtNode:frameBarBatch name:kAKFrameBarBottom size:frameBarSize rect:rect];
    
    // 左下の棒の位置を決定する
    rect = CGRectMake([AKScreenSize xOfStage:0.0f] - frameBarSize,
                      [AKScreenSize yOfStage:0.0f] - frameBarSize,
                      frameBarSize,
                      frameBarSize);
    
    // 左下の棒を配置する
    [self createFrameBlockAtNode:frameBarBatch name:kAKFrameBarLeftBottom size:frameBarSize rect:rect];
    
    // 右下の棒の位置を決定する
    rect = CGRectMake([AKScreenSize xOfStage:0.0f] + [AKScreenSize stageSize].width,
                      [AKScreenSize yOfStage:0.0f] - frameBarSize,
                      frameBarSize,
                      frameBarSize);
    
    // 右下の棒を配置する
    [self createFrameBlockAtNode:frameBarBatch name:kAKFrameBarRightBottom size:frameBarSize rect:rect];

    // 上側の棒の位置を決定する
    rect = CGRectMake([AKScreenSize xOfStage:0.0f],
                      [AKScreenSize yOfStage:0.0f] + [AKScreenSize stageSize].height,
                      [AKScreenSize stageSize].width,
                      frameBarSize);

    // 上側に棒を配置する隙間がある場合
    if (rect.origin.y < [AKScreenSize screenSize].height) {
        
        // 上側の棒を配置する
        [self createFrameBlockAtNode:frameBarBatch name:kAKFrameBarTop size:frameBarSize rect:rect];

        // 左上の棒の位置を決定する
        rect = CGRectMake([AKScreenSize xOfStage:0.0f] - frameBarSize,
                          [AKScreenSize yOfStage:0.0f] + [AKScreenSize stageSize].height,
                          frameBarSize,
                          frameBarSize);
        
        // 左上の棒を配置する
        [self createFrameBlockAtNode:frameBarBatch name:kAKFrameBarLeftTop size:frameBarSize rect:rect];
        
        // 右上の棒の位置を決定する
        rect = CGRectMake([AKScreenSize xOfStage:0.0f] + [AKScreenSize stageSize].width,
                          [AKScreenSize yOfStage:0.0f] + [AKScreenSize stageSize].height,
                          frameBarSize,
                          frameBarSize);
        
        // 右上の棒を配置する
        [self createFrameBlockAtNode:frameBarBatch name:kAKFrameBarRightTop size:frameBarSize rect:rect];
    }
    
    // 枠の棒用バッチノードをシーンに配置する
    [self addChild:frameBarBatch z:kAKLayerPosZFrameBar tag:kAKLayerPosZFrameBar];
}

/*!
 @brief 枠背景ブロック配置
 
 指定された範囲に枠背景のブロックを配置する。
 @param node 配置先のノード
 @param name ブロックの画像名
 @param size 1ブロックのサイズ
 @param rect 配置先の範囲
 */
- (void)createFrameBlockAtNode:(CCNode *)node name:(NSString *)name size:(NSInteger)size rect:(CGRect)rect
{
    AKLog(kAKLogPlayingScene_3, @"w=%f, h=%f", rect.size.width, rect.size.height);
        
    // 枠の背景ブロックを指定範囲に敷き詰める
    for (int y = rect.origin.y; y < rect.origin.y + rect.size.height; y += size) {
        for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x += size) {
            
            AKLog(kAKLogPlayingScene_3, @"x=%d, y=%d", x, y);
            
            // 背景ブロック画像のスプライトを作成する
            CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:name];
            
            // 位置を設定する
            // 左下を(0, 0)に合うようにするため、サイズの半分ずらす
            sprite.position = ccp(x + size / 2, y + size / 2);
            
            // 背景ブロックをノードに配置する
            [node addChild:sprite];
        }
    }
}

#pragma mark プライベートメソッド_更新処理

/*!
 @brief ゲーム開始時の更新処理
 
 ステージ定義ファイルを読み込み、敵を配置する。
 */
- (void)updateStart
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
 */
- (void)updatePlaying
{
    // ゲームデータの更新を行う
    [self.data update];
}

/*!
 @brief スリープ処理中の更新処理
 
 スリープ時間が経過したあと、次の状態へ遷移する。
 ゲームオーバーへの遷移の場合は遷移するまでプレイ中の状態更新を行う。
 */
- (void)updateSleep
{
    // スリープフレーム数をカウントする
    sleepFrame_--;
    
    // スリープフレーム数が経過した時に次の状態へ遷移する
    if (sleepFrame_ <= 0) {
        
        self.state = nextState_;
    }
    // まだスリープ時間が残っている場合
    else {
        
        // ゲームオーバーへの遷移の場合はプレイ中の状態を更新する
        if (nextState_ == kAKGameStateGameOver) {
            [self updatePlaying];
        }
    }
}

#pragma mark プライベートメソッド_状態遷移

/*!
 @brief ゲーム再開
 
 一時停止中の状態からゲームを再会する。
 */
- (void)resume
{
    // 一時停止中から以外の変更の場合はエラー
    NSAssert(self.state == kAKGameStateWait, @"状態遷移異常");
    
    // TODO:一時停止したBGMを再開する
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

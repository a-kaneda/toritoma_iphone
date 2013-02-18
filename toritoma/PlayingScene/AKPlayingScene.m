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

/// プレイ中メニュー項目のタグ
static const NSUInteger kAKMenuTagPlaying = 0x01;
/// 自機移動をスライド量の何倍にするか
static const float kAKPlayerMoveVal = 1.8f;
/// 開始ステージ番号
static const NSInteger kAKStartStage = 1;
/// チキンゲージ配置位置、下からの比率
static const float kAKChickenGaugePosFromBottomPoint = 18.0f;
/// コントロールテクスチャアトラス定義ファイル名
static NSString *kAKTextureAtlasDefFile = @"Control.plist";
/// コントロールテクスチャアトラスファイル名
static NSString *kAKTextureAtlasFile = @"Control.png";
/// シールドボタン配置位置、右からの座標
static const float kAKShieldButtonPosFromRightPoint = 50.0f;
/// シールドボタン配置位置、下からの座標
static const float kAKShieldButtonPosFromBottomPoint = 50.0f;
/// シールドボタン非選択時の画像名
static NSString *kAKShiledButtonNoSelectImage = @"ShieldButton_01.png";
/// シールドボタン選択時の画像名
static NSString *kAKShiledButtonSelectedImage = @"ShieldButton_02.png";

/*!
 @brief プレイシーンクラス
 
 プレイ中画面のシーンを管理する。
 */
@implementation AKPlayingScene

@synthesize data = data_;
@synthesize chickenGauge = chickenGauge_;
@synthesize shieldButton = shieldButton_;

/*!
 @brief オブジェクト初期化処理
 
 オブジェクトの初期化を行う。
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    AKLog(1, @"start");
    
    // スーパークラスの処理を行う
    self = [super init];
    if (!self) {
        AKLog(1, @"error");
        return nil;
    }
    
    // 状態をシーン読み込み前に設定する
    self.state = kAKGameStatePreLoad;
    
    // テクスチャアトラスを読み込む
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kAKTextureAtlasDefFile textureFilename:kAKTextureAtlasFile];

    // 背景レイヤーを作成する
    [self addChild:AKCreateBackColorLayer() z:kAKLayerPosZBack tag:kAKLayerPosZBack];
    
    // キャラクターを配置するレイヤーを作成する
    CCLayer *characterLayer = [CCLayer node];
    
    // キャラクターレイヤーを画面に配置する
    [self addChild:characterLayer z:kAKLayerPosZCharacter tag:kAKLayerPosZCharacter];
    
    // 情報レイヤーを作成する
    CCLayer *infoLayer = [CCLayer node];
    
    // 情報レイヤーを画面に配置する
    [self addChild:infoLayer z:kAKLayerPosZInfo tag:kAKLayerPosZInfo];
    
    // チキンゲージを作成する
    self.chickenGauge = [AKChickenGauge node];
    
    // チキンゲージを画面に情報レイヤーに配置する
    [infoLayer addChild:self.chickenGauge];
    
    // チキンゲージの座標を設定する
    self.chickenGauge.position = ccp([AKScreenSize center].x,
                                     [AKScreenSize positionFromBottomPoint:kAKChickenGaugePosFromBottomPoint]);
    
    // インターフェースレイヤーを作成する
    AKInterface *interfaceLayer = [AKInterface node];
    
    // インターフェースレイヤーを画面に配置する
    [self addChild:interfaceLayer z:kAKLayerPosZInterface tag:kAKLayerPosZInterface];
    
    // シールドボタンを作成する
    self.shieldButton = [interfaceLayer addMenuWithSpriteFrame:kAKShiledButtonNoSelectImage
                                                         atPos:ccp([AKScreenSize positionFromRightPoint:kAKShieldButtonPosFromRightPoint],
                                                                   [AKScreenSize positionFromBottomPoint:kAKShieldButtonPosFromBottomPoint])
                                                        action:@selector(touchShieldButton:)
                                                             z:0
                                                           tag:kAKMenuTagPlaying type:kAKMenuTypeMomentary];
    
    // スライド入力を画面全体に配置する
    [interfaceLayer addSlideMenuWithRect:CGRectMake(0.0f, 0.0f, [AKScreenSize screenSize].width, [AKScreenSize screenSize].height)
                                  action:@selector(movePlayer:)
                                     tag:kAKMenuTagPlaying];
    
    interfaceLayer.enableTag = 0xFFFFFFFF;
    
    // 左側の枠レイヤーを作成する
    [self addChild:AKCreateColorLayer(kAKColorLittleDark,
                                      CGRectMake(0.0f,
                                                 0.0f,
                                                 ([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2.0f,
                                                 [AKScreenSize screenSize].height))
                 z:kAKLayerPosZFrame
               tag:kAKLayerPosZFrame];
    
    // 右側の枠レイヤーを作成する
    [self addChild:AKCreateColorLayer(kAKColorLittleDark,
                                      CGRectMake([AKScreenSize positionFromHorizontalCenterPoint:[AKScreenSize stageSize].width / 2.0f],
                                                 0.0f,
                                                 ([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2.0f,
                                                 [AKScreenSize screenSize].height))
                 z:kAKLayerPosZFrame
               tag:kAKLayerPosZFrame];
    
    // 下側の枠レイヤーを作成する
    [self addChild:AKCreateColorLayer(kAKColorLittleDark,
                                      CGRectMake(([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2.0f,
                                                 0.0f,
                                                 [AKScreenSize screenSize].width,
                                                 [AKScreenSize screenSize].height - [AKScreenSize stageSize].height))
                 z:kAKLayerPosZFrame
               tag:kAKLayerPosZFrame];
    
    // ゲームデータを生成する
    self.data = [[[AKPlayData alloc] initWithScene:self] autorelease];

    // 更新処理開始
    [self scheduleUpdate];
    
    AKLog(1, @"end");
    return self;
}

/*!
 @brief オブジェクト解放処理
 
 メンバの解放を行う。
 */
- (void)dealloc
{
    AKLog(1, @"start");
    
    // メンバを解放する
    self.data = nil;
    [self.chickenGauge removeFromParentAndCleanup:YES];
    self.chickenGauge = nil;
    [self.shieldButton removeFromParentAndCleanup:YES];
    self.shieldButton = nil;
    
    // 未使用のスプライトフレームを解放する
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];

    // スーパークラスの処理を行う
    [super dealloc];

    AKLog(1, @"end");
}

/*!
 @brief ゲームプレイの状態取得
 
 ゲームプレイの状態を取得する。
 @return ゲームプレイの状態
 */
- (enum AKGameState)state
{
    return state_;
}

/*!
 @brief ゲームプレイの状態設定
 
 ゲームプレイの状態を設定する。
 @param state ゲームプレイの状態
 */
- (void)setState:(enum AKGameState)state
{
    state_ = state;
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
            
        default:
            // その他の状態のときは変化はないため、無処理とする
            break;
    }
    
}

/*!
 @brief ゲーム開始時の更新処理
 
 ステージ定義ファイルを読み込み、敵を配置する。
 @param dt フレーム更新間隔
 */
- (void)updateStart:(ccTime)dt
{
    AKLog(1, @"start");
    
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

    AKLog(0, @"prev=(%f, %f) location=(%f, %f)", item.prevPoint.x, item.prevPoint.y, location.x, location.y);
    
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
 @brief シールドボタン表示切替
 
 シールドボタンの表示を選択・非選択状態で切り替えを行う。
 @param seleted 選択状態かどうか
 */
- (void)setShieldButtonSelected:(BOOL)selected
{
    // 選択中かどうかで画像を切り替える
    if (selected) {
        [self.shieldButton setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kAKShiledButtonSelectedImage]];
    }
    else {
        [self.shieldButton setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kAKShiledButtonNoSelectImage]];
    }
}

@end

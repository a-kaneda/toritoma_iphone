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

/// キャラクターテクスチャアトラス定義ファイル名
NSString *kAKTextureAtlasDefFile = @"Character.plist";
/// キャラクターテクスチャアトラスファイル名
NSString *kAKTextureAtlasFile = @"Character.png";

/// プレイ中メニュー項目のタグ
static const NSUInteger kAKMenuTagPlaying = 0x01;
/// 自機移動をスライド量の何倍にするか
static const float kAKPlayerMoveVal = 1.8f;
/// 開始ステージ番号
static const NSInteger kAKStartStage = 1;
/// チキンゲージ配置位置、下からの比率
static const float kAKChickenGaugePosFromBottomPoint = 18.0f;

/*!
 @brief プレイシーンクラス
 
 プレイ中画面のシーンを管理する。
 */
@implementation AKPlayingScene

@synthesize data = data_;
@synthesize chickenGauge = chickenGauge_;

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
 
 オブジェクトの解放を行う。
 */
- (void)dealloc
{
    AKLog(1, @"start");
    
    // メンバを解放する
    self.data = nil;
    [self.chickenGauge removeFromParentAndCleanup:YES];
    self.chickenGauge = nil;

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
 @brief キャラクターイメージの追加
 
 キャラクターイメージのキャラクターレイヤーに追加する。
 @param image キャラクターイメージ
 */
- (void)addCharacterImage:(CCSprite *)image
{
    [self.characterLayer addChild:image];
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
@end

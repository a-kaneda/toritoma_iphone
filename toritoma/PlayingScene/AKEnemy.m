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
 @file AKEnemy.m
 @brief 敵クラス定義
 
 敵キャラクターのクラスの定義をする。
 */

#import "AKEnemy.h"
#import "AKEnemyShot.h"

/// 画像名のフォーマット
static NSString *kAKImageNameFormat = @"Enemy_%02d";
/// 敵の種類
enum AKEnemyType {
    kAKEnemyDragonfly = 1,              ///< トンボ
    kAKEnemyAnt = 2,                    ///< アリ
    kAKEnemyButterfly = 3,              ///< チョウ
    kAKEnemyLadybug = 4,                ///< テントウムシ
    kAKEnemyBagworm = 11,               ///< ミノムシ
    kAKEnemyCicada= 12,                 ///< セミ
    kAKEnemyGrasshopper = 13,           ///< バッタ
    kAKEnemyHornet = 14,                ///< ハチ
    kAKEnemyCockroach = 21,             ///< ゴキブリ
    kAKEnemySnail = 22,                 ///< カタツムリ
    kAKEnemyStagBeetle = 23,            ///< クワガタ
    kAKEnemyRhinocerosBeetle = 31,      ///< カブトムシ
    kAKEnemyMantis = 32,                ///< カマキリ
    kAKEnemyHoneycomb = 33,             ///< ハチの巣
    kAKEnemySpider = 34,                ///< クモ
    kAKEnemyCentipedeHead = 35,         ///< ムカデ（頭）
    kAKEnemyCentipedeBody = 36,         ///< ムカデ（胴体）
    kAKEnemyCentipedeTail = 37,         ///< ムカデ（尾）
    kAKEnemyMaggot = 38,                ///< ウジ
    kAKEnemyFly = 39                    ///< ハエ
    };
/// 敵の種類の数
static const NSInteger kAKEnemyDefCount = 40;

/// 敵の定義
static const struct AKEnemyDef kAKEnemyDef[kAKEnemyDefCount] = {
    //破壊,画像,フレーム数,フレーム間隔,幅,高さ,HP,スコア
    {1, 1, 2, 30, 32, 32, 0, 0, 3, 100},    // トンボ
    {1, 2, 2, 30, 32, 16, 0, 0, 3, 100},    // アリ
    {1, 3, 2, 30, 32, 32, 0, 0, 3, 100},    // チョウ
    {1, 4, 2, 6, 32, 32, 0, 0, 5, 100},     // テントウムシ
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備5
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備6
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備7
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備8
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備9
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備10
    {1, 11, 1, 0, 32, 32, 0, 0, 10, 100},   // ミノムシ
    {1, 12, 1, 0, 32, 32, 0, 0, 5, 100},    // セミ
    {1, 13, 1, 0, 32, 32, 0, 0, 3, 100},    // バッタ
    {1, 14, 2, 6, 32, 32, 0, 0, 5, 100},    // ハチ
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備15
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備16
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備17
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備18
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備19
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備20
    {1, 21, 2, 6, 32, 32, 0, 0, 5, 100},    // ゴキブリ
    {1, 22, 2, 30, 32, 32, 0, 0, 5, 100},   // カタツムリ
    {1, 23, 2, 6, 32, 32, 0, 0, 5, 100},    // クワガタ
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備24
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備25
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備26
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備27
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備28
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備29
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // 予備30
    {1, 31, 2, 3, 64, 40, 0, 0, 1000, 10000},   // カブトムシ
    {1, 32, 0, 0, 64, 64, 0, 0, 1000, 10000},   // カマキリ
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // ハチの巣
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // クモ
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // ムカデ（頭）
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // ムカデ（胴体）
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // ムカデ（尾）
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // ウジ
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},         // ハエ
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}          // 予備40
};

/*!
 @brief 敵クラス
 
 敵キャラクターのクラス。
 */
@implementation AKEnemy

/*!
 @brief キャラクター固有の動作

 生成時に指定されたセレクタを呼び出す。
 @param data ゲームデータ
 */
- (void)action:(id<AKPlayDataInterface>)data
{
    // 動作開始からのフレーム数をカウントする
    frame_++;
        
    // 敵種別ごとの処理を実行
    [self performSelector:action_ withObject:data];
}

/*!
 @brief 破壊処理

 HPが0になったときに敵種別固有の破壊処理を呼び出す。
 @param data ゲームデータ
 */
- (void)destroy:(id<AKPlayDataInterface>)data
{
    // 破壊時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKHitSE];
    
    // スコアを加算する
    [data addScore:score_];
    
    // 進行度を進める
    [data addProgress:progress_];
    
    // 敵種別ごとの処理を実行
    [self performSelector:destroy_ withObject:data];
    
    // 画像の解放
    [self.image removeFromParentAndCleanup:YES];
    self.image = nil;
    
    // スーパークラスの処理を行う
    [super destroy:data];
}

/*!
 @brief 生成処理

 敵キャラを生成する。
 @param type 敵キャラの種別
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param progress 倒した時に進む進行度
 @param parent 敵キャラを配置する親ノード
 */
- (void)createEnemyType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y progress:(NSInteger)progress parent:(CCNode *)parent
{
    // パラメータの内容をメンバに設定する
    self.positionX = x;
    self.positionY = y;
    progress_ = progress;
    
    // 配置フラグを立てる
    isStaged_ = YES;
    
    // 各メンバ変数を初期化する
    frame_ = 0;
    state_ = 0;
    for (int i = 0; i < kAKEnemyWorkCount; i++) {
        work_[i] = 0;
    }
    
    AKLog(type < 0 || type > kAKEnemyDefCount, @"敵の種類の値が範囲外:%d", type);
    NSAssert(type > 0 && type <= kAKEnemyDefCount, @"敵の種類の値が範囲外");
    
    // 動作処理を設定する
    action_ = [self actionSelector:type];
    
    // 破壊処理を設定する
    destroy_ = [self destroySeletor:kAKEnemyDef[type - 1].destroy];
        
    // 画像名を作成する
    self.imageName = [NSString stringWithFormat:kAKImageNameFormat, kAKEnemyDef[type - 1].image];
    AKLog(1, @"self.imageName = %@", self.imageName);
                
    // アニメーションフレームの個数を設定する
    self.animationPattern = kAKEnemyDef[type - 1].animationFrame;
    
    // アニメーションフレーム間隔を設定する
    self.animationInterval = kAKEnemyDef[type - 1].animationInterval;
    
    // 当たり判定のサイズを設定する
    self.width = kAKEnemyDef[type - 1].hitWidth;
    self.height = kAKEnemyDef[type - 1].hitHeight;
    
    // 当たり判定のオフセットを設定する
    
    // ヒットポイントを設定する
    self.hitPoint = kAKEnemyDef[type - 1].hitPoint;
    
    // スコアを設定する
    score_ = kAKEnemyDef[type - 1].score;
    
    // 画像の回転をリセットする
    self.image.rotation = 0.0f;
    
    // レイヤーに配置する
    [parent addChild:self.image];
}

/*!
 @brief 動作処理取得
 
 種別番号から動作処理のセレクタを取得する。
 @param type 種別番号
 @return 動作処理のセレクタ
 */
- (SEL)actionSelector:(NSInteger)type
{
    switch (type) {
        case kAKEnemyDragonfly: // トンボの動作処理
            return @selector(actionOfDragonfly:);
            
        case kAKEnemyAnt:       // アリの動作処理
            return @selector(actionOfAnt:);
            
        case kAKEnemyButterfly: // チョウの動作処理
            return @selector(actionOfButterfly:);
        
        case kAKEnemyLadybug:   // テントウムシの動作処理
            return @selector(actionOfLadybug:);
            
        case kAKEnemyBagworm:   // ミノムシの動作処理
            return @selector(actionOfBagworm:);
            
        case kAKEnemyCicada:    // セミの動作処理
            return @selector(actionOfCicada:);
            
        case kAKEnemyGrasshopper:   // バッタの動作処理
            return @selector(actionOfGrasshopper:);
            
        case kAKEnemyHornet:    // ハチの動作処理
            return @selector(actionOfHornet:);
            
        case kAKEnemyCockroach: // ゴキブリの動作処理
            return @selector(actionOfCockroach:);
            
        case kAKEnemySnail:     // カタツムリの動作処理
            return @selector(actionOfSnail:);
            
        case kAKEnemyStagBeetle:    // クワガタの動作処理
            return @selector(actionOfStagBeetle:);
            
        case kAKEnemyRhinocerosBeetle:  // カブトムシの動作処理
            return @selector(actionOfRhinocerosBeetle:);
            
        case kAKEnemyMantis:    // カマキリの動作処理
            return @selector(actionOfMantis:);
            
        default:
            AKLog(kAKLogEnemy_0, @"不正な種別:%d", type);
            NSAssert(NO, @"不正な種別");
            return @selector(actionOfDragonfly:);
    }
}

/*!
 @brief 破壊処理取得
 
 種別番号から破壊処理のセレクタを取得する。
 @param type 種別番号
 @return 破壊処理のセレクタ
 */
- (SEL)destroySeletor:(NSInteger)type
{
    switch (type) {
        case 1: // 雑魚敵の破壊処理
            return @selector(destroyNormal:);
            
        default:
            AKLog(kAKLogEnemy_0, @"不正な種別:%d", type);
            NSAssert(NO, @"不正な種別");
            return @selector(destroyNormal:);
    }
}

/*!
 @brief トンボの動作処理
 
 まっすぐ進む。一定間隔で左方向へ1-way弾発射。
 @param data ゲームデータ
 */
- (void)actionOfDragonfly:(id<AKPlayDataInterface>)data
{
    // 弾のスピード
    const float kAKShotSpeed = 3.0f;
    // 移動スピード
    const float kAKMoveSpeed = -1.5f;
    // 弾発射間隔
    const NSInteger kAKShotInterval = 60;

    // 左へ直進する
    self.speedX = kAKMoveSpeed;
    self.speedY = 0.0f;
    
    // 一定時間経過しているときは左方向へ1-way弾を発射する
    if ((frame_ + 1) % kAKShotInterval == 0) {
        
        // 左へ弾を発射する
        [AKEnemy fireNWayWithAngle:M_PI
                              from:ccp(self.positionX, self.positionY)
                             count:1
                          interval:0.0f
                             speed:kAKShotSpeed
                          isScroll:NO
                              data:data];
    }
    
    AKLog(kAKLogEnemy_1, @"pos=(%f, %f)", self.positionX, self.positionY);
    AKLog(kAKLogEnemy_1, @"img=(%f, %f)", self.image.position.x, self.image.position.y);
}

/*!
 @brief アリの動作処理
 
 天井または地面に張り付いて歩く。
 
 初期状態:上下どちらに張り付くか判定する。距離の近い方に張り付く。
 天井に張り付く場合は画像を上下反転する。
 
 左移動:左方向への移動。一定時間経過後に弾発射に遷移する。
 
 弾発射:停止して弾の発射。自機に向かって1-wayを一定数発射する。
 一定時間経過後に右移動に遷移する。
 
 右移動:地面右方向への移動。一定時間経過後に弾発射に遷移する。
 
 @param data ゲームデータ
 */
- (void)actionOfAnt:(id<AKPlayDataInterface>)data
{
    // 弾のスピード
    const float kAKShotSpeed = 2.0f;
    // 移動スピード
    const float kAKMoveSpeed = 1.0f;
    // 移動するフレーム数
    const NSInteger kAKMoveFrame = 120;
    // 弾発射間隔
    const NSInteger kAKShotInterval = 30;
    // 弾発射時間
    const NSInteger kAKShotFrame = 120;
    
    // 状態
    enum STATE {
        kAKStateInit = 0,           // 初期状態
        kAKStateLeftMove,           // 左移動
        kAKStateRightMove,          // 右移動
        kAKStateFire                // 弾発射
    };
    
    // 縦方向の速度は状態にかかわらず0とする
    self.speedY = 0.0f;
    
    // スクロールに合わせて移動する
    self.scrollSpeed = 1.0f;
    
    // 状態によって処理を分岐する
    switch (state_) {
        case kAKStateInit:     // 初期状態
            
            // 逆さま判定を行う
            [self checkReverse:data.blocks];
            
            // 左移動に遷移する
            state_ = kAKStateLeftMove;
            
            break;
            
        case kAKStateLeftMove:  // 左移動
            
            // スピードをマイナスにして、左右反転はなしにする
            self.speedX = -kAKMoveSpeed;
            self.image.flipX = NO;
            
            // 移動フレーム数が経過したら弾発射に遷移する
            if ((frame_ - work_[0] + 1) % kAKMoveFrame == 0) {

                state_ = kAKStateFire;
                
                // 作業領域に状態遷移した時のフレーム数を保存する
                work_[0] = frame_;
            }

            break;

        case kAKStateRightMove: // 右移動
            
            // スピードをプラスにして、左右反転はありにする
            self.speedX = kAKMoveSpeed;
            self.image.flipX = YES;
            
            // 移動フレーム数が経過したら弾発射に遷移する
            if ((frame_ - work_[0] + 1) % kAKMoveFrame == 0) {

                state_ = kAKStateFire;
                
                // 作業領域に状態遷移した時のフレーム数を保存する
                work_[0] = frame_;
            }
            
            break;
                        
        case kAKStateFire:  // 弾発射
            
            // 自分より右側に自機がいれば左右反転する
            if (self.positionX < data.playerPosition.x) {
                self.image.flipX = YES;
            }
            else {
                self.image.flipX = NO;
            }

            // 待機する
            self.speedX = 0.0f;
            
            // 弾発射時間が経過している場合は右移動へ遷移する
            if ((frame_ - work_[0] + 1) % kAKShotFrame == 0) {
                
                state_ = kAKStateRightMove;
                
                // 作業領域に状態遷移した時のフレーム数を保存する
                work_[0] = frame_;
                
            }
            // 弾発射間隔が経過している場合は弾を発射する
            else if ((frame_ - work_[0] + 1) % kAKShotInterval == 0) {
                
                // 自機へ向けて弾を発射する
                [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                        count:1
                                     interval:0.0f
                                        speed:kAKShotSpeed
                                         data:data];
            }
            
            break;
            
        default:
            AKLog(kAKLogEnemy_0, @"状態が異常:%d", state_);
            NSAssert(NO, @"状態が異常");
            break;
    }
        
    AKLog(kAKLogEnemy_2, @"speedX=%f state_=%d", speedX_, state_);
    
    // 障害物との衝突判定を行う
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(self.positionX, self.positionY)
                                              size:self.image.contentSize
                                         isReverse:self.image.flipY
                                              data:data];
    
    // 移動先の座標を反映する
    self.positionX = newPoint.x;
    self.positionY = newPoint.y;

    // 画像表示位置の更新を行う
    [self updateImagePosition];
    
    AKLog(kAKLogEnemy_1, @"pos=(%f, %f)", self.positionX, self.positionY);
    AKLog(kAKLogEnemy_1, @"img=(%f, %f)", self.image.position.x, self.image.position.y);
}


/*!
 @brief チョウの動作処理
 
 上下に斜めに移動しながら左へ進む。
 定周期で左方向へ3-way弾を発射する。
 @param data ゲームデータ
 */
- (void)actionOfButterfly:(id<AKPlayDataInterface>)data
{
    // 状態
    enum STATE {
        kAKStateInit = 0,   // 初期状態
        kAKStateUpMove,     // 上移動
        kAKStateDownMove    // 下移動
    };

    // 上下方向転換の間隔
    const NSInteger kAKChangeDirectionInterval = 50;
    // 弾発射間隔
    const NSInteger kAKShotInterval = 60;
    // x方向の移動スピード
    const float kAKMoveSpeedX = -1.0f;
    // y方向の移動スピード
    const float kAKMoveSpeedY = 2.0f;
    // 弾のスピード
    const float kAKShotSpeed = 3.0f;

    
    // 初期状態の場合
    if (state_ == kAKStateInit) {

        // 左方向への速度を決める
        self.speedX = kAKMoveSpeedX;
        
        // 最初は上向きの移動とする
        state_ = kAKStateUpMove;
    }
    
    // 上下方向転換の間隔経過している場合は上下の移動方向の状態を逆にする
    if ((frame_ + 1) % kAKChangeDirectionInterval == 0) {
        
        if (state_ == kAKStateUpMove) {
            state_ = kAKStateDownMove;
        }
        else {
            state_ = kAKStateUpMove;
        }
    }
    
    // 状態に応じて上下の移動方向を決める
    if (state_ == kAKStateUpMove) {
        self.speedY = kAKMoveSpeedY;
    }
    else {
        self.speedY = -kAKMoveSpeedY;
    }
    
    // 弾発射間隔経過しているときは左方向へ3-way弾を発射する
    if ((frame_ + 1) % kAKShotInterval == 0) {
        
        // 左へ弾を発射する
        [AKEnemy fireNWayWithAngle:M_PI
                              from:ccp(self.positionX, self.positionY)
                             count:3
                          interval:M_PI / 8.0f
                             speed:kAKShotSpeed
                          isScroll:NO
                              data:data];
    }
}

/*!
 @brief テントウムシの動作処理
 
 まっすぐ進む。一定間隔で自機を狙う1-way弾発射。
 @param data ゲームデータ
 */
- (void)actionOfLadybug:(id<AKPlayDataInterface>)data
{
    // 弾発射間隔
    const NSInteger kAKShotInterval = 60;
    // 移動スピード
    const float kAKMoveSpeed = -1.3f;
    // 弾のスピード
    const float kAKShotSpeed = 2.0f;

    // 左へ直進する
    self.speedX = kAKMoveSpeed;
    self.speedY = 0.0f;
    
    // 弾発射間隔経過しているときは自機を狙う1-way弾を発射する
    if ((frame_ + 1) % kAKShotInterval == 0) {
        
        // 自機へ向けて弾を発射する
        [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                count:1
                             interval:0.0f
                                speed:kAKShotSpeed
                                 data:data];        
    }
}

/*!
 @brief ミノムシの動作処理
 
 スクロールスピードに合わせて移動する。一定時間で全方位に12-way弾を発射する。
 @param data ゲームデータ
 */
- (void)actionOfBagworm:(id<AKPlayDataInterface>)data
{
    // 弾発射間隔
    const NSInteger kAKShotInterval = 60;
    // 弾のスピード
    const float kAKShotSpeed = 2.0f;

    // スクロールに合わせて移動する
    self.scrollSpeed = 1.0f;
    
    // 弾発射間隔経過しているときは全方位に弾を発射する
    if ((frame_ + 1) % kAKShotInterval == 0) {
        
        // 全方位に 12-way弾を発射する
        [AKEnemy fireNWayWithAngle:M_PI
                              from:ccp(self.positionX, self.positionY)
                             count:12
                          interval:M_PI / 6.0f
                             speed:kAKShotSpeed
                          isScroll:YES
                              data:data];
    }
}

/*!
 @brief セミの動作処理
 
 自機に向かって一定時間飛ぶ。その後待機して自機に向かって3-way弾を発射する。
 @param data ゲームデータ
 */
- (void)actionOfCicada:(id<AKPlayDataInterface>)data
{
    // 移動スピード
    const float kAKSpeed = 2.0f;
    // 移動間隔
    const NSInteger kAKMoveInterval = 60;
    // 弾発射間隔
    const NSInteger kAKShotInterval = 20;
    // 待機間隔
    const NSInteger kAKWaitInterval = 70;
    // 弾のスピード
    const float kAKShotSpeed = 2.0f;

    // 状態
    enum STATE {
        kAKStateInit = 0,           // 初期状態
        kAKStateLeftMove,           // 左移動
        kAKStateFire                // 弾発射
    };

    // 状態によって処理を分岐する
    switch (state_) {
        case kAKStateInit:     // 初期状態
        {
            // 自機との角度を求める
            float angle = [AKNWayAngle calcDestAngleFrom:ccp(self.positionX, self.positionY)
                                                      to:data.playerPosition];
            
            // 縦横の速度を決定する
            self.speedX = kAKSpeed * cosf(angle);
            self.speedY = kAKSpeed * sinf(angle);
            
            // 移動中はアニメーションを設定する
            self.animationPattern = 2;
            self.animationInterval = 6;
            self.animationInitPattern = 11;
            
            // 左移動の状態へ遷移する
            state_ = kAKStateLeftMove;            
        }
            break;
            
        case kAKStateLeftMove:     // 左へ移動
            
            // 移動間隔経過したら次の状態へ進める
            if ((frame_ + 1) % kAKMoveInterval == 0) {
                
                // 弾発射の状態へ遷移する
                state_= kAKStateFire;
                
                // 停止する（スクロールスピードに合わせる）
                self.speedX = -data.scrollSpeedX;
                self.speedY = -data.scrollSpeedY;
                
                // 待機中はアニメーションを無効化
                self.animationPattern = 1;
                self.animationInterval = 0.0f;
                self.animationInitPattern = 1;
                
                // 経過フレーム数を初期化する
                frame_ = 0;
            }
            break;
            
        case kAKStateFire:  // 弾発射
            
            // 弾発射間隔経過で自機に向かって3-way弾を発射する
            if ((frame_ + 1) % kAKShotInterval == 0) {
                
                [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                        count:3
                                     interval:M_PI / 8.0f
                                        speed:kAKShotSpeed
                                         data:data];                
            }
            
            // 待機間隔経過で初期状態に戻る
            if ((frame_ + 1) % kAKWaitInterval == 0) {
                
                // 初期状態へ遷移する
                state_ = kAKStateInit;
                
                // 経過フレーム数を初期化する
                frame_ = 0;
            }
            
            break;
            
        default:
            AKLog(kAKLogEnemy_0, @"状態が異常:%d", state_);
            NSAssert(NO, @"状態が異常");
            break;
    }
}

/*!
 @brief バッタの動作処理
 
 地面または天井を移動する。左方向へジャンプ、着地して弾発射を繰り返す。
 @param data ゲームデータ
 */
- (void)actionOfGrasshopper:(id<AKPlayDataInterface>)data
{
    // 移動スピード
    const float kAKMoveSpeed = -1.0f;
    // ジャンプのスピード
    const float kAKJumpSpeed = 4.0f;
    // 重力加速度
    const float kAKGravitationAlacceleration = 0.15f;
    // 左移動間隔
    const NSInteger kAKLeftMoveInterval = 60;
    // 待機間隔
    const NSInteger kAKWaitInterval = 60;
    // 弾発射間隔
    const NSInteger kAKShotInterval = 30;
    // 弾のスピード
    const float kAKShotSpeed = 2.0f;
    
    // 状態
    enum STATE {
        kAKStateInit = 0,           // 初期状態
        kAKStateLeftMove,           // 左移動
        kAKStateWait                // 待機
    };
    
    // スクロールに合わせて移動する
    self.scrollSpeed = 1;
    
    // 障害物との当たり判定を有効にする
    self.blockHitAction = kAKBlockHitMove;

    // 初期状態の時は逆さま判定を行う
    if (state_ == kAKStateInit) {
        [self checkReverse:data.blocks];
    }
    
    // 左移動中の場合
    if (state_ == kAKStateLeftMove) {

        // 重力加速度をかけて減速する
        if (!self.image.flipY) {
            self.speedY -= kAKGravitationAlacceleration;
        }
        else {
            self.speedY += kAKGravitationAlacceleration;
        }

        // 一定時間経過したら次の状態へ進める
        if (frame_ - work_[0] > kAKLeftMoveInterval) {
            
            // 弾発射の状態へ遷移する
            state_= kAKStateWait;
            
            // 停止する
            self.speedX = 0;
            
            // 作業領域に状態遷移した時のフレーム数を保存する
            work_[0] = frame_;
        }
    }
    
    // 落ちていく方向の障害物に接触している場合、着地したとしてスピードを0にする。
    if ((!self.image.flipY && (self.blockHitSide & kAKHitSideBottom)) ||
        (self.image.flipY && (self.blockHitSide & kAKHitSideTop))) {
        
        self.speedX = 0.0f;
        self.speedY = 0.0f;
    }
    
    // 初期状態または待機中で待機時間が経過している場合
    if ((state_ == kAKStateInit) || (state_ == kAKStateWait && (frame_ - work_[0] > kAKWaitInterval))) {
        
        AKLog(kAKLogEnemy_3, @"ジャンプ:frame=%d work[0]=%d", frame_, work_[0]);
        
        // 左方向へのスピードを設定する
        self.speedX = kAKMoveSpeed;
        
        // ジャンプする方向へ加速する
        if (!self.image.flipY) {
            self.speedY = kAKJumpSpeed;
        }
        else {
            self.speedY = -kAKJumpSpeed;
        }
        
        // 左移動の状態へ遷移する
        state_ = kAKStateLeftMove;
        
        // 作業領域に状態遷移した時のフレーム数を保存する
        work_[0] = frame_;
    }

    // 弾発射間隔経過で自機に向かって1-way弾を発射する
    if ((frame_ + 1) % kAKShotInterval == 0) {
        
        [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                count:1
                             interval:0.0f
                                speed:kAKShotSpeed
                                 data:data];
    }
    
    AKLog(kAKLogEnemy_3, @"speed=(%f, %f)", self.speedX, self.speedY);
    
    // 画像表示位置の更新を行う
    [self updateImagePosition];
}

/*!
 @brief ハチの動作処理
 
 画面上半分から登場するときは左下に向かって一定時間進み、一時停止して弾を発射、その後左上に向かって飛んで行く。
 画面下半分から登城するときは左上に向かって一定時間進み、あとの処理は同じ。
 弾は5種類のスピードの弾を左方向に発射する。
 @param data ゲームデータ
 */
- (void)actionOfHornet:(id<AKPlayDataInterface>)data
{
    // 弾の数
    const NSInteger kAKShotCount = 5;
    // 弾のスピード
    const float kAKShotSpeed[kAKShotCount] = {3.2f, 3.4f, 3.6f, 3.8f, 4.0f};
    // 登場時のx方向の移動スピード
    const float kAKMoveInSpeedX = -2.0f;
    // 登場時のy方向の移動スピード
    const float kAKMoveInSpeedY = 1.0f;
    // 退場時のx方向の移動スピード
    const float kAKMoveOutSpeedX = -2.6f;
    // 退場時のy方向の移動スピード
    const float kAKMoveOutSpeedY = 0.5f;
    // 登場時移動フレーム数
    const NSInteger kAKMoveInFrame = 30;
    // 弾発射までの待機フレーム数
    const NSInteger kAKWaitForFireFrame = 6;
    // 退場までの待機フレーム数
    const NSInteger kAKWaitForMoveOutFrame = 12;
    
    // 状態
    enum STATE {
        kAKStateInit = 0,   // 初期状態
        kAKStateMoveIn,     // 登場
        kAKStateFire,       // 弾発射
        kAKStateMoveOut     // 退場
    };
    
    // 状態によって処理を分岐する
    switch (state_) {
        case kAKStateInit:      // 初期状態
            
            // 左方向へ移動する
            self.speedX = kAKMoveInSpeedX;
            
            // 画面下半分に配置されている場合
            if (self.positionY < [AKScreenSize stageSize].height / 2) {
                // 上方向へ移動する
                self.speedY = kAKMoveInSpeedY;
            }
            // 画面上半分に配置されている場合
            else {
                // 下方向へ移動する
                self.speedY = -kAKMoveInSpeedY;
            }
            
            // 登場の状態へ遷移する
            state_ = kAKStateMoveIn;
            
            break;
            
        case kAKStateMoveIn:    // 登場
            
            // 登場移動時間が経過している場合
            if (frame_ > kAKMoveInFrame) {
                
                // 停止する
                self.speedX = 0.0f;
                self.speedY = 0.0f;
                
                // 弾発射の状態へ遷移する
                state_ = kAKStateFire;
                
                // 経過フレーム数を初期化する
                frame_ = 0;
            }
            
            break;
            
        case kAKStateFire:      // 弾発射
            
            // 待機時間が経過している場合
            if (frame_ > kAKWaitForFireFrame) {
                
                // 左へ5種類の弾を発射する
                for (int i = 0; i < kAKShotCount; i++) {
                    [AKEnemy fireNWayWithAngle:M_PI
                                          from:ccp(self.positionX, self.positionY)
                                         count:3
                                      interval:M_PI / 32.0f
                                         speed:kAKShotSpeed[i]
                                      isScroll:NO
                                          data:data];
                }

                // 退場の状態へ遷移する
                state_ = kAKStateMoveOut;
                
                // 経過フレーム数を初期化する
                frame_ = 0;
            }
            break;
            
        case kAKStateMoveOut:   // 退場
            
            // 待機時間が経過している場合
            if (frame_ > kAKWaitForMoveOutFrame) {
                // 左上へ移動する
                self.speedX = kAKMoveOutSpeedX;
                self.speedY = kAKMoveOutSpeedY;
            }
            
            break;
            
        default:
            AKLog(kAKLogEnemy_0, @"状態が異常:%d", state_);
            NSAssert(NO, @"状態が異常");
            break;
    }
}

/*!
 @brief ゴキブリの動作処理
 
 自機に向かって体当たりをしてくる。定周期で自機に向かって1-way弾を発射する。
 @param data ゲームデータ
 */
- (void)actionOfCockroach:(id<AKPlayDataInterface>)data
{
    // 移動スピード
    const float kAKMoveSpeed = 2.0f;
    // 弾のスピード
    const float kAKShotSpeed = 3.0f;
    // 弾発射間隔
    const NSInteger kAKShotInterval = 60;

    // 自機との角度を求める
    float angle = [AKNWayAngle calcDestAngleFrom:ccp(self.positionX, self.positionY)
                                              to:data.playerPosition];
    
    // 縦横の速度を決定する
    self.speedX = kAKMoveSpeed * cosf(angle);
    self.speedY = kAKMoveSpeed * sinf(angle);
    
    // 画像を回転させる
    self.image.rotation = AKCnvAngleRad2Scr(angle);
    
    // 一定時間経過しているときは自機を狙う1-way弾を発射する
    if ((frame_ + 1) % kAKShotInterval == 0) {
        
        // 自機へ向けて弾を発射する
        [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                count:1
                             interval:0.0f
                                speed:kAKShotSpeed
                                 data:data];        
    }
}

/*! 
 @brief カタツムリの動作処理
 
 天井または地面に張り付いて歩く。
 左方向へゆっくり移動しながら、自機に向かって3-way弾を発射する。
 @param data ゲームデータ
 */
- (void)actionOfSnail:(id<AKPlayDataInterface>)data
{
    // 弾のスピード
    const float kAKShotSpeed = 2.0f;
    // 移動スピード
    const float kAKMoveSpeed = 0.2f;
    // 弾発射間隔
    const NSInteger kAKShotInterval = 60;
    
    // 状態
    enum STATE {
        kAKStateInit = 0,           // 初期状態
        kAKStateLeftMove            // 左移動
    };
    
    // 縦方向の速度は状態にかかわらず0とする
    self.speedY = 0.0f;
    
    // スクロールに合わせて移動する
    self.scrollSpeed = 1.0f;
    
    // 状態によって処理を分岐する
    switch (state_) {
        case kAKStateInit:     // 初期状態
            
            // 逆さま判定を行う
            [self checkReverse:data.blocks];
            
            // 左方向へ移動する
            self.speedX = -kAKMoveSpeed;
            
            // 左移動の状態に遷移する
            state_ = kAKStateLeftMove;
            
            break;
            
        case kAKStateLeftMove:  // 左移動
                        
            // 一定時間経過したら弾を発射する
            if ((frame_ + 1) % kAKShotInterval == 0) {

                // 自機へ向けて弾を発射する
                [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                        count:3
                                     interval:M_PI / 8.0f
                                        speed:kAKShotSpeed
                                         data:data];
            }
            
            break;
        default:
            AKLog(kAKLogEnemy_0, @"状態が異常:%d", state_);
            NSAssert(NO, @"状態が異常");
            break;
    }
    
    // 障害物との衝突判定を行う
    CGPoint newPoint = [AKEnemy checkBlockPosition:ccp(self.positionX, self.positionY)
                                              size:self.image.contentSize
                                         isReverse:self.image.flipY
                                              data:data];
    
    // 移動先の座標を反映する
    self.positionX = newPoint.x;
    self.positionY = newPoint.y;
    
    // 画像表示位置の更新を行う
    [self updateImagePosition];
}

/*!
 @brief クワガタの動作処理
 
 登場時に自機の方向へ進行方向を決めて真っ直ぐ飛ぶ。定周期で3-way弾を発射する。
 途中で方向転換を行い、自機の方向へ向き直す。ただし、後ろの方向には戻らないようにx方向は常に左にする。
 @param data ゲームデータ
 */
- (void)actionOfStagBeetle:(id<AKPlayDataInterface>)data
{
    // 弾のスピード
    const float kAKShotSpeed = 3.0f;
    // 移動スピード
    const float kAKMoveSpeed = 2.0f;
    // 弾発射間隔
    const NSInteger kAKShotInterval = 60;
    // 方向転換を行うまでの間隔
    const NSInteger kAKChangeDirectionInterval = 120;

    // 状態
    enum STATE {
        kAKStateInit = 0,           // 初期状態
        kAKStateLeftMove            // 左移動
    };
    
    // 状態によって処理を分岐する
    switch (state_) {
        case kAKStateInit:              // 初期状態
        {
            // 自機との角度を求める
            float angle = [AKNWayAngle calcDestAngleFrom:ccp(self.positionX, self.positionY)
                                                      to:data.playerPosition];
            
            // 縦横の速度を決定する
            // ただし、後ろには戻らないようにx方向は絶対値とする
            self.speedX = -1.0 * fabsf(kAKMoveSpeed * cosf(angle));
            self.speedY = kAKMoveSpeed * sinf(angle);
            
            // 左移動の状態へ遷移する
            state_ = kAKStateLeftMove;
        }
            break;
            
        case kAKStateLeftMove:     // 左へ移動
            
            // 弾発射間隔時間経過したら弾を発射する
            if ((frame_ + 1) % kAKShotInterval == 0) {
                
                // 自機へ向けて弾を発射する
                [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                        count:3
                                     interval:M_PI / 8.0f
                                        speed:kAKShotSpeed
                                         data:data];
            }
            
            // 方向転換間隔経過したら初期状態に遷移して角度を設定し直す
            if ((frame_ + 1) % kAKChangeDirectionInterval == 0) {
                
                state_ = kAKStateInit;
            }
            break;
            
        default:
            AKLog(kAKLogEnemy_0, @"状態が異常:%d", state_);
            NSAssert(NO, @"状態が異常");
            break;
    }
    
}

/*!
 @brief カブトムシの動作処理
 
 左に真っすぐ進み、画像がすべて表示できた部分で上下に移動する。
 
 攻撃パターン1:左方向にまっすぐ3-wayと自機を狙う1-way弾を発射する
 
 攻撃パターン2:定周期に一塊の5-way弾を発射する
 
 攻撃パターン3:全方位弾を発射する
 @param data ゲームデータ
 */
- (void)actionOfRhinocerosBeetle:(id<AKPlayDataInterface>)data
{
    // 状態
    enum STATE {
        kAKStateInit = 0,           // 初期状態
        kAKStateLeftShot,           // 左方向へ弾発射
        kAKStateNWay,               // 自機へ向けてn-way弾発射
        kAKStateAllDirection,       // 全方位に弾発射
        kAKStateCount               // 状態の種類の数
    };
    
    // x座標最小位置
    const float kAKXMin = 300.0f;
    // y座標最小位置
    const float kAKYMin = 80.0f;
    // y座標最大位置
    const float kAKYMax = 210.0f;
    // 移動スピード
    const float kAKMoveSpeed = 1.0f;
    // 状態遷移間隔
    const NSInteger kAKStateInterval[kAKStateCount] = {1000000, 900, 900, 900};
    // 左方向への弾の発射間隔
    const NSInteger kAKLeftShotInterval = 30;
    // 左方向への弾の上下の発射位置
    const NSInteger kAKLeftShotPosition = 30;
    // 左方向への弾のスピード
    const float kAKLeftShotSpeed = 3.0f;
    // 左方向への弾発射時の1-way弾の発射間隔
    const NSInteger kAKLeftShot1WayInterval = 60;
    // 左方向への弾発射時の1-way弾のスピード
    const float kAKLeftShot1WaySpeed = 2.0f;
    // n-way弾の塊の発射間隔
    const NSInteger kAKNWayGroupShotInterval = 60;
    // n-way弾の発射間隔
    const NSInteger kAKNWayShotInterval = 6;
    // n-way弾の発射時間
    const NSInteger kAKNWayShotTime = 30;
    // n-way弾の弾数
    const NSInteger kAKNWayCount = 3;
    // n-way弾の角度の間隔
    const float kAKNwayAngle = M_PI / 8;
    // n-way弾のスピード
    const float kAKNWaySpeed = 3.0f;
    // 全方位弾の発射間隔
    const NSInteger kAKAllDirectionInterval = 30;
    // 全方位弾の弾数
    const float kAKAllDirectionCount = 12;
    // 全方位弾の角度の間隔
    const float kAKAllDirectionAngle = 2 * M_PI / kAKAllDirectionCount;
    // 全方位弾のスピード
    const float kAKAllDirectionSpeed = 3.0f;
    
    // x座標最小位置まで左に真っ直ぐ移動する
    if (self.positionX > kAKXMin) {
        self.speedX = -kAKMoveSpeed;
        self.speedY = 0.0f;
    }
    // x座標最小位置まで到達して上下に移動していない場合は横方向の移動を止めて、下方向に移動する
    else if (AKIsEqualFloat(self.speedY, 0.0f)) {
        self.speedX = 0.0f;
        self.speedY = -kAKMoveSpeed;
    }
    // 下方向へ移動中にy座標最小位置まで到達したら上方向へ移動する
    else if (self.speedY < 0.0f && self.positionY < kAKYMin) {
        self.speedY = kAKMoveSpeed;
    }
    // 上方向へ移動中にy座標最大位置まで到達したら下方向へ移動する
    else if (self.speedY > 0.0f && self.positionY > kAKYMax) {
        self.speedY = -kAKMoveSpeed;
    }
    // その他の場合はスピードはそのままとする
    else {
        // No operation.
    }
        
    // 状態によって処理を分岐する
    switch (state_) {
        case kAKStateInit:  // 初期状態
            
            // 上下移動になった場合は次の状態へ進める
            if (AKIsEqualFloat(self.speedX, 0.0f)) {
                state_++;                
            }
            
            break;
            
        case kAKStateLeftShot:  // 左方向へ弾発射
            
            // 左方向への弾発射間隔が経過している場合は弾を発射する
            if ((frame_ + 1) % kAKLeftShotInterval == 0) {
                
                // 3箇所から同時に弾を発射する
                [AKEnemy fireNWayWithAngle:M_PI
                                      from:ccp(self.positionX, self.positionY)
                                     count:1
                                  interval:0.0f
                                     speed:kAKLeftShotSpeed
                                  isScroll:NO
                                      data:data];

                [AKEnemy fireNWayWithAngle:M_PI
                                      from:ccp(self.positionX, self.positionY - kAKLeftShotPosition)
                                     count:1
                                  interval:0.0f
                                     speed:kAKLeftShotSpeed
                                  isScroll:NO
                                      data:data];

                [AKEnemy fireNWayWithAngle:M_PI
                                      from:ccp(self.positionX, self.positionY + kAKLeftShotPosition)
                                     count:1
                                  interval:0.0f
                                     speed:kAKLeftShotSpeed
                                  isScroll:NO
                                      data:data];
            }
            
            // 1-way弾の弾発射間隔が経過している場合は弾を発射する
            if ((frame_ + 1) % kAKLeftShot1WayInterval == 0) {
                
                [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                        count:1
                                     interval:0.0f
                                        speed:kAKLeftShot1WaySpeed
                                         data:data];
            }
            
            break;
            
        case kAKStateNWay:      // 自機へ向けてn-way弾発射
            
            // n-way弾グループの発射間隔が経過している場合はn-way弾を発射し始める
            if (frame_ - work_[0] > kAKNWayGroupShotInterval) {
                
                // n-way弾の発射間隔が経過している場合は弾を発射する
                if ((frame_ + 1) % kAKNWayShotInterval == 0) {
                    
                    [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                            count:kAKNWayCount
                                         interval:kAKNwayAngle
                                            speed:kAKNWaySpeed
                                             data:data];
                }
                
                // n-way弾の発射時間が経過している場合は作業領域に現在の経過フレーム数を入れて
                // n-way弾グループの発射間隔分待機する
                if (frame_ - work_[0] > kAKNWayShotTime + kAKNWayGroupShotInterval) {
                    work_[0] = frame_;
                }
            }
            break;
            
        case kAKStateAllDirection:  // 全方位に弾発射
            
            // 全方位弾の発射間隔が経過している場合は弾を発射する
            if ((frame_ + 1) % kAKAllDirectionInterval == 0) {
                
                [AKEnemy fireNWayWithAngle:M_PI
                                      from:ccp(self.positionX, self.positionY)
                                     count:kAKAllDirectionCount
                                  interval:kAKAllDirectionAngle
                                     speed:kAKAllDirectionSpeed
                                  isScroll:YES
                                      data:data];
            }
            break;
            
        default:
            AKLog(kAKLogEnemy_0, @"状態が異常:%d", state_);
            NSAssert(NO, @"状態が異常");
            break;
    }
    
    // 状態遷移間隔が経過している場合は次の状態へ進める
    if (frame_ > kAKStateInterval[state_]) {
        
        // 次の状態へ進める
        state_++;
        
        // 状態が最大を超える場合は最初の状態へループする
        if (state_ >= kAKStateCount) {
            state_ = kAKStateInit + 1;
        }
        
        // 経過フレーム数と作業領域を初期化する
        work_[0] = 0.0f;
        frame_ = 0.0f;
        
        AKLog(kAKLogEnemy_3, @"state_=%d", state_);
    }
}

/*!
 @brief カマキリの動作処理
 
 スクロールに応じて移動する。攻撃パターンの状態にかかわらず、常に3-way弾を発射する。
 攻撃の前に鎌を振り上げ、攻撃と同時に鎌を片方ずつ下ろすアニメーションを行う。
 
 攻撃パターン1:弧の形に並んだ弾を自機に向けて発射する。
 
 攻撃パターン2:塊弾を自機に向けて発射する。自機の位置に到達すると塊弾は12-way弾として弾ける。
 
 攻撃パターン3:9-way弾と10-way弾を短い間隔で連続で発射する。
 @param data ゲームデータ
 */
- (void)actionOfMantis:(id<AKPlayDataInterface>)data
{
    // 状態
    enum STATE {
        kAKStateInit = 0,           // 初期状態
        kAKStateArcShot,            // 弧形弾発射
        kAKStateBurstShot,          // 破裂弾発射
        kAKStateNWayShot,           // n-way弾発射
        kAKStateCount               // 状態の種類の数
    };
    // 地面の高さ
    const NSInteger kAKGround = 24;
    // 状態遷移間隔
    const NSInteger kAKStateInterval[kAKStateCount] = {340, 900, 900, 900};
    // 手の位置
    const CGPoint kAKHandPosition = {-48.0f, 48.0f};
    // 定周期弾の発射間隔
    const NSInteger kAKCycleShotInterval = 60;
    // 定周期弾の弾数
    const NSInteger kAKCycleShotCount = 3;
    // 定周期弾の角度の間隔
    const float kAKCycleShotAngle = M_PI / 8;
    // 定周期弾のスピード
    const float kAKCycleShotSpeed = 3.0f;
    // 弧形段の弾数
    const NSInteger kAKArcShotCount = 9;
    // 弧形弾の配置位置
    const CGPoint kAKArcShotPosition[kAKArcShotCount] = {
        {0, 0}, {6, 12}, {14, 24}, {24, 34}, {36, 42}, {-2, -14}, {0, -28}, {4, -42}, {12, -54}
    };
    // 弧形弾の発射待機時間
    const NSInteger kAKArcShotWaitTime = 90;
    // 弧形弾の発射間隔
    const NSInteger kAKArcShotInterval = 60;
    // 弧形弾のスピード
    const float kAKArcShotSpeed = 2.5f;
    // 破裂弾の発射待機時間
    const NSInteger kAKBurstShotWaitTime = 90;
    // 破裂弾の発射間隔
    const NSInteger kAKBurstShotInterval = 60;
    // 破裂弾の破裂前のスピード
    const float kAKBurstShotBeforSpeed = 2.0f;
    // 破裂弾の破裂後のスピード
    const float kAKBurstShotAfterSpeed = 3.5f;
    // 破裂弾の破裂までの間隔
    const NSInteger kAKBurstShotBurstInterval = 80;
    // 破裂弾の弾数
    const NSInteger kAKBurstShotCount = 12;
    // 破裂弾の各弾の間隔
    const float kAKBurstShotAngleInterval = M_PI / 6.0f;
    // n-way弾の待機間隔
    const NSInteger kAKNWayShotWaitTime = 90;
    // n-way弾の発射間隔
    const NSInteger kAKNWayShotInterval = 20;
    // n-way弾のスピード
    const float kAKNWayShotSpeed = 2.5f;
    // n-way弾の弾数
    const NSInteger kAKNWayCount[2] = {9, 10};
    // n-way弾の角度の間隔
    const float kAKNWayAngleInterval = M_PI / 20;
    
    // 状態によって処理を分岐する
    switch (state_) {
        case kAKStateInit:      // 初期状態

            // スクロールに合わせて移動する
            self.scrollSpeed = 1.0f;
            
            // 地面の上の位置に高さを補正する
            self.positionY = self.image.contentSize.height / 2 + kAKGround;
            
            break;
            
        case kAKStateArcShot:   // 弧形弾発射
            
            // 弧形弾の待機時間が経過したら鎌を振り上げる
            if (work_[0] == 0 && frame_ - work_[1] >= kAKArcShotWaitTime) {
                
                // 作業領域0(振り上げている鎌の数)を2とする
                work_[0] = 2;
                
                // 作業領域1(鎌を動かしてからの経過フレーム数)を現在のフレーム数に設定する
                work_[1] = frame_;
            }
            
            // 弧形弾の発射間隔が経過したら弾を発射する
            if (work_[0] > 0 && frame_ - work_[1] >= kAKArcShotInterval) {
                
                // 作業領域0(振り上げている鎌の数)を減らす
                work_[0]--;

                // 作業領域1(鎌を動かしてからの経過フレーム数)を現在のフレーム数に設定する
                work_[1] = frame_;
                
                // 弧形弾を発射する
                [AKEnemy fireGroupShotWithPosition:ccp(self.positionX + kAKHandPosition.x,
                                                       self.positionY + kAKHandPosition.y)
                                          distance:kAKArcShotPosition
                                             count:kAKArcShotCount
                                             speed:kAKArcShotSpeed
                                              data:data];
            }
            
            break;
            
        case kAKStateBurstShot: // 破裂弾発射

            // 破裂弾の待機時間が経過したら鎌を振り上げる
            if (work_[0] == 0 && frame_ - work_[1] >= kAKBurstShotWaitTime) {
                
                // 作業領域0(振り上げている鎌の数)を2とする
                work_[0] = 2;
                
                // 作業領域1(鎌を動かしてからの経過フレーム数)を現在のフレーム数に設定する
                work_[1] = frame_;
            }
            
            // 破裂弾の発射間隔が経過したら弾を発射する
            if (work_[0] > 0 && frame_ - work_[1] >= kAKBurstShotInterval) {
                
                // 作業領域0(振り上げている鎌の数)を減らす
                work_[0]--;
                
                // 作業領域1(鎌を動かしてからの経過フレーム数)を現在のフレーム数に設定する
                work_[1] = frame_;
                
                // 破裂弾を発射する
                [AKEnemy fireBurstShotWithPosition:ccp(self.positionX + kAKHandPosition.x,
                                                       self.positionY + kAKHandPosition.y)
                                             count:kAKBurstShotCount
                                          interval:kAKBurstShotAngleInterval
                                             speed:kAKBurstShotBeforSpeed
                                     burstInterval:kAKBurstShotBurstInterval
                                        burstSpeed:kAKBurstShotAfterSpeed
                                              data:data];
            }

            break;
            
        case kAKStateNWayShot:  // n-way弾発射
            
            // n-way弾の待機時間が経過したら鎌を振り上げる
            if (work_[0] == 0 && frame_ - work_[1] >= kAKNWayShotWaitTime) {
                
                // 作業領域0(振り上げている鎌の数)を2とする
                work_[0] = 2;
                
                // 作業領域1(鎌を動かしてからの経過フレーム数)を現在のフレーム数に設定する
                work_[1] = frame_;
            }
            
            // n-way弾の発射間隔が経過したら弾を発射する
            if (work_[0] > 0 && frame_ - work_[1] >= kAKNWayShotInterval) {
                
                // 作業領域0(振り上げている鎌の数)を減らす
                work_[0]--;
                
                // 作業領域1(鎌を動かしてからの経過フレーム数)を現在のフレーム数に設定する
                work_[1] = frame_;
                
                // n-way弾を発射する
                [AKEnemy fireNWayWithPosition:ccp(self.positionX + kAKHandPosition.x,
                                                  self.positionY + kAKHandPosition.y)
                                        count:kAKNWayCount[1 - work_[0]]
                                     interval:kAKNWayAngleInterval
                                        speed:kAKNWayShotSpeed
                                         data:data];
            }

            break;
            
        default:
            AKLog(kAKLogEnemy_0, @"状態が異常:%d", state_);
            NSAssert(NO, @"状態が異常");
            break;
    }
    
    // 初期状態以外の場合は定周期に3-way弾を発射する
    if (state_ != kAKStateInit && (frame_ + 1) % kAKCycleShotInterval == 0) {

        [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                count:kAKCycleShotCount
                             interval:kAKCycleShotAngle
                                speed:kAKCycleShotSpeed
                                 data:data];
    }
    
    // 振り上げている鎌の数に応じてグラフィックを変更する
    self.animationInitPattern = work_[0] + 1;
    
    // 状態遷移間隔が経過している場合は次の状態へ進める
    if (frame_ > kAKStateInterval[state_]) {
        
        // 次の状態へ進める
        state_++;
        
        // 状態が最大を超える場合は最初の状態へループする
        if (state_ >= kAKStateCount) {
            state_ = kAKStateInit + 1;
        }
        
        // 経過フレーム数と作業領域を初期化する
        work_[0] = 0.0f;
        work_[1] = 0.0f;
        frame_ = 0.0f;
        
        AKLog(kAKLogEnemy_3, @"state_=%d", state_);
    }
}

/*!
 @brief 雑魚敵の破壊処理
 
 破壊エフェクトを発生させる。
 @param data ゲームデータ
 */
- (void)destroyNormal:(id<AKPlayDataInterface>)data
{
    AKLog(kAKLogEnemy_1, @"start");
    
    // 画面効果を生成する
    [data createEffect:1 x:self.positionX y:self.positionY];
}

/*!
 @brief 自機を狙うn-way弾発射
 
 自機を狙うn-way弾の発射を行う。
 @param position 発射する位置
 @param count 発射方向の数
 @param interval 弾の間隔
 @param speed 弾の速度
 @param data ゲームデータ
 */
+ (void)fireNWayWithPosition:(CGPoint)position count:(NSInteger)count interval:(float)interval speed:(float)speed data:(id<AKPlayDataInterface>)data
{
    // n-way弾の各弾の角度を計算する
    AKNWayAngle *nWayAngle = [AKNWayAngle angleFromSrc:position
                                                  dest:data.playerPosition
                                                 count:count
                                              interval:interval];
    
    // 各弾を発射する
    for (NSNumber *angle in nWayAngle.angles) {
        
        // 敵弾インスタンスを取得する
        AKEnemyShot *enemyShot = [data getEnemyShot];
        
        // 通常弾を生成する
        [enemyShot createNormalShotAtX:position.x
                                     y:position.y
                                 angle:[angle floatValue]
                                 speed:speed
                                parent:[data getEnemyShotParent]];
    }
}

/*!
 @brief 角度指定によるn-way弾発射
 
 角度指定によるn-way弾の発射を行う。
 @param angle 発射する角度
 @param position 発射する位置
 @param count 発射方向の数
 @param interval 弾の間隔
 @param speed 弾の速度
 @param isScroll スクロールの影響を受けるか
 @param data ゲームデータ
 */
+ (void)fireNWayWithAngle:(float)angle
                     from:(CGPoint)position
                    count:(NSInteger)count
                 interval:(float)interval
                    speed:(float)speed
                 isScroll:(BOOL)isScroll
                     data:(id<AKPlayDataInterface>)data
{
    // n-way弾の各弾の角度を計算する
    AKNWayAngle *nWayAngle = [AKNWayAngle angleFromCenterAngle:angle
                                                         count:count
                                                      interval:interval];
    
    // 各弾を発射する
    for (NSNumber *angle in nWayAngle.angles) {

        // 敵弾インスタンスを取得する
        AKEnemyShot *enemyShot = [data getEnemyShot];
        
        // スクロールの影響を受けるかどうかで弾の種別を変える
        if (isScroll) {
            // スクロール影響弾を生成する
            [enemyShot createScrollShotAtX:position.x
                                         y:position.y
                                     angle:[angle floatValue]
                                     speed:speed
                                    parent:[data getEnemyShotParent]];
        }
        else {
            // 通常弾を生成する
            [enemyShot createNormalShotAtX:position.x
                                         y:position.y
                                     angle:[angle floatValue]
                                     speed:speed
                                    parent:[data getEnemyShotParent]];
        }
    }
}

/*!
 @brief 自機を狙うグループ弾発射
 
 自機を狙う一塊のグループ弾を発射する。
 中心点から自機の角度を計算し、すべての弾をその角度で発射する。
 @param position グループ弾の中心点の座標
 @param distance 中心点からの距離
 @param count 弾の数
 @param speed 弾の速度
 @param data ゲームデータ
 */
+ (void)fireGroupShotWithPosition:(CGPoint)position
                         distance:(const CGPoint *)distance
                            count:(NSInteger)count
                            speed:(float)speed
                             data:(id<AKPlayDataInterface>)data
{
    // 弾の角度を計算する
    AKNWayAngle *nWayAngle = [AKNWayAngle angleFromSrc:position
                                                  dest:data.playerPosition
                                                 count:1
                                              interval:0.0f];
    
    // 各弾の位置に通常弾を生成する
    for (int i = 0; i < count; i++) {

        // 敵弾インスタンスを取得する
        AKEnemyShot *enemyShot = [data getEnemyShot];
        
        // 通常弾を生成する
        [enemyShot createNormalShotAtX:position.x + distance[i].x
                                     y:position.y + distance[i].y
                                 angle:nWayAngle.topAngle
                                 speed:speed
                                parent:[data getEnemyShotParent]];
    }
}

/*!
 @brief 破裂弾発射
 
 一定時間で破裂する弾を発射する。
 @param position 発射する位置
 @param count 破裂後の数
 @param interval 破裂後の弾の間隔
 @param speed 弾の速度
 @param burstInterval 破裂までの間隔
 @param burstSpeed 破裂後の速度
 @param data ゲームデータ
 */
+ (void)fireBurstShotWithPosition:(CGPoint)position
                            count:(NSInteger)count
                         interval:(float)interval
                            speed:(float)speed
                    burstInterval:(float)burstInterval
                       burstSpeed:(float)burstSpeed
                             data:(id<AKPlayDataInterface>)data
{
    // 中心点からの弾の距離
    const float kAKDistance = 4.0f;
    
    // 破裂弾弾全体の角度を計算する
    AKNWayAngle *centerAngle = [AKNWayAngle angleFromSrc:position
                                                    dest:data.playerPosition
                                                   count:1
                                                interval:0.0f];
    
    // 個別の弾の角度を計算する
    AKNWayAngle *burstAngle = [AKNWayAngle angleFromCenterAngle:M_PI
                                                          count:count
                                                       interval:interval];
    
    // 各弾を発射する
    for (NSNumber *angle in burstAngle.angles) {
        
        // 敵弾インスタンスを取得する
        AKEnemyShot *enemyShot = [data getEnemyShot];
        
        // 破裂弾を生成する
        [enemyShot createChangeSpeedShotAtX:position.x + cosf([angle floatValue]) * kAKDistance
                                          y:position.y + sinf([angle floatValue]) * kAKDistance
                                      angle:centerAngle.topAngle
                                      speed:speed
                             changeInterval:burstInterval
                                changeAngle:[angle floatValue]
                                changeSpeed:burstSpeed
                                     parent:[data getEnemyShotParent]];

    }
}

/*!
 @brief 逆さま判定
 
 上方向にある障害物と下方向にある障害物の近い方へ位置を移動する。
 上方向の方が近い場合は天井張り付き、下方向の方が近い場合は床に張り付きとする。
 存在しない場合は無限遠にあるものとして判定し、上下同じ場合は下側を優先する。
 @param blocks 障害物
 */
- (void)checkReverse:(NSArray *)blocks
{
    // 上方向距離と下方向距離の初期値を設定する
    float upDistance = FLT_MAX;
    float downDistance = FLT_MAX;
    
    // 移動先位置の初期値を設定する
    float upPosition = self.image.contentSize.height / 2;
    float downPosition = self.image.contentSize.height / 2;

    // 各障害物との距離を調べる
    for (AKCharacter *block in [blocks objectEnumerator]) {
        
        // x軸方向に重なりがない場合は処理を飛ばす
        if (fabsf(self.positionX - block.positionX) > (self.image.contentSize.width + block.image.contentSize.width) / 2) {
            continue;
        }
        
        // 障害物が上方向にある場合は上方向距離を更新する
        if (self.positionY < block.positionY) {
            
            // 距離が小さい場合は距離と移動先位置を更新する
            if (block.positionY - self.positionY < upDistance) {
                
                upDistance = block.positionY - self.positionY;
                upPosition = block.positionY - (block.height + self.image.contentSize.height) / 2;
            }
        }
        // 上方向にない場合は下方向距離を更新する
        else {
            
            // 距離が小さい場合は距離と移動先位置を更新する
            if (self.positionY - block.positionY < downDistance) {
                
                downDistance = self.positionY - block.positionY;
                downPosition = block.positionY + (block.height + self.image.contentSize.height) / 2;
            }
        }
    }
    
    // 上方向の距離が小さい場合は上方向に移動して、逆さにする
    if (upDistance < downDistance) {
        self.positionY = upPosition;
        self.image.flipY = YES;
    }
    // 下方向の距離が小さい場合は下方向に移動する
    else {
        self.positionY = downPosition;
    }
}

/*!
 @brief 障害物との衝突判定
 
 障害物との衝突判定を行う。
 移動先と移動元の段差が1/2ブロック以上ある場合は移動しない。
 左端の足元と右端の足元で障害物の高さが異なる場合は高い方（逆さまの場合は低い方）に合わせる。
 @param current 現在位置
 @param size キャラクターのサイズ
 @param isReverse 逆さまになっているかどうか
 @param data ゲームデータ
 @return 移動先の座標
 */
+ (CGPoint)checkBlockPosition:(CGPoint)current
                         size:(CGSize)size
                    isReverse:(BOOL)isReverse
                         data:(id<AKPlayDataInterface>)data;
{
    // 乗り越えることのできる高さ
    const NSInteger kAKHalfBlockSize = 17;
    
    // 頭の座標を計算する
    float top = 0.0f;
    if (!isReverse) {
        top = current.y + size.height / 2.0f;
    }
    else {
        top = current.y - size.height / 2.0f;
    }
        
    // 左端の座標を計算する
    float left = current.x - size.width / 2.0f;
    
    // 左側の足元の障害物を取得する
    AKCharacter *leftBlock = [AKEnemy getBlockAtFeetAtX:left
                                                   from:top
                                              isReverse:isReverse
                                                 blocks:data.blocks];
    
    // 右端の座標を計算する
    float right = current.x+ size.width / 2.0f;

    // 左側の足元の障害物を取得する
    AKCharacter *rightBlock = [AKEnemy getBlockAtFeetAtX:right
                                                    from:top
                                               isReverse:isReverse
                                                  blocks:data.blocks];
    
    AKLog(kAKLogEnemy_2, @"left=(%.0f, %.0f, %d, %d) right=(%.0f, %.0f, %d, %d)",
          leftBlock.positionX, leftBlock.positionY, leftBlock.width, leftBlock.height,
          rightBlock.positionX, rightBlock.positionY, rightBlock.width, rightBlock.height);
    
    // 足元に障害物がない場合は移動はしない
    if (leftBlock == nil && rightBlock == nil) {
        AKLog(kAKLogEnemy_2, @"足元に障害物なし");
        return current;
    }
    
    // 高さを合わせる障害物と移動先のx座標を決定する
    AKCharacter *blockAtFeet = nil;
    float newX = 0.0f;

    // 左側の障害物がない場合は自分の左端を右側の障害物の左端に合わせる
    if (leftBlock == nil) {
        AKLog(kAKLogEnemy_2, @"左側に障害物なし");
        newX = rightBlock.positionX - rightBlock.width / 2.0f + size.width / 2.0f;
        blockAtFeet = rightBlock;
    }
    // 右側の障害物がない場合は自分の右端を左側の障害物の右端に合わせる
    else if (rightBlock == nil) {
        AKLog(kAKLogEnemy_2, @"右側に障害物なし");
        newX = leftBlock.positionX + leftBlock.width / 2.0f - size.width / 2.0f;
        blockAtFeet = leftBlock;
    }
    // 左右の障害物の高さの差が1/2ブロック以上ある場合は進行方向と逆側の障害物に合わせる
    else if ((!isReverse && (fabsf((leftBlock.positionY + leftBlock.height / 2.0f) - (rightBlock.positionY + rightBlock.height / 2.0f)) > kAKHalfBlockSize)) ||
             (isReverse && (fabsf((leftBlock.positionY - leftBlock.height / 2.0f) - (rightBlock.positionY - rightBlock.height / 2.0f)) > kAKHalfBlockSize))) {
        
        // 近い方のブロックに移動する
        if  (rightBlock.positionX - current.x < current.x - leftBlock.positionX) {
            newX = rightBlock.positionX - rightBlock.width / 2.0f + size.width / 2.0f;
            blockAtFeet = rightBlock;
        }
        else {
            newX = leftBlock.positionX + leftBlock.width / 2.0f - size.width / 2.0f;
            blockAtFeet = leftBlock;
        }
    }
    // その他の場合は足元に近い方の高さに合わせる
    else {
        
        // 逆向きでない場合は上の方にあるものを採用する
        if (!isReverse) {
            if (leftBlock.positionY + leftBlock.height / 2.0f > rightBlock.positionY + rightBlock.height / 2.0f) {
                blockAtFeet = leftBlock;
            }
            else {
                blockAtFeet = rightBlock;
            }
        }
        // 逆向きの場合は下の方にあるものを採用する
        else {
            if (leftBlock.positionY - leftBlock.height / 2.0f < rightBlock.positionY - rightBlock.height / 2.0f) {
                blockAtFeet = leftBlock;
            }
            else {
                blockAtFeet = rightBlock;
            }
        }
        
        // x軸方向は移動しない
        newX = current.x;
    }
    
    // 移動先のy座標を決定する
    float newY = 0.0f;
    
    // 逆向きでない場合は自分の下端の位置を障害物の上端に合わせる
    if (!isReverse) {
        newY = blockAtFeet.positionY + blockAtFeet.height / 2.0f + size.height / 2.0f;
    }
    // 逆向きの場合は自分の上端の位置を障害物の下端に合わせる
    else {
        newY = blockAtFeet.positionY - blockAtFeet.height / 2.0f - size.height / 2.0f;
    }
    
    AKLog(kAKLogEnemy_2, @"(%.0f, %.0f)->(%.0f, %.0f)", current.x, current.y, newX, newY);
    
    // 移動先の座標を返す
    return ccp(newX, newY);
}

/*!
 @brief 足元の障害物を取得する
 
 足元の障害物を取得する。
 指定したx座標で一番上にある障害物を取得する。ただし、頭よりも上にある障害物は除外する。
 逆さまになっている場合は上下を逆にして検索を行う。
 @param x x座標
 @param top 頭の位置
 @param isReverse 逆さまになっているかどうか
 @param blocks 障害物
 @return 足元の障害物
 */
+ (AKCharacter *)getBlockAtFeetAtX:(float)x from:(float)top isReverse:(BOOL)isReverse blocks:(NSArray *)blocks
{    
    // 足元の障害物を探す
    AKCharacter *blockAtFeet = nil;
    for (AKCharacter *block in [blocks objectEnumerator]) {
        
        // 配置されていない障害物は除外する
        if (!block.isStaged) {
            continue;
        }
        
        // 障害物の幅の範囲内に指定座標が入っている場合
        if (roundf(block.positionX - block.width / 2) <= roundf(x) &&
            roundf(block.positionX + block.width / 2) >= roundf(x)) {
            
            // 逆さまでない場合
            if (!isReverse) {
                
                // 障害物の下端が自分の上端よりも下にあるものの内、
                // 一番上にあるものを採用する
                if (roundf(block.positionY - block.height / 2) <= roundf(top) &&
                    (blockAtFeet == nil || block.positionY + block.height / 2 > blockAtFeet.positionY + blockAtFeet.height / 2)) {
                    
                    blockAtFeet = block;
                }
            }
            // 逆さまの場合
            else {
                
                // 障害物の上端が自分の下端より上にあるものの内、
                // 一番下にあるものを採用する
                if (roundf(block.positionY + block.height / 2) > roundf(top) &&
                    (blockAtFeet == nil || block.positionY - block.height / 2 < blockAtFeet.positionY - blockAtFeet.height / 2)) {
                    
                    blockAtFeet = block;
                }
            }
        }
    }
    
    return blockAtFeet;
}

@end

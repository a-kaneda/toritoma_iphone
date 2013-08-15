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
    //破壊,画像,フレーム数,フレーム間隔幅,高さ,HP,スコア
    {1, 1, 2, 0.5f, 32, 32, 3, 100},     // トンボ
    {1, 2, 2, 0.5f, 32, 16, 3, 100},     // アリ
    {1, 3, 2, 0.5f, 32, 32, 3, 100},     // チョウ
    {1, 4, 2, 0.1f, 32, 32, 5, 100},     // テントウムシ
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備5
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備6
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備7
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備8
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備9
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備10
    {1, 11, 1, 0.0f, 32, 32, 10, 100},   // ミノムシ
    {1, 12, 1, 0.0f, 32, 32, 5, 100},    // セミ
    {1, 13, 1, 0.0f, 32, 32, 3, 100},    // バッタ
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // ハチ
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備15
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備16
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備17
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備18
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備19
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備20
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // ゴキブリ
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // カタツムリ
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // クワガタ
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備24
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備25
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備26
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備27
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備28
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備29
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // 予備30
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // カブトムシ
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // カマキリ
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // ハチの巣
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // クモ
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // ムカデ（頭）
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // ムカデ（胴体）
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // ムカデ（尾）
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // ウジ
    {0, 0, 0, 0.0f, 0, 0, 0, 0},         // ハエ
    {0, 0, 0, 0.0f, 0, 0, 0, 0}          // 予備40
};

/// 標準弾の種別
static const NSInteger kAKEnemyShotTypeNormal = 1;
/// スクロール影響弾の種別
static const NSInteger kAKEnemyShotTypeScroll = 2;

/*!
 @brief 敵クラス
 
 敵キャラクターのクラス。
 */
@implementation AKEnemy

/*!
 @brief キャラクター固有の動作

 生成時に指定されたセレクタを呼び出す。
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)action:(ccTime)dt data:(id<AKPlayDataInterface>)data
{
    NSNumber *objdt = NULL;     // フレーム更新間隔(オブジェクト版)
    
    // 動作開始からの経過時間をカウントする
    time_ += dt;
    
    // id型として渡すためにNSNumberを作成する
    objdt = [NSNumber numberWithFloat:dt];
    
    // 敵種別ごとの処理を実行
    [self performSelector:action_ withObject:objdt withObject:data];
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
    time_ = 0.0f;
    state_ = 0;
    work_ = 0;
    
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
    
    // ヒットポイントを設定する
    self.hitPoint = kAKEnemyDef[type - 1].hitPoint;
    
    // スコアを設定する
    score_ = kAKEnemyDef[type - 1].score;
    
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
            return @selector(actionOfDragonfly:data:);
            
        case kAKEnemyAnt:       // アリの動作処理
            return @selector(actionOfAnt:data:);
            
        case kAKEnemyButterfly: // チョウの動作処理
            return @selector(actionOfButterfly:data:);
        
        case kAKEnemyLadybug:   // テントウムシの動作処理
            return @selector(actionOfLadybug:data:);
            
        case kAKEnemyBagworm:   // ミノムシの動作処理
            return @selector(actionOfBagworm:data:);
            
        case kAKEnemyCicada:    // セミの動作処理
            return @selector(actionOfCicada:data:);
            
        case kAKEnemyGrasshopper:   // バッタの動作処理
            return @selector(actionOfGrasshopper:data:);
            
        default:
            AKLog(kAKLogEnemy_0, @"不正な種別:%d", type);
            NSAssert(NO, @"不正な種別");
            return @selector(actionOfDragonfly:data:);
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
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)actionOfDragonfly:(NSNumber *)dt data:(id<AKPlayDataInterface>)data
{
    // 左へ直進する
    self.speedX = -90.0f;
    self.speedY = 0.0f;
    
    // 一定時間経過しているときは左方向へ1-way弾を発射する
    if (time_ > 1.5f) {
        
        // 左へ弾を発射する
        [AKEnemy fireNWayWithAngle:M_PI
                              from:ccp(self.positionX, self.positionY)
                             count:1
                          interval:0.0f
                             speed:150.0f
                              type:kAKEnemyShotTypeNormal
                              data:data];
        
        // 動作時間の初期化を行う
        time_ = 0.0f;
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
 
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)actionOfAnt:(NSNumber *)dt data:(id<AKPlayDataInterface>)data
{
    // 弾のスピード
    const float kAKShotSpeed = 150.0f;
    // 移動スピード
    const float kAKMoveSpeed = 48.0f;
    // 移動する時間
    const float kAKMoveTime = 2.0f;
    // 弾を発射する間隔
    const float kAKFireInterval = 0.5f;
    // 一度に発射する弾の数
    const NSInteger kAKFireCount = 4;
    
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
            
             // 動作時間の初期化を行う
            time_ = 0.0f;
            
            // 左移動に遷移する
            state_ = kAKStateLeftMove;
            
            break;
            
        case kAKStateLeftMove:  // 左移動
            
            // スピードをマイナスにして、左右反転はなしにする
            self.speedX = -kAKMoveSpeed;
            self.image.flipX = NO;
            
            // 移動時間が経過したら弾発射に遷移する
            if (time_ > kAKMoveTime) {
                time_ = 0.0f;
                state_ = kAKStateFire;
            }

            break;

        case kAKStateRightMove: // 右移動
            
            // スピードをプラスにして、左右反転はありにする
            self.speedX = kAKMoveSpeed;
            self.image.flipX = YES;
            
            // 移動時間が経過したら弾発射に遷移する
            if (time_ > kAKMoveTime) {
                time_ = 0.0f;
                state_ =kAKStateFire;
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
            self.speedX = 0;
            
            // 一定時間経過したら弾を発射する
            if (time_ > kAKFireInterval) {
                
                // 一度に発射する弾をすでに発射済みの場合は右移動へ遷移する
                if (work_ >= kAKFireCount) {
                    
                    work_ = 0;
                    time_ = 0.0f;
                    state_ = kAKStateRightMove;
                }
                else {
                    
                    // 自機へ向けて弾を発射する
                    [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                            count:1
                                         interval:0.0f
                                            speed:kAKShotSpeed data:data];
                    
                    // 発射した弾をカウントする
                    work_++;
                    
                    // 動作時間の初期化を行う
                    time_ = 0.0f;
                }
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
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)actionOfButterfly:(NSNumber *)dt data:(id<AKPlayDataInterface>)data
{
    // 左方向への速度を決める
    self.speedX = -70.0f;
    
    // 一定時間経過している場合は上下の移動方向の状態を逆にする
    if (time_ > 0.8f) {
        state_ = 1 - state_;
        time_ = 0.0f;
    }
    
    // 状態に応じて上下の移動方向を決める
    if (state_ == 0) {
        self.speedY = 120.0f;
    }
    else {
        self.speedY = -120.0f;
    }
    
    // 弾発射間隔カウント用にwork領域を使用する
    work_ += [dt floatValue];
    
    AKLog(kAKLogEnemy_3, "work=%f", work_);
    
    // 一定時間経過しているときは左方向へ3-way弾を発射する
    if (work_ > 1.0f) {
        
        // 左へ弾を発射する
        [AKEnemy fireNWayWithAngle:M_PI
                              from:ccp(self.positionX, self.positionY)
                             count:3
                          interval:M_PI / 8.0f
                             speed:150.0f
                              type:kAKEnemyShotTypeNormal
                              data:data];
        
        // 動作時間の初期化を行う
        work_ = 0.0f;
    }
}

/*!
 @brief テントウムシの動作処理
 
 まっすぐ進む。一定間隔で自機を狙う1-way弾発射。
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)actionOfLadybug:(NSNumber *)dt data:(id<AKPlayDataInterface>)data
{
    // 左へ直進する
    self.speedX = -65.0f;
    self.speedY = 0.0f;
    
    // 一定時間経過しているときは自機を狙う1-way弾を発射する
    if (time_ > 1.2f) {
        
        // 自機へ向けて弾を発射する
        [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                count:1
                             interval:0.0f
                                speed:120.0f
                                 data:data];
        
        // 動作時間の初期化を行う
        time_ = 0.0f;
    }
}

/*!
 @brief ミノムシの動作処理
 
 スクロールスピードに合わせて移動する。一定時間で全方位に12-way弾を発射する。
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)actionOfBagworm:(NSNumber *)dt data:(id<AKPlayDataInterface>)data
{
    // スクロールスピードに合わせて移動する
    self.speedX = -data.scrollSpeedX;
    self.speedY = -data.scrollSpeedY;
    
    // 一定時間経過しているときは全方位に弾を発射する
    if (time_ > 1.0f) {
        
        // 全方位に 12-way弾を発射する
        [AKEnemy fireNWayWithAngle:M_PI
                              from:ccp(self.positionX, self.positionY)
                             count:12
                          interval:M_PI / 6.0f
                             speed:50.0f
                              type:kAKEnemyShotTypeScroll
                              data:data];
        
        // 動作時間の初期化を行う
        time_ = 0.0f;
    }
}

/*!
 @brief セミの動作処理
 
 自機に向かって一定時間飛ぶ。その後待機して自機に向かって3-way弾を発射する。
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)actionOfCicada:(NSNumber *)dt data:(id<AKPlayDataInterface>)data
{
    // 移動スピード
    const float kAKSpeed = 120.0f;

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
            self.animationInterval = 0.1f;
            self.animationInitPattern = 11;
            
            // 左移動の状態へ遷移する
            state_ = kAKStateLeftMove;
            
            // 経過時間、作業領域は初期化する
            time_ = 0.0f;
            work_ = 0.0f;
        }
            break;
            
        case kAKStateLeftMove:     // 左へ移動
            
            // 一定時間経過したら次の状態へ進める
            if (time_ > 1.0f) {
                
                // 弾発射の状態へ遷移する
                state_= kAKStateFire;
                
                // 停止する（スクロールスピードに合わせる）
                self.speedX = -data.scrollSpeedX;
                self.speedY = -data.scrollSpeedY;
                
                // 待機中はアニメーションを無効化
                self.animationPattern = 1;
                self.animationInterval = 0.0f;
                self.animationInitPattern = 1;
                
                // 経過時間、作業領域は初期化する
                time_ = 0.0f;
                work_ = 0.0f;
            }
            break;
            
        case kAKStateFire:  // 弾発射
            
            // 弾発射間隔経過で自機に向かって3-way弾を発射する
            if (time_ - work_ > 0.3f) {
                
                [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                        count:3
                                     interval:M_PI / 8.0f
                                        speed:120.0f
                                         data:data];
                
                // 作業領域を経過時間で初期化する
                work_ = time_;
            }
            
            // 待機間隔経過で初期状態に戻る
            if (time_ > 1.0f) {
                
                // 初期状態へ遷移する
                state_ = kAKStateInit;
                
                // 経過時間、作業領域は初期化する
                time_ = 0.0f;
                work_ = 0.0f;
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
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)actionOfGrasshopper:(NSNumber *)dt data:(id<AKPlayDataInterface>)data
{
    // 移動スピード
    const float kAKMoveSpeed = -60.0f;
    // ジャンプのスピード
    const float kAKJumpSpeed = 240.0f;
    // 重力加速度
    const float kAKGravitationAlacceleration = 480.0f;
    
    // 状態
    enum STATE {
        kAKStateInit = 0,           // 初期状態
        kAKStateLeftMove,           // 左移動
        kAKStateWait                // 待機
    };
    
    // スクロールに合わせて移動する
    self.scrollSpeed = 1.0f;
    
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
            self.speedY -= kAKGravitationAlacceleration * [dt floatValue];
        }
        else {
            self.speedY += kAKGravitationAlacceleration * [dt floatValue];
        }

        // 一定時間経過したら次の状態へ進める
        if (time_ > 1.0f) {
            
            // 弾発射の状態へ遷移する
            state_= kAKStateWait;
            
            // 停止する
            self.speedX = 0.0f;
            
            // 経過時間、作業領域は初期化する
            work_ -= time_;
            time_ = 0.0f;
        }
    }
    
    // 落ちていく方向の障害物に接触している場合、着地したとしてスピードを0にする。
    if ((!self.image.flipY && (self.blockHitSide & kAKHitSideBottom)) ||
        (self.image.flipY && (self.blockHitSide & kAKHitSideTop))) {
        
        self.speedX = 0.0f;
        self.speedY = 0.0f;
    }
    
    // 初期状態または待機中で待機時間が経過している場合
    if ((state_ == kAKStateInit) || (state_ == kAKStateWait && (time_ > 1.0f))) {
        
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
        
        // 経過時間、作業領域は初期化する
        work_ -= time_;
        time_ = 0.0f;
    }

    // 弾発射間隔経過で自機に向かって1-way弾を発射する
    if (time_ - work_ > 0.5f) {
        
        [AKEnemy fireNWayWithPosition:ccp(self.positionX, self.positionY)
                                count:1
                             interval:0.0f
                                speed:120.0f
                                 data:data];
        
        // 作業領域を経過時間で初期化する
        work_ = time_;
    }
    
    AKLog(kAKLogEnemy_3, @"speed=(%f, %f)", self.speedX, self.speedY);
    
    // 画像表示位置の更新を行う
    [self updateImagePosition];
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
    // n-way弾の角度計算用のクラスを生成する
    AKNWayAngle *nWayAngle = [AKNWayAngle angle];
    
    // 各弾の角度を計算する
    NSArray *angles = [nWayAngle calcNWayAngleFromSrc:position
                                                 dest:data.playerPosition
                                                count:count
                                             interval:interval];
    
    // 各弾を発射する
    for (NSNumber *angle in angles) {
        // 通常弾を生成する
        [data createEnemyShotType:kAKEnemyShotTypeNormal
                                x:position.x
                                y:position.y
                            angle:[angle floatValue]
                            speed:speed];
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
 @param type 弾の種別
 @param data ゲームデータ
 */
+ (void)fireNWayWithAngle:(float)angle
                     from:(CGPoint)position
                    count:(NSInteger)count
                 interval:(float)interval
                    speed:(float)speed
                     type:(NSInteger)type
                     data:(id<AKPlayDataInterface>)data
{
    // n-way弾の角度計算用のクラスを生成する
    AKNWayAngle *nWayAngle = [AKNWayAngle angle];
    
    // 各弾の角度を計算する
    NSArray *angles = [nWayAngle calcNWayAngleFromCenterAngle:angle
                                                        count:count
                                                     interval:interval];
    
    // 各弾を発射する
    for (NSNumber *angle in angles) {
        // 通常弾を生成する
        [data createEnemyShotType:type
                                x:position.x
                                y:position.y
                            angle:[angle floatValue]
                            speed:speed];
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
        if (abs(self.positionX - block.positionX) > (self.image.contentSize.width + block.image.contentSize.width) / 2) {
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
    else if ((!isReverse && (abs((leftBlock.positionY + leftBlock.height / 2.0f) - (rightBlock.positionY + rightBlock.height / 2.0f)) > kAKHalfBlockSize)) ||
             (isReverse && (abs((leftBlock.positionY - leftBlock.height / 2.0f) - (rightBlock.positionY - rightBlock.height / 2.0f)) > kAKHalfBlockSize))) {
        
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

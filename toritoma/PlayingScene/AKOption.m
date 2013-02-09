//
//  AKOption.m
//  toritoma
//
//  Created by KANEDA AKIHIRO on 2013/02/06.
//  Copyright (c) 2013年 KANEDA AKIHIRO. All rights reserved.
//

#import "AKOption.h"
#import "AKPlayData.h"

/// オプションの画像ファイル名
static NSString *kAKOptionImageFile = @"Option_%02d";
/// シールドなし時のアニメーションフレーム数
static const NSInteger kAKOptionAnimationCountOfShieldOff = 2;
/// シールドあり時のアニメーションフレーム数
static const NSInteger kAKOptionAnimationCountOfShieldOn = 1;
/// 弾発射の間隔
static const float kAKOptionShotInterval = 0.2f;
/// オプション間の距離
static const NSInteger kAKOptionSpace = 20;
/// オプションの当たり判定
static const NSInteger kAKOptionSize = 16;

@implementation AKOption

@synthesize movePositions = movePositions_;
@synthesize shield = shield_;

/*!
 @brief オブジェクト生成処理
 
 オブジェクトの生成を行う。
 指定されたオプションの個数分を再帰的に生成する。
 @param count オプションの個数
 @param parent 画像を配置する親ノード
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithOptionCount:(NSInteger)count parent:(CCNode *)parent
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // アニメーションフレームの個数を設定する
    self.animationPattern = kAKOptionAnimationCountOfShieldOff;
    
    // 画像名を設定する
    self.imageName = [NSString stringWithFormat:kAKOptionImageFile, 1];
    
    // 弾発射までの残り時間を設定する
    shootTime_ = kAKOptionShotInterval;
    
    // 移動座標を保存する配列を作成する
    self.movePositions = [NSMutableArray arrayWithCapacity:kAKOptionSpace];
    
    // ヒットポイントは1としておく
    self.hitPoint = 1;
    
    // オプションの当たり判定を設定する
    // これはシールド時のみ使用する
    self.width = kAKOptionSize;
    self.height = kAKOptionSize;
    
    // 初期状態はシールドなしとする
    self.shield = NO;

    // 初期状態では画面には配置しない
    self.isStaged = NO;
    self.image.visible = NO;
    
    // 画像を親ノードに配置する
    [parent addChild:self.image];
    
    // オプション個数が指定されている場合は次のオプションを生成する
    if (count > 0) {
        self.next = [[[AKOption alloc] initWithOptionCount:count - 1 parent:parent] autorelease];
    }
    
    return self;
}

/*!
 @brief インスタンス解放時処理
 
 インスタンス解放時にメンバを解放する。
 */
- (void)dealloc
{
    // メンバを解放する
    self.movePositions = nil;
    
    // スーパークラスの解放処理
    [super dealloc];
}

/*!
 @brief シールド有無設定
 
 シールド有無を設定する。
 画像の切り替えも行う。
 次のオプションに対しても同様の設定を行う。
 @param shield シールド有無
 */
- (void)setShield:(Boolean)shield
{
    // メンバに設定する
    shield_ = shield;
        
    // シールド有無によって画像を切り替える
    if (shield) {
        
        AKLog(0, @"シールドあり");
        
        // 画像名を設定する
        self.imageName = [NSString stringWithFormat:kAKOptionImageFile, 2];
        
        // アニメーションフレームの個数を設定する
        self.animationPattern = kAKOptionAnimationCountOfShieldOn;
    }
    else {

        AKLog(0, @"シールドなし");

        // 画像名を設定する
        self.imageName = [NSString stringWithFormat:kAKOptionImageFile, 1];
        
        // アニメーションフレームの個数を設定する
        self.animationPattern = kAKOptionAnimationCountOfShieldOff;
    }
    
    // 次のオプションがある場合は次のオプションにも設定する
    if (self.next != nil) {
        self.next.shield = shield;
    }
}

/*!
 @brief キャラクター固有の動作
 
 速度によって位置を移動する。オプションの表示位置は固定とする。
 次のオプションの移動を行う。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    // 弾発射までの時間をカウントする
    shootTime_ -= dt;
    
    // 弾発射までの残り時間が0になっている場合は弾を発射する
    if (shootTime_ < 0.0f) {
        
        // 自機弾を生成する
        [[AKPlayData sharedInstance] createPlayerShotAtX:self.positionX y:self.positionY];
        
        // 弾発射までの残り時間をリセットする
        shootTime_ = kAKOptionShotInterval;
    }
    
    // 次のオプションの移動を行う
    if (self.next != nil) {
        [self.next move:dt];
    }
}

/*!
 @brief 衝突処理
 
 衝突した時の処理。
 反射弾を作成後、相手のHPを0にする。
 @param character 衝突した相手
 */
- (void)hit:(AKCharacter *)character
{
    AKLog(1, @"反射処理開始");
    
    // 衝突したものが敵弾以外の場合はエラー
    NSAssert([character isKindOfClass:[AKEnemyShot class]], @"不正なオブジェクトと衝突");
    
    // 反射弾を作成する
    [[AKPlayData sharedInstance] createReflectiedShot:(AKEnemyShot *)character];
    
    // 相手のHPを0にする
    character.hitPoint = 0;
}

/*!
 @brief 移動座標設定
 
 移動座標を設定する。オプションが付属している場合はオプションの移動も行う。
 @param x 移動先x座標
 @param y 移動先y座標
 */
- (void)setPositionX:(float)x y:(float)y
{
    // オプションに自分の移動前の座標を通知する
    if (self.next != nil && self.next.isStaged) {
        [self.next setPositionX:self.positionX y:self.positionY];
    }
    
    // 移動先座標が間隔分溜まっている場合は先頭の座標に移動する
    if (self.movePositions.count >= kAKOptionSpace) {
        
        // 先頭の要素を取得する
        NSData *data = [self.movePositions objectAtIndex:0];
        
        // 取得した要素を配列から取り除く
        [self.movePositions removeObjectAtIndex:0];
        
        // 先頭の要素から座標情報を取得する
        CGPoint point;
        [data getBytes:&point length:sizeof(point)];
        
        // 座標を移動する
        self.positionX = point.x;
        self.positionY = point.y;
    }
    
    // 移動先座標の構造体を作成する
    CGPoint newPoint = ccp(x, y);
    
    // 配列に格納するために座標オブジェクトを作成する
    NSData *newData = [NSData dataWithBytes:&newPoint length:sizeof(newPoint)];
    
    // 移動先座標の配列の末尾に追加する
    [self.movePositions addObject:newData];
}

/*!
 @brief オプション数設定
 
 オプションの個数を設定する。
 1以上が設定された場合は自分を配置状態に設定する。
 0以下が設定された場合は自分を配置状態から外す。
 次のオプションが存在する場合は個数を一つ減らして再帰的に呼び出す。
 @param count オプション個数
 @param x 初期配置位置x座標
 @param y 初期配置位置y座標
 */
- (void)setOptionCount:(NSInteger)count x:(float)x y:(float)y
{
    AKLog(0, @"count=%d", count);
    
    // オプション個数が設定された場合はオプションを有効とする
    if (count > 0) {
        
        // 配置されていない場合は配置状態にして、初期配置位置に移動する
        if (!self.isStaged) {
            AKLog(1, @"オプション配置");
            self.isStaged = YES;
            self.image.visible = YES;
            self.positionX = x;
            self.positionY = y;
            // 初期表示時に前回の位置に表示されることを防ぐため、画像位置も変更する
            self.image.position = ccp([AKScreenSize xOfStage:self.positionX],
                                      [AKScreenSize yOfStage:self.positionY]);
        }
    }
    // オプション個数が0以下の場合はオプションを無効とする
    else {
        
        // 配置されている場合は配置状態を解除して、移動座標をすべてクリアする
        if (self.isStaged) {
            AKLog(1, @"オプション削除");
            self.isStaged = NO;
            self.image.visible = NO;
            [self.movePositions removeAllObjects];
        }
    }
    
    // 自分の座標を初期座標として次のオプションを設定する
    if (self.next != nil) {
        [self.next setOptionCount:count - 1 x:self.positionX y:self.positionY];
    }
}

@end

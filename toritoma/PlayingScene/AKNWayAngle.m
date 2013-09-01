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
 @file AKNWayAngle.m
 @brief n-way弾角度計算クラス定義
 
 n-way弾角度の計算を行うクラスを定義する。
 */

#import "AKNWayAngle.h"

/*!
 @brief n-way弾角度計算クラス
 
 n-way弾を作成する際の角度を計算するクラス。
 */
@implementation AKNWayAngle

@synthesize angles = angles_;

/*!
 @brief 1個目の弾の角度
 
 1個目の弾の角度を取得する。
 @return 1個目の弾の角度
 */
- (float)topAngle
{
    return [[angles_ objectAtIndex:0] floatValue];
}

/*!
 @brief コンビニエンスコンストラクタ
 
 コンビニエンスコンストラクタ。
 @return 初期化したオブジェクト
 */
+ (id)angle
{
    return [[[AKNWayAngle alloc] init] autorelease];
}

/*!
 @brief オブジェクト解放処理
 
 オブジェクトの解放を行う。
 */
- (void)dealloc
{
    // メンバを解放する
    self.angles = nil;
    
    // スーパークラスの処理を行う
    [super dealloc];
}

/*!
 @brief 2点間指定によるn-way角度計算
 
 2点の座標からn-way弾の各弾の角度を計算する。
 @param src 始点
 @param dest 終点
 @param count 弾数
 @param interval 弾の間の角度
 @return 初期化したインスタンス
 */
- (id)initFromSrc:(CGPoint)src dest:(CGPoint)dest count:(NSInteger)count interval:(float)interval
{
    // 中心の弾の角度を計算する
    float centerAngle = [AKNWayAngle calcDestAngleFrom:src to:dest];
    
    // 中心角からn-way角度を計算する
    return [self initFromCenterAngle:centerAngle count:count interval:interval];
}

/*!
 @brief 中心角度指定によるn-way角度計算
 
 中心の弾の角度からn-way弾の各弾の角度を計算する。
 @param center 中心角度
 @param count 弾数
 @param interval 弾の間の角度
 @return 初期化したインスタンス
 */
- (id)initFromCenterAngle:(float)center count:(NSInteger)count interval:(float)interval
{
    // スーパークラスの初期化処理を行う
    self = [super init];
    if (!self) {
        NSAssert(NO, @"インスタンスの初期化に失敗。");
        return nil;
    }
    
    // 角度格納用配列を生成する
    self.angles = [NSMutableArray arrayWithCapacity:count];

    // 最小値の角度を計算する
    float minAngle = center - (interval * (count - 1)) / 2.0f;

    // 各弾の発射角度を計算する
    for (int i = 0; i < count; i++) {
    
        // 弾の角度を計算する
        float angle = minAngle + i * interval;
    
        // NSArrayに格納するためにオブジェクトを作成する
        NSNumber *angleObj = [NSNumber numberWithFloat:angle];
    
        // 配列に追加する
        [angles_ addObject:angleObj];
    }

    return self;
}

/*!
 @brief 2点間指定によるn-way角度計算(コンビニエンスコンストラクタ)
 
 2点の座標からn-way弾の各弾の角度を計算する。
 @param src 始点
 @param dest 終点
 @param count 弾数
 @param interval 弾の間の角度
 @return 生成したインスタンス
 */
+ (id)angleFromSrc:(CGPoint)src dest:(CGPoint)dest count:(NSInteger)count interval:(float)interval
{
    return [[[AKNWayAngle alloc] initFromSrc:src dest:dest count:count interval:interval] autorelease];
}

/*!
 @brief 中心角度指定によるn-way角度計算
 
 中心の弾の角度からn-way弾の各弾の角度を計算する。
 @param center 中心角度
 @param count 弾数
 @param interval 弾の間の角度
 @return 生成したインスタンス
 */
+ (id)angleFromCenterAngle:(float)center count:(NSInteger)count interval:(float)interval
{
    return [[[AKNWayAngle alloc] initFromCenterAngle:center count:count interval:interval] autorelease];
}

/*!
 @brief 2点間の角度計算
 
 2点間を線で結んだときの角度を計算する。
 @param srcx 始点
 @param dest 終点
 @return 2点間の角度
 */
+ (float)calcDestAngleFrom:(CGPoint)src to:(CGPoint)dest
{
    // x方向のベクトルの大きさを計算する
    float vx = dest.x - src.x;
    
    // y方向のベクトルの大きさを計算する
    float vy = dest.y - src.y;

    // 角度を計算する
    float angle = atan(vy / vx);
    
    // 第2象限、第3象限の場合はπ進める
    if (vx < 0.0f) {
        angle += M_PI;
    }
        
    return angle;
}
@end

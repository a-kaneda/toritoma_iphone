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
 @file AKNWayAngle.h
 @brief n-way弾角度計算クラス定義
 
 n-way弾角度の計算を行うクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

// n-way弾角度計算クラス
@interface AKNWayAngle : NSObject {
    /// 弾の角度
    NSMutableArray *angles_;
}

/// 弾の角度
@property (nonatomic, retain)NSMutableArray *angles;

// コンビニエンスコンストラクタ
+ (id)angle;
// 2点間指定によるn-way角度計算
- (NSArray *)calcNWayAngleFromSrc:(CGPoint)src dest:(CGPoint)dest count:(NSInteger)count interval:(float)interval;
// 中心角度指定によるn-way角度計算
- (NSArray *)calcNWayAngleFromCenterAngle:(float)center count:(NSInteger)count interval:(float)interval;
// 2点間の角度計算
+ (float)calcDestAngleFrom:(CGPoint)src to:(CGPoint)dest;

@end

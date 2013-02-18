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
 @file AKOption.h
 @brief オプションクラス
 
 オプションを管理するクラスを定義する。
 */

#import "AKCharacter.h"

// オプションクラス
@interface AKOption : AKCharacter {
    /// 移動座標
    NSMutableArray *movePositions_;
    /// 弾発射までの残り時間
    float shootTime_;
    /// 次のオプション
    AKOption *next_;
    /// シールド有無
    BOOL shield_;
}

/// 移動座標
@property (nonatomic, retain)NSMutableArray *movePositions;
/// 次のオプション
@property (nonatomic, retain)AKOption *next;
/// シールド有無
@property (nonatomic)BOOL shield;

// 初期化処理
- (id)initWithOptionCount:(NSInteger)count parent:(CCNode *)parent;
// 移動座標設定
- (void)setPositionX:(float)x y:(float)y;
// オプション数設定
- (void)setOptionCount:(NSInteger)count x:(float)x y:(float)y;

@end

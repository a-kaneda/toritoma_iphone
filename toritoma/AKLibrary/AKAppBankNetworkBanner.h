/*
 * Copyright (c) 2012-2013 Akihiro Kaneda.
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
 @file AKAppBankNetworkBanner.h
 @brief AppBankNetworkの広告バナー
 
 AppBankNetworkの広告バナーを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "GADCustomEventBanner.h"
#import "NADView.h"

// AppBankNetworkのapiKey(アプリケーションで個別に定義する)
extern NSString *kAKAPIKey;
// AppBankNetworkのspotID(アプリケーションで個別に定義する)
extern NSString *kAKSpotID;

// AppBankNetworkの広告バナー
@interface AKAppBankNetworkBanner : NSObject <NADViewDelegate, GADCustomEventBanner> {
    /// デリゲート
    id<GADCustomEventBannerDelegate> delegate_;
    /// 広告バナー
    NADView *nadView_;
}

/// デリゲート
@property (nonatomic, assign)id<GADCustomEventBannerDelegate> delegate;
/// 広告バナー
@property (nonatomic, retain)NADView *nadView;

@end

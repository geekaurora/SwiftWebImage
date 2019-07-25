//
//  CZWebImagePrefetcher.m
//  CZWebImage
//
//  Created by Cheng Zhang on 1/30/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

#import "CZWebImagePrefetcher.h"
#import "CZWebImageUtils.h"
#import <CZWebImage/CZWebImage-Swift.h>

static const NSUInteger CZDefaultMaxConcurrentCount = 3;

@interface CZWebImagePrefetcher()

@property(nonatomic, strong)CZWebImageManager *manager;
@property(nonatomic, copy)NSArray *prefetchURLs;
@property(nonatomic, copy)SDWebImagePrefetcherCompletionBlock completion;

/// The amount of all requested prefetches
@property(nonatomic, assign)NSUInteger requestedCount;
@property(nonatomic, assign)NSUInteger finishedCount;
@property(nonatomic, assign)NSUInteger maxConcurrentCount;

@end

@implementation CZWebImagePrefetcher

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static CZWebImagePrefetcher *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[CZWebImagePrefetcher alloc] init];
    });

    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _manager = [[CZWebImageManager alloc] init];
        _maxConcurrentCount = CZDefaultMaxConcurrentCount;
        [self reset];
    }
    return self;
}

- (void)pretchURLs:(NSArray *)urls completion:(SDWebImagePrefetcherCompletionBlock)completion {
    [self cancelPrefetching];

    @synchronized (self.prefetchURLs) {
        self.prefetchURLs = urls;
        self.completion = completion;
        
        if (urls.count == 0) {
            completion(0, 0);
        }
        [self runNextInnerFetch];
    }
}

/**
 *  Fetch urls of the next loop based on maxConcurrentCount setting
 */
- (void)runNextInnerFetch {
    @synchronized(self.prefetchURLs) {
        for (NSUInteger i = self.requestedCount; i < self.prefetchURLs.count; i++) {
            NSUInteger runningCount = self.requestedCount - self.finishedCount;
            if (runningCount + 1 <= self.maxConcurrentCount) {
                [self startPrefetchAtIndex: i];
            } else {
                break;
            }
        }
    }
}

- (void)startPrefetchAtIndex:(NSUInteger)index {
    @synchronized(self.prefetchURLs) {
        if (index > self.prefetchURLs.count - 1) {
            return;
        }
        self.requestedCount++;
        NSURL *url = [self.prefetchURLs objectAtIndex:index];
        weakifySelf;
        [self.manager downloadImageWithURL:url
                                  cropSize:CGSizeZero
                              downloadType:Operation.QueuePriorityPrefetch
                         completionHandler:^(UIImage *image, NSNumber *isFromDisk, NSURL *imageUrl) {
                             weakSelf.finishedCount++;

                             /* Finished current prefech */
                             if (weakSelf.delegate &&
                                 [weakSelf.delegate respondsToSelector:@selector(imagePrefetcher:didPrefetchURL:finishedCount:totalCount:)]) {
                                 [weakSelf.delegate imagePrefetcher:self didPrefetchURL:imageUrl finishedCount:self.finishedCount totalCount:self.prefetchURLs.count];
                             }

                             if (weakSelf.finishedCount == self.prefetchURLs.count) {
                                 /* Finished all prefeches */
                                 if (weakSelf.delegate &&
                                     [weakSelf.delegate respondsToSelector:@selector(imagePrefetcher:didFinishWithTotalCount:skippedCount:)]) {
                                     [weakSelf.delegate imagePrefetcher:self didFinishWithTotalCount:self.prefetchURLs.count skippedCount:0];
                                 }

                                 if (weakSelf.completion) {
                                     weakSelf.completion(self.finishedCount, 0);
                                 }
                             } else {
                                 [weakSelf runNextInnerFetch];
                             }
                         }];
    }
}

- (void)cancelPrefetching {
    @synchronized (self.prefetchURLs) {
        if (self.prefetchURLs) {
            for (NSURL *url in self.prefetchURLs) {
                [self.manager cancelDownloadWithURL:url];
            }
        }
        [self reset];
    }
}

- (void)reset {
    self.prefetchURLs = nil;
    self.requestedCount = 0;
    self.finishedCount = 0;
}

@end

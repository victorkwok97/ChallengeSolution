//
//  LWWElementSet.h
//  GoodNotesChallenge
//
//  Created by Victor Kwok on 3/12/2018.
//  Copyright © 2018 VICTOR. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWWElementSet : NSObject

@property (atomic, strong) NSMutableArray *addElementsSet, *removeElementsSet;

- (void)addElement:(NSObject *)object forTimestamp:(double)timestamp;
- (void)removeElement:(NSObject *)object forTimestamp:(double)timestamp;
- (NSArray *)elements;
- (void)mergeSet:(LWWElementSet *)mergingSet;
- (id)copy;

@end

NS_ASSUME_NONNULL_END

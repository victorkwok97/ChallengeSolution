//
//  LWWElementSet.m
//  GoodNotesChallenge
//
//  Created by Victor Kwok on 3/12/2018.
//  Copyright © 2018 VICTOR. All rights reserved.
//

#import "LWWElementSet.h"

@implementation LWWElementSet

- (instancetype)init {
    self = [super init];
    if (self) {
        self.addElementsSet = [[NSMutableArray alloc] init];
        self.removeElementsSet = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addElement:(NSObject *)object forTimestamp:(double)timestamp {
    [self addElement:object forTimestamp:timestamp toSet:self.addElementsSet];
}

- (void)removeElement:(NSObject *)object forTimestamp:(double)timestamp {
    [self addElement:object forTimestamp:timestamp toSet:self.removeElementsSet];
}

- (void)addElement:(NSObject *)object forTimestamp:(double)timestamp toSet:(NSMutableArray *)set {
    // Add element inspiration was taken from the lww-element-set project repository by Junji Zhi written in Python:
    // Link to the repository: https://github.com/junjizhi/lww-element-set
    
    // Constructs a dictionary to wrap around the element together with a timestamp
    NSDictionary *elementDictionary = @{
                                        @"element": object,
                                        @"timestamp": [NSNumber numberWithDouble:timestamp]
                                        };
    NSArray *dataArray = [set valueForKeyPath:@"element"];
    if ([dataArray containsObject:object]) {
        // If the object exists int the set already, update the timestamp instead of adding a new one
        NSInteger index = [dataArray indexOfObject:object];
        if (timestamp > [set[index][@"timestamp"] doubleValue]) {
            [set replaceObjectAtIndex:index withObject:elementDictionary];
        }
    }
    else {
        [set addObject:elementDictionary];
    }
}

- (NSArray *)elements {
    NSMutableArray *elementsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *elementDictionary in self.addElementsSet) {
        NSArray *removedDataArray = [self.removeElementsSet valueForKeyPath:@"element"];
        if ([removedDataArray containsObject:elementDictionary[@"element"]]) {
            double removeTimestamp = [self.removeElementsSet[[removedDataArray indexOfObject:elementDictionary[@"element"]]][@"timestamp"] doubleValue];
            
            // Biased toward adds
            if ([elementDictionary[@"timestamp"] doubleValue] >= removeTimestamp) {
                // Timestamp in remove set is earlier than timestamp in add set
                [elementsArray addObject:elementDictionary[@"element"]];
            }
        }
        else {
            // Not in remove set
            [elementsArray addObject:elementDictionary[@"element"]];
        }
    }
    
    return elementsArray;
}

- (void)mergeSet:(LWWElementSet *)mergingSet {
    for (NSDictionary *elementDictionary in mergingSet.addElementsSet) {
        [self addElement:elementDictionary[@"element"]
            forTimestamp:[elementDictionary[@"timestamp"] doubleValue]];
    }
    for (NSDictionary *elementDictionary in mergingSet.removeElementsSet) {
        [self removeElement:elementDictionary[@"element"]
               forTimestamp:[elementDictionary[@"timestamp"] doubleValue]];
    }
}

- (id)copy {
    LWWElementSet *copySet = [[LWWElementSet alloc] init];
    copySet.addElementsSet = [self.addElementsSet mutableCopy];
    copySet.removeElementsSet = [self.removeElementsSet mutableCopy];
    
    return copySet;
}

@end

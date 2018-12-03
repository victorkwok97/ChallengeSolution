//
//  GoodNotesChallengeTests.m
//  GoodNotesChallengeTests
//
//  Created by Victor Kwok on 3/12/2018.
//  Copyright © 2018 VICTOR. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../GoodNotesChallenge/LWWElementSet.h"

@interface GoodNotesChallengeTests : XCTestCase

@end

@implementation GoodNotesChallengeTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCase1 {
    // Test adding elements
    LWWElementSet *lwwElementSet = [[LWWElementSet alloc] init];
    [lwwElementSet addElement:@"123" forTimestamp:[[NSDate date] timeIntervalSince1970]];
    [lwwElementSet addElement:@"1234" forTimestamp:[[NSDate date] timeIntervalSince1970]];
    [lwwElementSet addElement:@"12345" forTimestamp:[[NSDate date] timeIntervalSince1970]];
    
    NSArray *expectedArray = @[@"123", @"1234", @"12345"];
    XCTAssertEqualObjects(lwwElementSet.elements, expectedArray);
}

- (void)testCase2 {
    // Test adding 2 identical elements at different time
    LWWElementSet *lwwElementSet = [[LWWElementSet alloc] init];
    [lwwElementSet addElement:@"123" forTimestamp:[[NSDate date] timeIntervalSince1970] - 1000];
    [lwwElementSet addElement:@"123" forTimestamp:[[NSDate date] timeIntervalSince1970]];
    
    NSArray *expectedArray = @[@"123"];
    XCTAssertEqualObjects(lwwElementSet.elements, expectedArray);
}

- (void)testCase3 {
    // Test removing elements
    // According to CRDT LWWElementSet, since the remove was done later than the add, the element @"1234" should not exist in the end
    LWWElementSet *lwwElementSet = [[LWWElementSet alloc] init];
    [lwwElementSet addElement:@"123" forTimestamp:[[NSDate date] timeIntervalSince1970]];
    [lwwElementSet addElement:@"1234" forTimestamp:[[NSDate date] timeIntervalSince1970]];
    [lwwElementSet addElement:@"12345" forTimestamp:[[NSDate date] timeIntervalSince1970]];
    [lwwElementSet addElement:@"123456" forTimestamp:[[NSDate date] timeIntervalSince1970]];
    [lwwElementSet removeElement:@"1234" forTimestamp:[[NSDate date] timeIntervalSince1970] + 100];
    
    NSArray *expectedArray = @[@"123", @"12345", @"123456"];
    XCTAssertEqualObjects(lwwElementSet.elements, expectedArray);
}

- (void)testCase4 {
    // Test removing element before adding
    LWWElementSet *lwwElementSet = [[LWWElementSet alloc] init];
    [lwwElementSet removeElement:@"1234" forTimestamp:[[NSDate date] timeIntervalSince1970]];
    [lwwElementSet addElement:@"1234" forTimestamp:[[NSDate date] timeIntervalSince1970] + 100];
    
    NSArray *expectedArray = @[@"1234"];
    XCTAssertEqualObjects(lwwElementSet.elements, expectedArray);
}

- (void)testCase5 {
    // Test adding and removing at the same time
    // This implementation of CRDT LWWElementSet is biased towards add (i.e. if the same element was added and removed at the same time, it should be treated as an add)
    LWWElementSet *lwwElementSet = [[LWWElementSet alloc] init];
    double timestamp = [[NSDate date] timeIntervalSince1970];
    [lwwElementSet addElement:@"1234" forTimestamp:timestamp];
    [lwwElementSet removeElement:@"1234" forTimestamp:timestamp];
    
    NSArray *expectedArray = @[@"1234"]; // result should bias towards add
    XCTAssertEqualObjects(lwwElementSet.elements, expectedArray);
}

- (void)testCase6 {
    // Test merging two LWWElementSets together
    double currentTimestamp = [[NSDate date] timeIntervalSince1970];
    
    LWWElementSet *lwwElementSet = [[LWWElementSet alloc] init];
    [lwwElementSet addElement:@"1234" forTimestamp:currentTimestamp];
    [lwwElementSet addElement:@"12345" forTimestamp:currentTimestamp];
    [lwwElementSet addElement:@"123456" forTimestamp:currentTimestamp];
    
    LWWElementSet *replica1 = [lwwElementSet copy];
    [replica1 addElement:@"1234567" forTimestamp:currentTimestamp];
    [replica1 addElement:@"12345678" forTimestamp:currentTimestamp];
    
    LWWElementSet *replica2 = [lwwElementSet copy];
    [replica2 removeElement:@"12345" forTimestamp:currentTimestamp + 100];
    [replica2 removeElement:@"123456" forTimestamp:currentTimestamp + 100];
    
    [replica1 mergeSet:replica2]; // Merging replica2 into replica1
    
    NSArray *expectedArray = @[@"1234", @"1234567", @"12345678"];
    XCTAssertEqualObjects(replica1.elements, expectedArray);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

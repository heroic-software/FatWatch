//
//  EWEnergyEquivalent.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/5/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol EWEnergyEquivalent <NSObject>
@property (nonatomic) int dbID;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *unitName;
@property (nonatomic) float value;
- (NSString *)stringForEnergy:(float)energy;
@end


@interface EWActivityEquivalent : NSObject <EWEnergyEquivalent> {
	int dbID;
	NSString *name;
	float mets;
}
+ (void)setCurrentWeight:(float)weight;
@end


@interface EWFoodEquivalent : NSObject <EWEnergyEquivalent> {
	int dbID;
	NSString *name;
	float energyPerUnit;
	NSString *unitName;
}
@end

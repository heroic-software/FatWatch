//
//  EWEnergyEquivalent.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 1/5/10.
//  Copyright 2010 Benjamin Ragheb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EWEnergyEquivalent : NSObject {
	NSString *name;
	float energyPerUnit;
	NSString *unitName;
}
@property (nonatomic,copy) NSString *name;
@property (nonatomic) float energyPerUnit;
@property (nonatomic,copy) NSString *unitName;
- (void)setEnergyPerMinuteByMets:(float)mets forWeight:(float)weight;
- (NSString *)stringForEnergy:(float)energy;
@end

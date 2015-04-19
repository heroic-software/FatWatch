/*
 * CSVReader.h
 * Created by Benjamin Ragheb on 5/17/08.
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Foundation/Foundation.h>


@interface CSVReader : NSObject
@property (nonatomic,strong) NSNumberFormatter *floatFormatter;
@property (nonatomic,readonly) float progress;
- (id)initWithData:(NSData *)csvData encoding:(NSStringEncoding)encoding;
- (void)reset;
- (BOOL)nextRow;
- (NSString *)readString;
- (float)readFloat;
- (BOOL)readBoolean;
- (NSArray *)readRow;
@end

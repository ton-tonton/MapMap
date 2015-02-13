//
//  DirectionService.h
//  MapMap
//
//  Created by Tawatchai Sunarat on 2/13/15.
//  Copyright (c) 2015 pddk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DirectionService : NSObject

-(void)setDirectionQuery:(NSDictionary *)object withSelector:(SEL)selector withDelegate:(id)delegate;
-(void)retrieveDirections;
-(void)fetchedData:(NSData *)data;

@end

//
//  CarRental.h
//  objective-c_final
//
//  Created by Colby Boucher on 4/18/24.
//

#ifndef CarRental_h
#define CarRental_h

#import <Foundation/Foundation.h>

@interface CarRental : NSObject

- (void)menu;
- (void)rentCar;
- (void)returnCar;
- (void)displayAllInfo;
- (void)clearFile;

@end

#endif /* CarRental_h */

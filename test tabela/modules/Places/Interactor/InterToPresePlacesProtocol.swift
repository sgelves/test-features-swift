//
//  PlacesPlacesInteractorInput.swift
//  test-features-swift
//
//  Created by Sergio on 11/06/2019.
//  Copyright © 2019 sgelves. All rights reserved.
//

import Foundation
import RxSwift

protocol InterToPresePlacesProtocol: class {
    
    var placesBehaviorSubject: PublishSubject<[Local]> { get }
    
}

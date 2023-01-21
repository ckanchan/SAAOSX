//
//  VolumeInformationDetail.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 16/01/2023.
//  Copyright © 2023 Chaitanya Kanchan. All rights reserved.
//

import SwiftUI

struct VolumeInformationDetail: View {
    var volume: Volume?
    
    var body: some View {
        VStack {
            Text(volume?.title ?? "No title selected")
                .font(.title)
            
            Text(volume?.blurb ?? "")
                .font(.caption)
        }
    }
}

struct VolumeInformationDetail_Previews: PreviewProvider {
    static var previews: some View {
        VolumeInformationDetail(volume: Volume.saa01)
    }
}

//
//  VolumeInformationList.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 15/01/2023.
//  Copyright © 2023 Chaitanya Kanchan. All rights reserved.
//

import SwiftUI

struct VolumeInformationList: View {
    @State var selectedVolume: Volume
    
    var body: some View {
        HStack {
            List(Volume.allVolumes, selection: $selectedVolume) {
                //VolumeInformationView(volume: $0)
                Text($0.title)
            }
            VolumeInformationDetail(volume: selectedVolume)
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
    }
}

struct VolumeInformationList_Previews: PreviewProvider {
    static var previews: some View {
        VolumeInformationList(selectedVolume: Volume.saa01)
    }
}

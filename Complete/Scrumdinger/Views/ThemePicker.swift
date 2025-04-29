/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI
import ThemeKit

struct ThemePicker: View {
    @Binding var selection: Theme
    
    var body: some View {
        Picker("Theme", selection: $selection) {
            ForEach(Theme.allCases) { theme in
                ThemeView(theme: theme)
                    .tag(theme)
            }
        }
        .pickerStyle(.navigationLink)
    }
}

#Preview {
    @Previewable @State var theme = Theme.periwinkle
    ThemePicker(selection: $theme)
}

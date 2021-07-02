//
//  RearrangeTiles.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct RearrangeTilesView: View {
    @State private var types: [TileType] = []
    @State private var selectedTypes: Set<String> = .init()

    var body: some View {
        List(selection: $selectedTypes) {
            ForEach(types) { item in
                Text(item.localized).tag(item.id)
            }
            .onMove(perform: move)
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("REARRANGE_SHORT")
        .onChange(of: selectedTypes, perform: { _ in save() })
        .onChange(of: types, perform: { _ in save() })
        .onAppear {
            let selected: [TileType] = UserDefaults.shared?.stringArray(forKey: UserDefaultsKey.tilesInHome)?.compactMap({ TileType(rawValue: $0) }) ?? []
            types = selected + TileType.allCases.filter({ !selected.contains($0) })
            selectedTypes = Set((selected.isEmpty ? TileType.allCases : selected).map({ $0.id }))
        }
    }

    func save() {
        let tiles: [String] = types
            .map({ $0.id })
            .filter({ selectedTypes.contains($0) })
        UserDefaults.shared?.set(tiles.isEmpty ? TileType.allCases.map({ $0.id }) : tiles, forKey: UserDefaultsKey.tilesInHome)
    }

    func move(from source: IndexSet, to destination: Int) {
        types.move(fromOffsets: source, toOffset: destination)
    }
}

struct RearrangeTiles_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RearrangeTilesView()
        }
    }
}

//
//  USJArea.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/16.
//

import SwiftUI
import MapKit

struct USJArea: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let color: Color
    let icon: String
    let attractions: [Attraction]

    static func == (lhs: USJArea, rhs: USJArea) -> Bool {
        lhs.id == rhs.id
    }
}

struct Attraction: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

let usjAreas = [
    USJArea(name: "スーパー・ニンテンドー・ワールド",
            coordinate: CLLocationCoordinate2D(latitude: 34.66849297257609, longitude: 135.43012388453195),
            color: .green,
            icon: "gamecontroller",
            attractions: [
                Attraction(name: "マリオカート ～クッパの挑戦状～", coordinate: CLLocationCoordinate2D(latitude: 34.6666, longitude: 135.4326)),
                Attraction(name: "ヨッシー・アドベンチャー", coordinate: CLLocationCoordinate2D(latitude: 34.6664, longitude: 135.4330))
            ]),
    USJArea(name: "ウィザーディング・ワールド・オブ・ハリー・ポッター",
            coordinate: CLLocationCoordinate2D(latitude: 34.668119664103784,  longitude: 135.4317527094158),
            color: .purple,
            icon: "wand.and.stars",
            attractions: [
                Attraction(name: "ハリー・ポッター・アンド・ザ・フォービドゥン・ジャーニー", coordinate: CLLocationCoordinate2D(latitude: 34.6659, longitude: 135.4312)),
                Attraction(name: "フライト・オブ・ザ・ヒッポグリフ", coordinate: CLLocationCoordinate2D(latitude: 34.6656, longitude: 135.4316))
            ]),
    USJArea(name: "ミニオン・パーク",
            coordinate: CLLocationCoordinate2D(latitude: 34.663409798249305, longitude: 135.4324409493342),
            color: .yellow,
            icon: "face.smiling",
            attractions: [
                Attraction(name: "ミニオン・ハチャメチャ・ライド", coordinate: CLLocationCoordinate2D(latitude: 34.6658, longitude: 135.4332)),
                Attraction(name: "ミニオン・ハチャメチャ・アイス", coordinate: CLLocationCoordinate2D(latitude: 34.6656, longitude: 135.4334))
            ]),
    USJArea(name: "ユニバーサル・ワンダーランド",
            coordinate: CLLocationCoordinate2D(latitude: 34.6670681049386, longitude: 135.4331334951063),
            color: .pink,
            icon: "star",
            attractions: [
                Attraction(name: "フライング・スヌーピー", coordinate: CLLocationCoordinate2D(latitude: 34.6652, longitude: 135.4326)),
                Attraction(name: "エルモのゴーゴー・スケートボード", coordinate: CLLocationCoordinate2D(latitude: 34.6650, longitude: 135.4329)),
                Attraction(name: "モッピーのバルーン・トリップ", coordinate: CLLocationCoordinate2D(latitude: 34.6648, longitude: 135.4327)),
                Attraction(name: "セサミのビッグ・ドライブ", coordinate: CLLocationCoordinate2D(latitude: 34.6651, longitude: 135.4331)),
                Attraction(name: "ビッグバードのビッグトップ・サーカス", coordinate: CLLocationCoordinate2D(latitude: 34.6649, longitude: 135.4325)),
                Attraction(name: "エルモのリトル・ドライブ", coordinate: CLLocationCoordinate2D(latitude: 34.6647, longitude: 135.4330)),
                Attraction(name: "エルモのバブル・バブル", coordinate: CLLocationCoordinate2D(latitude: 34.6646, longitude: 135.4326)),
                Attraction(name: "ハローキティのカップケーキ・ドリーム", coordinate: CLLocationCoordinate2D(latitude: 34.6653, longitude: 135.4332))
            ]),
    USJArea(name: "ハリウッド・エリア",
            coordinate: CLLocationCoordinate2D(latitude: 34.66658566750501, longitude: 135.4339035782933),
            color: .red,
            icon: "film",
            attractions: [
                Attraction(name: "ハリウッド・ドリーム・ザ・ライド", coordinate: CLLocationCoordinate2D(latitude: 34.6656, longitude: 135.4321)),
                Attraction(name: "スペース・ファンタジー・ザ・ライド", coordinate: CLLocationCoordinate2D(latitude: 34.6653, longitude: 135.4325)),
                Attraction(name: "シング・オン・ツアー", coordinate: CLLocationCoordinate2D(latitude: 34.6657, longitude: 135.4326))
            ]),
    USJArea(name: "ニューヨーク・エリア",
            coordinate: CLLocationCoordinate2D(latitude: 34.66413360040401, longitude: 135.43452575833518),
            color: .orange,
            icon: "building.2",
            attractions: [
                Attraction(name: "アメージング・アドベンチャー・オブ・スパイダーマン・ザ・ライド 4K3D", coordinate: CLLocationCoordinate2D(latitude: 34.6661, longitude: 135.4329))
            ]),
    USJArea(name: "ジュラシック・パーク",
            coordinate: CLLocationCoordinate2D(latitude: 34.66491203745761, longitude: 135.43062111881088),
            color: .green,
            icon: "leaf",
            attractions: [
                Attraction(name: "ジュラシック・パーク・ザ・ライド", coordinate: CLLocationCoordinate2D(latitude: 34.6653, longitude: 135.4314)),
                Attraction(name: "ザ・フライング・ダイナソー", coordinate: CLLocationCoordinate2D(latitude: 34.6657, longitude: 135.4326))
            ]),
    USJArea(name: "アミティ・ビレッジ",
            coordinate: CLLocationCoordinate2D(latitude: 34.66596559228669, longitude: 135.43193968439826),
            color: .blue,
            icon: "water.waves",
            attractions: [
                Attraction(name: "ジョーズ", coordinate: CLLocationCoordinate2D(latitude: 34.6649, longitude: 135.4319))
            ]),
    USJArea(name: "ウォーターワールド",
            coordinate: CLLocationCoordinate2D(latitude: 34.66698465126322, longitude: 135.42983819805195),
            color: .cyan,
            icon: "drop",
            attractions: [
                Attraction(name: "ウォーターワールド", coordinate: CLLocationCoordinate2D(latitude: 34.6646, longitude: 135.4329))
            ])
]


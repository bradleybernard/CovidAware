//
//  USAState.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/26/20.
//

import SwiftUI

enum USAState: String, CaseIterable, Identifiable, Equatable, Codable {
    case alaska             = "AK"
    case alabama            = "AL"
    case arkansas           = "AR"
    case americanSamoa      = "AS"
    case arizona            = "AZ"
    case california         = "CA"
    case colorado           = "CO"
    case connecticut        = "CT"
    case districtOfColumbia = "DC"
    case delaware           = "DE"
    case florida            = "FL"
    case georgia            = "GA"
    case guam               = "GU"
    case hawaii             = "HI"
    case iowa               = "IA"
    case idaho              = "ID"
    case illinois           = "IL"
    case indiana            = "IN"
    case kansas             = "KS"
    case kentucky           = "KY"
    case louisiana          = "LA"
    case massachusetts      = "MA"
    case maryland           = "MD"
    case maine              = "ME"
    case michigan           = "MI"
    case minnesota          = "MN"
    case missouri           = "MO"
    case mississippi        = "MS"
    case montana            = "MT"
    case northCarolina      = "NC"
    case northDakota        = "ND"
    case nebraska           = "NE"
    case newHampshire       = "NH"
    case newJersey          = "NJ"
    case newMexico          = "NM"
    case nevada             = "NV"
    case newYork            = "NY"
    case ohio               = "OH"
    case oklahoma           = "OK"
    case oregon             = "OR"
    case pennsylvania       = "PA"
    case puertoRico         = "PR"
    case rhodeIsland        = "RI"
    case southCarolina      = "SC"
    case southDakota        = "SD"
    case tennessee          = "TN"
    case texas              = "TX"
    case utah               = "UT"
    case virginia           = "VA"
    case virginIslands      = "VI"
    case vermont            = "VT"
    case washington         = "WA"
    case wisconsin          = "WI"
    case westVirginia       = "WV"
    case wyoming            = "WY"

    var name: String {
        switch self {
            case .alaska:
                return "Alaska"
            case .alabama:
                return "Alabama"
            case .arkansas:
                return "Arkansas"
            case .americanSamoa:
                return "American Samoa"
            case .arizona:
                return "Arizona"
            case .california:
                return "California"
            case .colorado:
                return "Colorado"
            case .connecticut:
                return "Connecticut"
            case .districtOfColumbia:
                return "District of Columbia"
            case .delaware:
                return "Delaware"
            case .florida:
                return "Florida"
            case .georgia:
                return "Georgia"
            case .guam:
                return "Guam"
            case .hawaii:
                return "Hawaii"
            case .iowa:
                return "Iowa"
            case .idaho:
                return "Idaho"
            case .illinois:
                return "Illinois"
            case .indiana:
                return "Indiana"
            case .kansas:
                return "Kansas"
            case .kentucky:
                return "Kentucky"
            case .louisiana:
                return "Louisiana"
            case .massachusetts:
                return "Massachusetts"
            case .maryland:
                return "Maryland"
            case .maine:
                return "Maine"
            case .michigan:
                return "Michigan"
            case .minnesota:
                return "Minnesota"
            case .missouri:
                return "Missouri"
            case .mississippi:
                return "Mississippi"
            case .montana:
                return "Montana"
            case .northCarolina:
                return "North Carolina"
            case .northDakota:
                return "North Dakoa"
            case .nebraska:
                return "Nebraska"
            case .newHampshire:
                return "New Hampshire"
            case .newJersey:
                return "New Jersey"
            case .newMexico:
                return "New Mexico"
            case .nevada:
                return "Nevada"
            case .newYork:
                return "New York"
            case .ohio:
                return "Ohio"
            case .oklahoma:
                return "Oklahoma"
            case .oregon:
                return "Oregon"
            case .pennsylvania:
                return "Pennsylvania"
            case .puertoRico:
                return "Puerto Rico"
            case .rhodeIsland:
                return "Rhode Island"
            case .southCarolina:
                return "South Carolina"
            case .southDakota:
                return "South Dakota"
            case .tennessee:
                return "Tennessee"
            case .texas:
                return "Texas"
            case .utah:
                return "Utah"
            case .virginia:
                return "Virginia"
            case .virginIslands:
                return "Virgin Islands"
            case .vermont:
                return "Vermont"
            case .washington:
                return "Washington"
            case .wisconsin:
                return "Wisconsin"
            case .westVirginia:
                return "West Virginia"
            case .wyoming:
                return "Wyoming"
        }
    }

    var color: Color {
        Color(uiColor)
    }

    var uiColor: UIColor {
        guard let position = Self.allCases.firstIndex(of: self) else {
            fatalError("Could not find position of state in allCases")
        }

        let hueMax: CGFloat = 1.0
        let huePerIndex = hueMax / CGFloat(Self.allCases.count)
        let hue = huePerIndex * CGFloat(position)

        return UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1)
    }

    var id: String {
        rawValue
    }
}

#if DEBUG
extension USAState {
    static let mock: Self = .california
}
#endif

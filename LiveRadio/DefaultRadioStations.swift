import Foundation

struct DefaultRadioStations {
    static let categories: [RadioCategory] = [
        // NEWS - News & Current Affairs
        RadioCategory(
            name: "News",
            shortName: "NEWS",
            icon: "newspaper",
            stations: [
                RadioStation(
                    name: "BBC World Service",
                    description: "International news and current affairs",
                    streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_world_service",
                    websiteURL: "https://www.bbc.co.uk/worldserviceradio",
                    location: "London, UK"
                ),
                RadioStation(
                    name: "NPR Program Stream",
                    description: "National Public Radio",
                    streamURL: "https://npr-ice.streamguys1.com/live.mp3",
                    websiteURL: "https://www.npr.org",
                    location: "Washington, DC"
                ),
                RadioStation(
                    name: "BBC Radio 4",
                    description: "Speech-based news, drama & culture",
                    streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_fourfm",
                    websiteURL: "https://www.bbc.co.uk/radio4",
                    location: "London, UK"
                ),
                RadioStation(
                    name: "WNYC FM",
                    description: "New York Public Radio",
                    streamURL: "https://fm939.wnyc.org/wnycfm",
                    websiteURL: "https://www.wnyc.org",
                    location: "New York, NY"
                ),
                RadioStation(
                    name: "KQED Public Radio",
                    description: "San Francisco news & talk",
                    streamURL: "https://streams.kqed.org/kqedradio",
                    websiteURL: "https://www.kqed.org",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "WBUR Boston",
                    description: "Boston's NPR news station",
                    streamURL: "https://stream.wbur.org/wbur.mp3",
                    websiteURL: "https://www.wbur.org",
                    location: "Boston, MA"
                ),
                RadioStation(
                    name: "KCRW News",
                    description: "Santa Monica public radio",
                    streamURL: "https://kcrw.streamguys1.com/kcrw_192k_mp3_on_air",
                    websiteURL: "https://www.kcrw.com",
                    location: "Santa Monica, CA"
                ),
                RadioStation(
                    name: "WAMU Washington",
                    description: "DC's NPR station",
                    streamURL: "https://stream.wamu.org/wamu-1.mp3",
                    websiteURL: "https://www.wamu.org",
                    location: "Washington, DC"
                ),
            ]
        ),

        // JAZZ - Jazz Music
        RadioCategory(
            name: "Jazz",
            shortName: "JAZZ",
            icon: "music.quarternote.3",
            stations: [
                RadioStation(
                    name: "WBGO Jazz 88.3",
                    description: "America's premier jazz station",
                    streamURL: "https://wbgo.streamguys1.com/wbgo128",
                    websiteURL: "https://www.wbgo.org",
                    location: "Newark, NJ"
                ),
                RadioStation(
                    name: "Jazz24",
                    description: "24/7 Jazz from KNKX",
                    streamURL: "https://live.wostreaming.net/direct/ppm-jazz24aac-ibc1",
                    websiteURL: "https://www.jazz24.org",
                    location: "Seattle, WA"
                ),
                RadioStation(
                    name: "KCSM Jazz 91.1",
                    description: "San Francisco Bay Area jazz",
                    streamURL: "https://ice7.securenetsystems.net/KCSM2",
                    websiteURL: "https://www.kcsm.org",
                    location: "San Mateo, CA"
                ),
                RadioStation(
                    name: "WWOZ New Orleans",
                    description: "New Orleans jazz & heritage",
                    streamURL: "https://wwoz-sc.streamguys1.com/wwoz-hi.mp3",
                    websiteURL: "https://www.wwoz.org",
                    location: "New Orleans, LA"
                ),
                RadioStation(
                    name: "TSF Jazz Paris",
                    description: "French jazz radio",
                    streamURL: "https://tsfjazz.ice.infomaniak.ch/tsfjazz-high.mp3",
                    websiteURL: "https://www.tsfjazz.com",
                    location: "Paris, France"
                ),
                RadioStation(
                    name: "SomaFM Jazz Groove",
                    description: "Organic house & jazz",
                    streamURL: "https://ice4.somafm.com/jazzgroove-128-mp3",
                    websiteURL: "https://somafm.com/jazzgroove",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "Radio Swiss Jazz",
                    description: "Swiss jazz radio",
                    streamURL: "https://stream.srg-ssr.ch/m/rsj/mp3_128",
                    websiteURL: "https://www.radioswissjazz.ch",
                    location: "Zurich, Switzerland"
                ),
                RadioStation(
                    name: "WDCB Jazz",
                    description: "Chicago jazz",
                    streamURL: "https://wdcb-ice.streamguys1.com/wdcb128",
                    websiteURL: "https://www.wdcb.org",
                    location: "Chicago, IL"
                ),
            ]
        ),

        // CLAS - Classical Music
        RadioCategory(
            name: "Classical",
            shortName: "CLAS",
            icon: "music.note.list",
            stations: [
                RadioStation(
                    name: "WQXR Classical",
                    description: "New York's classical music station",
                    streamURL: "https://stream.wqxr.org/wqxr",
                    websiteURL: "https://www.wqxr.org",
                    location: "New York, NY"
                ),
                RadioStation(
                    name: "BBC Radio 3",
                    description: "Classical, jazz, world and arts",
                    streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_three",
                    websiteURL: "https://www.bbc.co.uk/radio3",
                    location: "London, UK"
                ),
                RadioStation(
                    name: "KUSC Classical",
                    description: "Southern California classical",
                    streamURL: "https://kusc.streamguys1.com/kusc-128k.mp3",
                    websiteURL: "https://www.kusc.org",
                    location: "Los Angeles, CA"
                ),
                RadioStation(
                    name: "Radio Swiss Classic",
                    description: "Swiss classical radio",
                    streamURL: "https://stream.srg-ssr.ch/m/rsc_de/mp3_128",
                    websiteURL: "https://www.radioswissclassic.ch",
                    location: "Zurich, Switzerland"
                ),
                RadioStation(
                    name: "WFMT Chicago",
                    description: "Chicago classical & fine arts",
                    streamURL: "https://wfmt.streamguys1.com/main-mp3",
                    websiteURL: "https://www.wfmt.com",
                    location: "Chicago, IL"
                ),
                RadioStation(
                    name: "WCPE The Classical Station",
                    description: "Great classical music 24/7",
                    streamURL: "https://audio-mp3.ibiblio.org/wcpe.mp3",
                    websiteURL: "https://www.theclassicalstation.org",
                    location: "Wake Forest, NC"
                ),
                RadioStation(
                    name: "Classical KING FM",
                    description: "Seattle's classical station",
                    streamURL: "https://classicalking.streamguys1.com/king-fm-aac-128k",
                    websiteURL: "https://www.king.org",
                    location: "Seattle, WA"
                ),
                RadioStation(
                    name: "WCRB Boston",
                    description: "Boston's classical station",
                    streamURL: "https://stream.wgbh.org/wcrb",
                    websiteURL: "https://www.classicalwcrb.org",
                    location: "Boston, MA"
                ),
            ]
        ),

        // ELEC - Electronic & Dance
        RadioCategory(
            name: "Electronic",
            shortName: "ELEC",
            icon: "waveform",
            stations: [
                RadioStation(
                    name: "SomaFM Groove Salad",
                    description: "Ambient & downtempo beats",
                    streamURL: "https://ice4.somafm.com/groovesalad-256-mp3",
                    websiteURL: "https://somafm.com/groovesalad",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM DEF CON",
                    description: "Music for hackers",
                    streamURL: "https://ice4.somafm.com/defcon-256-mp3",
                    websiteURL: "https://somafm.com/defcon",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM Beat Blender",
                    description: "Deep house & downtempo",
                    streamURL: "https://ice4.somafm.com/beatblender-128-mp3",
                    websiteURL: "https://somafm.com/beatblender",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM Cliqhop IDM",
                    description: "Intelligent dance music",
                    streamURL: "https://ice4.somafm.com/cliqhop-256-mp3",
                    websiteURL: "https://somafm.com/cliqhop",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM Secret Agent",
                    description: "Spy music & lounge",
                    streamURL: "https://ice4.somafm.com/secretagent-256-mp3",
                    websiteURL: "https://somafm.com/secretagent",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM The Trip",
                    description: "Progressive trance & house",
                    streamURL: "https://ice4.somafm.com/thetrip-128-mp3",
                    websiteURL: "https://somafm.com/thetrip",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM Fluid",
                    description: "Vocal electronic music",
                    streamURL: "https://ice4.somafm.com/fluid-128-mp3",
                    websiteURL: "https://somafm.com/fluid",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM Digitalis",
                    description: "Electronica & synth",
                    streamURL: "https://ice4.somafm.com/digitalis-128-mp3",
                    websiteURL: "https://somafm.com/digitalis",
                    location: "San Francisco, CA"
                ),
            ]
        ),

        // CHILL - Lo-fi & Ambient
        RadioCategory(
            name: "Chill",
            shortName: "CHILL",
            icon: "leaf",
            stations: [
                RadioStation(
                    name: "SomaFM Drone Zone",
                    description: "Atmospheric textures with minimal beats",
                    streamURL: "https://ice4.somafm.com/dronezone-256-mp3",
                    websiteURL: "https://somafm.com/dronezone",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM Space Station",
                    description: "Spaced out ambient & electronic",
                    streamURL: "https://ice4.somafm.com/spacestation-128-mp3",
                    websiteURL: "https://somafm.com/spacestation",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM Deep Space One",
                    description: "Deep ambient electronic",
                    streamURL: "https://ice4.somafm.com/deepspaceone-128-mp3",
                    websiteURL: "https://somafm.com/deepspaceone",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM Groove Salad Classic",
                    description: "Original downtempo favorites",
                    streamURL: "https://ice4.somafm.com/gsclassic-128-mp3",
                    websiteURL: "https://somafm.com/gsclassic",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM Illinois Street Lounge",
                    description: "Classic bachelor pad & exotica",
                    streamURL: "https://ice4.somafm.com/illstreet-128-mp3",
                    websiteURL: "https://somafm.com/illstreet",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "Radio Paradise Mellow",
                    description: "Mellow mix",
                    streamURL: "https://stream.radioparadise.com/mellow-320",
                    websiteURL: "https://radioparadise.com/mellow",
                    location: "Paradise, CA"
                ),
                RadioStation(
                    name: "SomaFM Lush",
                    description: "Sensuous vocals & mellow beats",
                    streamURL: "https://ice4.somafm.com/lush-128-mp3",
                    websiteURL: "https://somafm.com/lush",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM n5MD Radio",
                    description: "Ambient & post-rock",
                    streamURL: "https://ice4.somafm.com/n5md-128-mp3",
                    websiteURL: "https://somafm.com/n5md",
                    location: "San Francisco, CA"
                ),
            ]
        ),

        // ROCK - Rock Music
        RadioCategory(
            name: "Rock",
            shortName: "ROCK",
            icon: "guitars",
            stations: [
                RadioStation(
                    name: "KEXP 90.3",
                    description: "Seattle's eclectic music station",
                    streamURL: "https://kexp-mp3-128.streamguys1.com/kexp128.mp3",
                    websiteURL: "https://www.kexp.org",
                    location: "Seattle, WA"
                ),
                RadioStation(
                    name: "Radio Paradise Rock",
                    description: "Eclectic rock mix",
                    streamURL: "https://stream.radioparadise.com/rock-320",
                    websiteURL: "https://radioparadise.com",
                    location: "Paradise, CA"
                ),
                RadioStation(
                    name: "SomaFM Underground 80s",
                    description: "Deep cuts from the 80s",
                    streamURL: "https://ice4.somafm.com/u80s-256-mp3",
                    websiteURL: "https://somafm.com/u80s",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "BBC Radio 6 Music",
                    description: "Alternative & indie music",
                    streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_6music",
                    websiteURL: "https://www.bbc.co.uk/6music",
                    location: "London, UK"
                ),
                RadioStation(
                    name: "SomaFM Indie Pop Rocks",
                    description: "Indie pop & rock",
                    streamURL: "https://ice4.somafm.com/indiepop-128-mp3",
                    websiteURL: "https://somafm.com/indiepop",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "SomaFM Metal Detector",
                    description: "Heavy metal",
                    streamURL: "https://ice4.somafm.com/metal-128-mp3",
                    websiteURL: "https://somafm.com/metal",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "WXPN Philadelphia",
                    description: "Adult album alternative",
                    streamURL: "https://wxpn.xpn.org/xpnmp3hi",
                    websiteURL: "https://www.xpn.org",
                    location: "Philadelphia, PA"
                ),
                RadioStation(
                    name: "Radio Paradise Main",
                    description: "Eclectic DJ-curated mix",
                    streamURL: "https://stream.radioparadise.com/aac-320",
                    websiteURL: "https://radioparadise.com",
                    location: "Paradise, CA"
                ),
            ]
        ),

        // WRLD - World Music
        RadioCategory(
            name: "World",
            shortName: "WRLD",
            icon: "globe",
            stations: [
                RadioStation(
                    name: "FIP Radio",
                    description: "Eclectic French radio",
                    streamURL: "https://icecast.radiofrance.fr/fip-midfi.mp3",
                    websiteURL: "https://www.fip.fr",
                    location: "Paris, France"
                ),
                RadioStation(
                    name: "FIP World",
                    description: "World music from Radio France",
                    streamURL: "https://icecast.radiofrance.fr/fipworld-midfi.mp3",
                    websiteURL: "https://www.fip.fr",
                    location: "Paris, France"
                ),
                RadioStation(
                    name: "Radio Paradise World",
                    description: "Global sounds & world beat",
                    streamURL: "https://stream.radioparadise.com/world-etc-320",
                    websiteURL: "https://radioparadise.com",
                    location: "Paradise, CA"
                ),
                RadioStation(
                    name: "NTS Radio 1",
                    description: "Underground music from London",
                    streamURL: "https://stream-relay-geo.ntslive.net/stream",
                    websiteURL: "https://www.nts.live",
                    location: "London, UK"
                ),
                RadioStation(
                    name: "FIP Reggae",
                    description: "Reggae from Radio France",
                    streamURL: "https://icecast.radiofrance.fr/fipreggae-midfi.mp3",
                    websiteURL: "https://www.fip.fr",
                    location: "Paris, France"
                ),
                RadioStation(
                    name: "SomaFM Suburbs of Goa",
                    description: "Indian world beat",
                    streamURL: "https://ice4.somafm.com/suburbsofgoa-128-mp3",
                    websiteURL: "https://somafm.com/suburbsofgoa",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "FIP Jazz",
                    description: "Jazz from Radio France",
                    streamURL: "https://icecast.radiofrance.fr/fipjazz-midfi.mp3",
                    websiteURL: "https://www.fip.fr",
                    location: "Paris, France"
                ),
                RadioStation(
                    name: "FIP Electro",
                    description: "Electronic from Radio France",
                    streamURL: "https://icecast.radiofrance.fr/fipelectro-midfi.mp3",
                    websiteURL: "https://www.fip.fr",
                    location: "Paris, France"
                ),
            ]
        ),

        // TALK - Talk Radio
        RadioCategory(
            name: "Talk",
            shortName: "TALK",
            icon: "mic",
            stations: [
                RadioStation(
                    name: "BBC Radio 4",
                    description: "Speech-based news & culture",
                    streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_fourfm",
                    websiteURL: "https://www.bbc.co.uk/radio4",
                    location: "London, UK"
                ),
                RadioStation(
                    name: "BBC Radio 4 Extra",
                    description: "Comedy, drama & entertainment",
                    streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_four_extra",
                    websiteURL: "https://www.bbc.co.uk/radio4extra",
                    location: "London, UK"
                ),
                RadioStation(
                    name: "KQED Forum",
                    description: "San Francisco public radio",
                    streamURL: "https://streams.kqed.org/kqedradio",
                    websiteURL: "https://www.kqed.org",
                    location: "San Francisco, CA"
                ),
                RadioStation(
                    name: "WNYC AM",
                    description: "New York talk & news",
                    streamURL: "https://am820.wnyc.org/wnycam",
                    websiteURL: "https://www.wnyc.org",
                    location: "New York, NY"
                ),
                RadioStation(
                    name: "NPR Program Stream",
                    description: "NPR talk & news",
                    streamURL: "https://npr-ice.streamguys1.com/live.mp3",
                    websiteURL: "https://www.npr.org",
                    location: "Washington, DC"
                ),
                RadioStation(
                    name: "KPCC Los Angeles",
                    description: "Southern California public radio",
                    streamURL: "https://live.scpr.org/kpcclive",
                    websiteURL: "https://www.kpcc.org",
                    location: "Los Angeles, CA"
                ),
                RadioStation(
                    name: "WBEZ Chicago",
                    description: "Chicago public radio",
                    streamURL: "https://stream.wbez.org/wbez128.mp3",
                    websiteURL: "https://www.wbez.org",
                    location: "Chicago, IL"
                ),
                RadioStation(
                    name: "WHYY Philadelphia",
                    description: "Philadelphia public radio",
                    streamURL: "https://whyy-hd.streamguys1.com/whyy-hd-mp3",
                    websiteURL: "https://www.whyy.org",
                    location: "Philadelphia, PA"
                ),
            ]
        ),
    ]
}

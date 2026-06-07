import Foundation

// MARK: - Interest

enum Interest: String, Codable, CaseIterable, Hashable {
    case movies      = "영화·드라마"
    case music       = "음악"
    case sports      = "스포츠"
    case gaming      = "게임"
    case reading     = "독서·오디오북"
    case news        = "뉴스·미디어"
    case fitness     = "운동·피트니스"
    case education   = "교육·공부"
    case productivity = "생산성·업무"
    case webtoon     = "웹툰·만화"

    var sfSymbol: String {
        switch self {
        case .movies:       return "film.fill"
        case .music:        return "music.note"
        case .sports:       return "sportscourt.fill"
        case .gaming:       return "gamecontroller.fill"
        case .reading:      return "book.fill"
        case .news:         return "newspaper.fill"
        case .fitness:      return "figure.run"
        case .education:    return "graduationcap.fill"
        case .productivity: return "briefcase.fill"
        case .webtoon:      return "doc.richtext.fill"
        }
    }
}

// MARK: - ServiceInfo

struct ServiceInfo: Identifiable {
    let id: String
    let name: String
    let category: SubscriptionCategory
    let interests: [Interest]
    let monthlyPriceKRW: Int
    let description: String
    let keywords: [String]
    let sfSymbol: String
    let colorHex: String
}

// MARK: - ServiceDatabase

struct ServiceDatabase {
    static let all: [ServiceInfo] = [

        // ── 영화·드라마 ──────────────────────────────────────────
        .init(id: "netflix", name: "Netflix", category: .entertainment,
              interests: [.movies],
              monthlyPriceKRW: 17_000,
              description: "넷플릭스 오리지널과 글로벌 영화·시리즈",
              keywords: ["netflix", "넷플릭스"],
              sfSymbol: "tv.fill", colorHex: "E50914"),

        .init(id: "disney_plus", name: "Disney+", category: .entertainment,
              interests: [.movies],
              monthlyPriceKRW: 9_900,
              description: "디즈니·마블·스타워즈·픽사 콘텐츠",
              keywords: ["disney", "디즈니"],
              sfSymbol: "sparkles.tv.fill", colorHex: "0063E5"),

        .init(id: "watcha", name: "Watcha", category: .entertainment,
              interests: [.movies],
              monthlyPriceKRW: 9_900,
              description: "한국 영화·드라마 강점, 취향 기반 추천",
              keywords: ["watcha", "왓챠"],
              sfSymbol: "play.rectangle.fill", colorHex: "FF0558"),

        .init(id: "tving", name: "Tving", category: .entertainment,
              interests: [.movies, .sports],
              monthlyPriceKRW: 7_900,
              description: "CJ ENM 오리지널 + 스포츠 중계",
              keywords: ["tving", "티빙"],
              sfSymbol: "play.tv.fill", colorHex: "FF153C"),

        .init(id: "coupang_play", name: "Coupang Play", category: .entertainment,
              interests: [.movies, .sports],
              monthlyPriceKRW: 7_890,
              description: "영화·스포츠·예능, 로켓배송 포함",
              keywords: ["coupang play", "쿠팡플레이", "쿠팡 플레이"],
              sfSymbol: "tv.and.mediabox", colorHex: "FF6600"),

        .init(id: "wavve", name: "Wavve", category: .entertainment,
              interests: [.movies],
              monthlyPriceKRW: 7_900,
              description: "지상파 3사 KBS·MBC·SBS 실시간 및 VOD",
              keywords: ["wavve", "웨이브"],
              sfSymbol: "wave.3.right.circle.fill", colorHex: "0072F0"),

        .init(id: "apple_tv_plus", name: "Apple TV+", category: .entertainment,
              interests: [.movies],
              monthlyPriceKRW: 9_900,
              description: "애플 오리지널 고퀄리티 시리즈",
              keywords: ["apple tv", "애플 tv", "애플tv"],
              sfSymbol: "appletv.fill", colorHex: "555555"),

        .init(id: "youtube_premium", name: "YouTube Premium", category: .entertainment,
              interests: [.movies, .music],
              monthlyPriceKRW: 14_900,
              description: "광고 없는 유튜브 + YouTube Music 포함",
              keywords: ["youtube premium", "유튜브 프리미엄", "유튜브프리미엄"],
              sfSymbol: "play.circle.fill", colorHex: "FF0000"),

        // ── 음악 ─────────────────────────────────────────────────
        .init(id: "melon", name: "Melon", category: .music,
              interests: [.music],
              monthlyPriceKRW: 10_900,
              description: "국내 1위 음원 스트리밍 서비스",
              keywords: ["melon", "멜론"],
              sfSymbol: "music.note.list", colorHex: "00CD3C"),

        .init(id: "genie", name: "Genie Music", category: .music,
              interests: [.music],
              monthlyPriceKRW: 8_900,
              description: "KT 계열 음원 서비스",
              keywords: ["genie", "지니", "지니뮤직"],
              sfSymbol: "music.note", colorHex: "0055FF"),

        .init(id: "apple_music", name: "Apple Music", category: .music,
              interests: [.music],
              monthlyPriceKRW: 11_000,
              description: "공간 음향 지원, Apple 기기 최적화",
              keywords: ["apple music", "애플뮤직", "애플 뮤직"],
              sfSymbol: "music.quarternote.3", colorHex: "FC3C44"),

        .init(id: "spotify", name: "Spotify", category: .music,
              interests: [.music],
              monthlyPriceKRW: 10_900,
              description: "글로벌 최대 음원 + 팟캐스트 플랫폼",
              keywords: ["spotify", "스포티파이"],
              sfSymbol: "headphones", colorHex: "1DB954"),

        .init(id: "youtube_music", name: "YouTube Music", category: .music,
              interests: [.music],
              monthlyPriceKRW: 10_900,
              description: "유튜브 기반 음원·뮤직비디오",
              keywords: ["youtube music", "유튜브뮤직", "유튜브 뮤직"],
              sfSymbol: "music.mic", colorHex: "FF0000"),

        .init(id: "flo", name: "FLO", category: .music,
              interests: [.music],
              monthlyPriceKRW: 10_900,
              description: "SKT 기반 AI 취향 분석 음원",
              keywords: ["flo", "플로"],
              sfSymbol: "waveform.circle.fill", colorHex: "7B5EEA"),

        // ── 게임 ─────────────────────────────────────────────────
        .init(id: "ps_plus", name: "PlayStation Plus", category: .gaming,
              interests: [.gaming],
              monthlyPriceKRW: 8_900,
              description: "PS4·PS5 무료 게임 + 온라인 멀티플레이",
              keywords: ["playstation", "ps plus", "플레이스테이션"],
              sfSymbol: "gamecontroller.fill", colorHex: "003791"),

        .init(id: "xbox_gamepass", name: "Xbox Game Pass", category: .gaming,
              interests: [.gaming],
              monthlyPriceKRW: 9_900,
              description: "100개 이상 게임 무제한 플레이",
              keywords: ["xbox", "game pass", "gamepass", "게임패스"],
              sfSymbol: "gamecontroller", colorHex: "107C10"),

        .init(id: "nintendo_online", name: "Nintendo Switch Online", category: .gaming,
              interests: [.gaming],
              monthlyPriceKRW: 4_500,
              description: "스위치 온라인 + 레트로 게임 라이브러리",
              keywords: ["nintendo", "닌텐도", "스위치 온라인"],
              sfSymbol: "arcade.stick.console", colorHex: "E60012"),

        .init(id: "apple_arcade", name: "Apple Arcade", category: .gaming,
              interests: [.gaming],
              monthlyPriceKRW: 7_500,
              description: "광고·결제 없는 고품질 모바일 게임",
              keywords: ["apple arcade", "애플 아케이드", "애플아케이드"],
              sfSymbol: "arcade.stick", colorHex: "0071E3"),

        // ── 독서·오디오북 ─────────────────────────────────────────
        .init(id: "millie", name: "밀리의 서재", category: .education,
              interests: [.reading],
              monthlyPriceKRW: 9_900,
              description: "국내 최대 전자책·오디오북 라이브러리",
              keywords: ["밀리", "millie", "밀리의 서재", "밀리의서재"],
              sfSymbol: "books.vertical.fill", colorHex: "FF6F00"),

        .init(id: "ridi", name: "리디 셀렉트", category: .education,
              interests: [.reading, .webtoon],
              monthlyPriceKRW: 6_500,
              description: "전자책·웹툰 구독형 서비스",
              keywords: ["ridi", "리디", "리디셀렉트", "리디 셀렉트"],
              sfSymbol: "doc.text.fill", colorHex: "1362F5"),

        .init(id: "audible", name: "Audible", category: .education,
              interests: [.reading],
              monthlyPriceKRW: 14_900,
              description: "아마존 오디오북, 영어 원서 포함",
              keywords: ["audible", "오더블"],
              sfSymbol: "headphones.circle.fill", colorHex: "F3A847"),

        // ── 스포츠 ───────────────────────────────────────────────
        .init(id: "spotv", name: "SPOTV NOW", category: .entertainment,
              interests: [.sports],
              monthlyPriceKRW: 7_500,
              description: "해외축구·NBA 등 프리미엄 스포츠 중계",
              keywords: ["spotv", "스포티비", "spotv now"],
              sfSymbol: "sportscourt.fill", colorHex: "00A651"),

        // ── 운동·피트니스 ─────────────────────────────────────────
        .init(id: "myfitnesspal", name: "MyFitnessPal", category: .health,
              interests: [.fitness],
              monthlyPriceKRW: 8_900,
              description: "칼로리 추적 + 운동 기록 관리",
              keywords: ["myfitnesspal", "마이피트니스팔"],
              sfSymbol: "heart.text.square.fill", colorHex: "00B5AD"),

        .init(id: "nike_training", name: "Nike Training Club", category: .health,
              interests: [.fitness],
              monthlyPriceKRW: 0,
              description: "무료 홈트레이닝 앱 (프리미엄 콘텐츠 유료)",
              keywords: ["nike", "나이키", "나이키 트레이닝"],
              sfSymbol: "figure.run.circle.fill", colorHex: "111111"),

        // ── 교육·공부 ─────────────────────────────────────────────
        .init(id: "class101", name: "Class101+", category: .education,
              interests: [.education],
              monthlyPriceKRW: 11_900,
              description: "그림·코딩·요리 등 실용 클래스",
              keywords: ["class101", "클래스101", "클래스 101"],
              sfSymbol: "graduationcap.fill", colorHex: "FF4500"),

        .init(id: "duolingo", name: "Duolingo Plus", category: .education,
              interests: [.education],
              monthlyPriceKRW: 9_500,
              description: "게임형 외국어 학습, 33개 언어 지원",
              keywords: ["duolingo", "듀오링고"],
              sfSymbol: "globe.americas.fill", colorHex: "58CC02"),

        .init(id: "coursera", name: "Coursera Plus", category: .education,
              interests: [.education],
              monthlyPriceKRW: 65_000,
              description: "세계 유명 대학 강의 무제한 수강",
              keywords: ["coursera", "코세라"],
              sfSymbol: "building.columns.fill", colorHex: "0056D2"),

        // ── 생산성·업무 ───────────────────────────────────────────
        .init(id: "microsoft365", name: "Microsoft 365", category: .productivity,
              interests: [.productivity],
              monthlyPriceKRW: 9_900,
              description: "Word·Excel·PowerPoint + 1TB 클라우드",
              keywords: ["microsoft", "마이크로소프트", "office", "오피스", "microsoft 365"],
              sfSymbol: "doc.fill", colorHex: "D83B01"),

        .init(id: "notion", name: "Notion Plus", category: .productivity,
              interests: [.productivity],
              monthlyPriceKRW: 16_000,
              description: "노트·프로젝트·DB 올인원 협업 도구",
              keywords: ["notion", "노션"],
              sfSymbol: "square.grid.3x3.fill", colorHex: "333333"),

        .init(id: "adobe_cc", name: "Adobe Creative Cloud", category: .software,
              interests: [.productivity],
              monthlyPriceKRW: 35_000,
              description: "포토샵·프리미어 등 크리에이티브 툴 모음",
              keywords: ["adobe", "어도비", "creative cloud", "크리에이티브 클라우드"],
              sfSymbol: "paintbrush.fill", colorHex: "FF0000"),

        // ── 웹툰·만화 ─────────────────────────────────────────────
        .init(id: "naver_webtoon", name: "네이버 웹툰 쿠키", category: .entertainment,
              interests: [.webtoon],
              monthlyPriceKRW: 9_900,
              description: "국내외 인기 웹툰 쿠키 충전",
              keywords: ["네이버웹툰", "naver webtoon", "네이버 웹툰"],
              sfSymbol: "doc.richtext.fill", colorHex: "03C75A"),

        .init(id: "kakao_webtoon", name: "카카오 웹툰", category: .entertainment,
              interests: [.webtoon],
              monthlyPriceKRW: 9_900,
              description: "카카오 웹툰 코인 충전 및 프리미엄",
              keywords: ["카카오웹툰", "kakao webtoon", "카카오 웹툰"],
              sfSymbol: "text.bubble.fill", colorHex: "FAE100"),

        // ── 뉴스·멤버십 ───────────────────────────────────────────
        .init(id: "naver_plus", name: "네이버 플러스 멤버십", category: .news,
              interests: [.news, .movies, .music],
              monthlyPriceKRW: 4_900,
              description: "네이버 포인트 + 웹툰·음악·VOD 혜택",
              keywords: ["네이버 플러스", "naver plus", "네이버플러스"],
              sfSymbol: "newspaper.fill", colorHex: "03C75A"),
    ]
}

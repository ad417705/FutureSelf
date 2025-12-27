# FutureSelf

> Budget today, become your FutureSelf

A gamified iOS budgeting app for underserved communities with AI-powered financial coaching, goal-driven visuals, and accessibility-first design.

---

## Quick Reference

| Item | Value |
|------|-------|
| **Stack** | Swift/SwiftUI (iOS) + Azure (Backend) + Plaid (Banking) |
| **Target** | iOS 17+ |
| **Pattern** | MVVM + Combine + Protocol-Driven Services |
| **Deadline** | January 9, 2025 |
| **Primary Users** | Black, Brown, and marginalized communities dealing with irregular income |

---

## Design Philosophy

### Who We're Building For
- People with **irregular income** (gig work, hourly shifts, multiple side hustles)
- Those who are **underbanked** or have had negative experiences with financial institutions
- Families with **generational financial stress** and family support obligations
- Users who need **judgment-free** financial guidance

### Core UX Principles
1. **Progress over perfection** - Celebrate small wins, not just end goals
2. **No shame, only agency** - Frame setbacks as data, not failures
3. **Visualize the future** - Goal images that respond to behavior
4. **Simple start** - Begin with 3-4 envelopes, grow complexity over time
5. **Accessible by default** - Voice mode, high contrast, VoiceOver support

---

## Architecture

### System Overview
```
┌─────────────────────────────────────────────────────────────────────────┐
│                              iOS App (Swift)                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │   Views     │  │ ViewModels  │  │  Services   │  │   Models    │   │
│  │  (SwiftUI)  │◄─┤   (MVVM)    │◄─┤  (Protocol) │◄─┤   (Data)    │   │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘   │
│         │                                  │                            │
│         ▼                                  ▼                            │
│  ┌─────────────┐                  ┌─────────────────┐                  │
│  │  Plaid SDK  │                  │  Azure API      │                  │
│  │  (LinkKit)  │                  │  Client         │                  │
│  └─────────────┘                  └─────────────────┘                  │
└─────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           Azure Cloud                                    │
│                                                                          │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐  │
│  │ Azure Functions  │    │    Cosmos DB     │    │   Azure OpenAI   │  │
│  │ (Serverless API) │◄──►│   (NoSQL Data)   │◄──►│   (GPT-4 + DALL-E)│  │
│  └──────────────────┘    └──────────────────┘    └──────────────────┘  │
│           │                                               │             │
│           ▼                                               ▼             │
│  ┌──────────────────┐                          ┌──────────────────┐    │
│  │   Plaid API      │                          │  Speech Services │    │
│  │   (Banking)      │                          │  (Voice Mode)    │    │
│  └──────────────────┘                          └──────────────────┘    │
│                                                         │              │
│                                                         ▼              │
│                                                ┌──────────────────┐    │
│                                                │  Blob Storage    │    │
│                                                │  (Goal Images)   │    │
│                                                └──────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

### iOS Project Structure
```
FutureSelf/
├── App/
│   ├── FutureSelfApp.swift
│   ├── ContentView.swift
│   └── AppContainer.swift              # Dependency injection
├── Models/
│   ├── User.swift
│   ├── Envelope.swift
│   ├── Transaction.swift
│   ├── Goal.swift
│   ├── Streak.swift
│   ├── Achievement.swift
│   ├── BudgetStatus.swift
│   └── Account.swift                   # Plaid accounts
├── Services/
│   ├── Protocols/
│   │   ├── TransactionServiceProtocol.swift
│   │   ├── EnvelopeServiceProtocol.swift
│   │   ├── GoalServiceProtocol.swift
│   │   ├── GoalImageServiceProtocol.swift
│   │   └── PlaidServiceProtocol.swift
│   ├── Mock/
│   │   ├── MockTransactionService.swift
│   │   └── MockGoalImageService.swift
│   └── Live/
│       ├── AzureAPIClient.swift
│       ├── AzureTransactionService.swift
│       ├── AzureGoalImageService.swift
│       ├── PlaidService.swift
│       ├── AIService.swift
│       └── SpeechService.swift
├── Repositories/
│   ├── LocalRepository.swift           # SwiftData for offline
│   └── SyncRepository.swift            # Handles offline + sync
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── EnvelopesViewModel.swift
│   ├── TransactionsViewModel.swift
│   ├── GoalsViewModel.swift
│   ├── FutureSelfViewModel.swift
│   ├── OnboardingViewModel.swift
│   └── AIChatViewModel.swift
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── StabilityBarView.swift      # Essentials progress
│   │   ├── CrisisStreakView.swift      # No-crisis week tracker
│   │   ├── DaysSafeMeterView.swift     # Emergency fund ring
│   │   └── ForecastBarView.swift       # 2-week money forecast
│   ├── Envelopes/
│   │   ├── EnvelopeListView.swift
│   │   ├── EnvelopeDetailView.swift
│   │   └── BillBossView.swift          # Bill thermometers
│   ├── Transactions/
│   │   ├── TransactionListView.swift
│   │   ├── AddTransactionView.swift
│   │   └── SwipeCategoryView.swift     # Swipe to categorize
│   ├── Goals/
│   │   ├── GoalsListView.swift
│   │   ├── FutureSelfView.swift        # Dynamic goal images
│   │   ├── DebtBossBattleView.swift    # Debt timeline
│   │   └── StoryEpisodeView.swift      # Future self stories
│   ├── AI/
│   │   ├── AIChatView.swift
│   │   ├── VoiceInputButton.swift
│   │   └── ChatBubble.swift
│   ├── Community/
│   │   └── GoalCirclesView.swift       # Anonymous group goals
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   └── OnboardingStepViews/
│   └── Components/
│       ├── ProgressArc.swift
│       ├── StatusBadge.swift
│       ├── ThermometerBar.swift
│       ├── TriageModeOverlay.swift     # Crisis mode UI
│       └── EmptyStateView.swift
├── Utilities/
│   ├── Extensions/
│   ├── Theme.swift
│   └── Constants.swift
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

---

## Data Models

### User
```swift
struct User: Identifiable, Codable {
    let id: String
    var email: String
    var displayName: String
    var incomeType: IncomeType
    var primaryPayCycle: PayCycle
    var monthlyIncome: Decimal?
    var onboardingComplete: Bool
    var settings: UserSettings
    var createdAt: Date

    enum IncomeType: String, Codable, CaseIterable {
        case steady      // Regular paycheck
        case irregular   // Gig work, tips, variable hours
        case mixed       // Some stable + some variable
    }

    enum PayCycle: String, Codable, CaseIterable {
        case weekly
        case biweekly
        case twiceMonthly
        case monthly
        case irregular
    }
}

struct UserSettings: Codable {
    var voiceModeEnabled: Bool
    var highContrastMode: Bool
    var notificationsEnabled: Bool
    var triageModeActive: Bool      // Simplified UI when struggling
    var currency: String            // "USD"
}
```

### Envelope (Budget Category)
```swift
struct Envelope: Identifiable, Codable {
    let id: String
    let userId: String
    var name: String
    var budgetAmount: Decimal
    var spentAmount: Decimal
    var cycle: BudgetCycle
    var limitType: LimitType
    var rolloverEnabled: Bool
    var rolloverAmount: Decimal
    var iconName: String
    var colorHex: String
    var sortOrder: Int
    var isEssential: Bool           // For Stability Bar tracking

    enum BudgetCycle: String, Codable, CaseIterable {
        case weekly, biweekly, monthly, custom
    }

    enum LimitType: String, Codable {
        case soft   // Warning only
        case hard   // Strong alert
    }

    var remaining: Decimal {
        budgetAmount + rolloverAmount - spentAmount
    }

    var percentUsed: Double {
        guard budgetAmount > 0 else { return 0 }
        return Double(truncating: (spentAmount / budgetAmount) as NSNumber)
    }

    var status: BudgetStatus {
        let pct = percentUsed
        if pct >= 1.0 { return .danger }
        if pct >= 0.8 { return .warning }
        return .good
    }
}
```

### Transaction
```swift
struct Transaction: Identifiable, Codable {
    let id: String
    let userId: String
    let accountId: String?          // From Plaid
    var envelopeId: String?
    var amount: Decimal             // positive = expense, negative = income
    var description: String
    var merchantName: String?
    var category: TransactionCategory
    var date: Date
    var source: TransactionSource
    var categoryConfidence: Double? // AI auto-categorization confidence
    var isPending: Bool
    var notes: String?

    enum TransactionSource: String, Codable {
        case manual
        case plaid
        case recurring
    }
}

enum TransactionCategory: String, Codable, CaseIterable {
    case housing, utilities, transportation, food, healthcare
    case entertainment, shopping, personal, education, travel
    case familySupport    // "Helping family" - important for target users
    case sideHustle       // Income from gig work
    case income, transfer, other

    var icon: String {
        switch self {
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .transportation: return "car.fill"
        case .food: return "fork.knife"
        case .healthcare: return "heart.fill"
        case .entertainment: return "tv.fill"
        case .shopping: return "bag.fill"
        case .personal: return "person.fill"
        case .education: return "book.fill"
        case .travel: return "airplane"
        case .familySupport: return "person.2.fill"
        case .sideHustle: return "briefcase.fill"
        case .income: return "dollarsign.circle.fill"
        case .transfer: return "arrow.left.arrow.right"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
```

### Goal
```swift
struct Goal: Identifiable, Codable {
    let id: String
    let userId: String
    var name: String
    var description: String
    var type: GoalType
    var targetAmount: Decimal?
    var currentAmount: Decimal
    var targetDate: Date?
    var isActive: Bool
    var imageURL: URL?              // Dynamic FutureSelf image
    var createdAt: Date

    enum GoalType: String, Codable, CaseIterable {
        case emergencyFund = "Build emergency cushion"
        case debtFree = "Get out of debt"
        case moveOut = "Move to my own place"
        case travel = "Take a trip"
        case education = "Invest in education"
        case familySupport = "Support my family"
        case retirement = "Start retirement savings"
        case custom = "Custom goal"

        var displayName: String { rawValue }
    }

    var progress: Double {
        guard let target = targetAmount, target > 0 else { return 0 }
        return min(1.0, Double(truncating: (currentAmount / target) as NSNumber))
    }
}
```

### Budget Status
```swift
enum BudgetStatus: String, Codable {
    case good
    case warning
    case danger

    var displayName: String {
        switch self {
        case .good: return "On Track"
        case .warning: return "Watch It"
        case .danger: return "Needs Attention"
        }
    }

    var color: Color {
        switch self {
        case .good: return .green
        case .warning: return .orange
        case .danger: return .red
        }
    }

    /// For FutureSelf images: affects image clarity/style
    var imageModifier: String {
        switch self {
        case .good: return "bright, clear, complete, inspiring"
        case .warning: return "slightly faded, minor imperfections, cloudy"
        case .danger: return "damaged, stormy, broken, incomplete"
        }
    }
}
```

### Streak & Achievement
```swift
struct Streak: Identifiable, Codable {
    let id: String
    let userId: String
    var type: StreakType
    var currentCount: Int
    var longestCount: Int
    var lastUpdated: Date

    enum StreakType: String, Codable {
        case noCrisisWeek = "No Crisis Week"      // No overdraft/payday loan
        case budgetWeek = "Under Budget"
        case dailyCheckIn = "Daily Check-in"
        case essentialsFunded = "Essentials Funded"
    }
}

struct Achievement: Identifiable, Codable {
    let id: String
    let userId: String
    var name: String
    var description: String
    var iconName: String
    var earnedAt: Date?
    var requirement: String

    var isEarned: Bool { earnedAt != nil }
}
```

### Account (from Plaid)
```swift
struct Account: Identifiable, Codable {
    let id: String
    let userId: String
    let plaidAccountId: String
    let plaidItemId: String
    var name: String
    var officialName: String?
    var type: AccountType
    var currentBalance: Decimal
    var availableBalance: Decimal?
    var lastSynced: Date

    enum AccountType: String, Codable {
        case checking, savings, credit, loan, investment, other
    }
}
```

### Conversation (AI Chat)
```swift
struct Conversation: Identifiable, Codable {
    let id: String
    let userId: String
    var messages: [ChatMessage]
    var createdAt: Date
    var updatedAt: Date
    var expiresAt: Date             // Messages expire after 30 days for privacy
}

struct ChatMessage: Identifiable, Codable {
    let id: String
    var role: MessageRole
    var content: String
    var timestamp: Date
    var isVoice: Bool

    enum MessageRole: String, Codable {
        case user, assistant, system
    }
}
```

---

## Dashboard & Analytics

### Dashboard Layout
```
┌─────────────────────────────────────┐
│  Monthly Summary Card               │
│  ┌─────────────────────────────┐   │
│  │ Spent: $2,450 / $3,000      │   │
│  │ ████████████░░░░ 82%        │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  FutureSelf Score: 78              │
│  ⭐⭐⭐⭐☆                          │
├─────────────────────────────────────┤
│  Goal Progress                      │
│  ┌─────────┐ ┌─────────┐          │
│  │ Emergency│ │ Debt    │          │
│  │ 45%     │ │ 67%     │          │
│  └─────────┘ └─────────┘          │
├─────────────────────────────────────┤
│  Spending by Category (Pie Chart)  │
│         🍕 Food 35%                 │
│       🏠 Housing 40%               │
│       🚗 Transport 15%             │
│       🎮 Other 10%                 │
├─────────────────────────────────────┤
│  Recent Transactions               │
│  • Whole Foods      -$67.43        │
│  • Netflix          -$15.99        │
│  • Direct Deposit   +$2,500.00     │
└─────────────────────────────────────┘
```

**DashboardView.swift**
```swift
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    MonthlySummaryCard(
                        spent: viewModel.monthlySpent,
                        budget: viewModel.monthlyBudget
                    )

                    FutureSelfScoreCard(score: viewModel.futureselfScore)

                    GoalProgressSection(goals: viewModel.goals)

                    SpendingCategoryChart(
                        categories: viewModel.spendingByCategory
                    )

                    RecentTransactionsSection(
                        transactions: viewModel.recentTransactions
                    )
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.refresh()
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}
```

**SpendingCategoryChart.swift** (using Swift Charts)
```swift
import Charts

struct SpendingCategoryChart: View {
    let categories: [CategorySpending]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Spending by Category")
                .font(.headline)

            Chart(categories) { category in
                SectorMark(
                    angle: .value("Amount", category.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("Category", category.name))
                .cornerRadius(4)
            }
            .frame(height: 200)

            // Legend
            LazyVGrid(columns: [.init(), .init()], spacing: 8) {
                ForEach(categories) { category in
                    HStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 10, height: 10)
                        Text(category.name)
                            .font(.caption)
                        Spacer()
                        Text(category.percentage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct CategorySpending: Identifiable {
    let id = UUID()
    let name: String
    let amount: Decimal
    let color: Color

    var percentage: String {
        // Calculate based on total
        "0%"
    }
}
```

**FutureSelf Score Calculation**
```swift
struct FutureSelfScore {
    /// Score from 0-100 based on financial health
    static func calculate(
        monthlySpent: Decimal,
        monthlyBudget: Decimal,
        goalProgress: [Goal],
        savingsRate: Double
    ) -> Int {
        var score = 0

        // Budget adherence (40 points max)
        let budgetRatio = Double(truncating: (monthlySpent / monthlyBudget) as NSNumber)
        if budgetRatio <= 1.0 {
            score += Int(40 * (1 - budgetRatio))
        }

        // Goal progress (30 points max)
        let avgProgress = goalProgress.map(\.progress).reduce(0, +) / Double(max(1, goalProgress.count))
        score += Int(30 * avgProgress)

        // Savings rate (30 points max)
        score += Int(30 * min(1, savingsRate / 0.20)) // 20% savings = max points

        return min(100, max(0, score))
    }
}
```

---

## Gamification Widgets

### 1. Stability Bar (Essentials Progress)

Shows progress toward funding essential expenses (rent, utilities, food).

```swift
struct StabilityBarView: View {
    let housingProgress: Double     // 0-1
    let utilitiesProgress: Double
    let foodTransportProgress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Month's Essentials")
                .font(.headline)

            // Segmented progress bar
            GeometryReader { geo in
                HStack(spacing: 2) {
                    // Housing segment (40% of bar)
                    SegmentView(
                        progress: housingProgress,
                        color: .blue,
                        width: geo.size.width * 0.4
                    )

                    // Utilities segment (30% of bar)
                    SegmentView(
                        progress: utilitiesProgress,
                        color: .teal,
                        width: geo.size.width * 0.3
                    )

                    // Food & Transport segment (30% of bar)
                    SegmentView(
                        progress: foodTransportProgress,
                        color: .orange,
                        width: geo.size.width * 0.3
                    )
                }
            }
            .frame(height: 24)

            // Milestone icons
            HStack {
                if housingProgress >= 0.5 {
                    MilestoneIcon(icon: "house.fill", text: "Roof secured")
                }
                if utilitiesProgress >= 1.0 {
                    MilestoneIcon(icon: "lightbulb.fill", text: "Lights on")
                }
            }

            Text("You've funded \(Int(overallProgress * 100))% of essentials")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    var overallProgress: Double {
        (housingProgress * 0.4 + utilitiesProgress * 0.3 + foodTransportProgress * 0.3)
    }
}
```

### 2. No Crisis Week Streak

Tracks weeks without overdrafts, payday loans, or shutoffs.

```swift
struct CrisisStreakView: View {
    let weeks: [Bool]   // true = clean week, false = crisis week
    let streakCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No Crisis Week")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(weeks.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(weeks[index] ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 36, height: 36)
                }
            }

            Text("Streak: \(streakCount) clean weeks")
                .font(.caption)
                .foregroundColor(.secondary)

            if streakCount >= 4 {
                Text("New avatar unlocked!")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
```

### 3. Days Safe Meter (Emergency Fund)

Circular ring showing how many days of expenses are covered.

```swift
struct DaysSafeMeterView: View {
    let daysCovered: Int
    let goalDays: Int = 30

    var body: some View {
        VStack {
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)

                // Progress ring
                Circle()
                    .trim(from: 0, to: CGFloat(daysCovered) / CGFloat(goalDays))
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: daysCovered)

                // Center text
                VStack {
                    Text("\(daysCovered)")
                        .font(.system(size: 44, weight: .bold))
                    Text("days safe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 150, height: 150)

            Text("Goal: \(goalDays) days")
                .font(.caption)
            Text("+1 day every time you add $15")
                .font(.caption2)
                .foregroundColor(.secondary)

            // Milestone tokens
            HStack(spacing: 16) {
                if daysCovered >= 3 {
                    MilestoneToken(icon: "cart.fill", text: "Food buffer")
                }
                if daysCovered >= 7 {
                    MilestoneToken(icon: "calendar", text: "1 week safe")
                }
                if daysCovered >= 14 {
                    MilestoneToken(icon: "shield.fill", text: "2-week shield")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    var ringColor: Color {
        if daysCovered < 4 { return .red }
        if daysCovered < 14 { return .orange }
        return .green
    }
}
```

### 4. Bill Boss Thermometers

Vertical meters for tracking progress toward monthly bills.

```swift
struct BillBossView: View {
    let bills: [BillProgress]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bill Boss Challenges")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 16) {
                ForEach(bills) { bill in
                    ThermometerView(bill: bill)
                }
            }

            if bills.allSatisfy({ $0.progress >= 1.0 }) {
                Text("No Crisis Month!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ThermometerView: View {
    let bill: BillProgress

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 120)

                RoundedRectangle(cornerRadius: 8)
                    .fill(bill.progress >= 1.0 ? Color.green : Color.accentColor)
                    .frame(width: 40, height: 120 * min(1.0, bill.progress))

                // 50% goal flag
                if bill.progress >= 0.5 {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.white)
                        .offset(y: -60)
                }
            }

            Text(bill.name)
                .font(.caption)

            Text("\(Int(bill.progress * 100))%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct BillProgress: Identifiable {
    let id = UUID()
    let name: String
    let progress: Double    // 0-1
}
```

### 5. Two-Week Money Forecast

Shows how many days you're covered if income stopped.

```swift
struct ForecastBarView: View {
    @State private var hoursThisWeek: Double = 30
    @State private var spendingMode: SpendingMode = .normal
    let daysCovered: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("2-Week Money Forecast")
                .font(.headline)
            Text("If income stopped today, how long could you last?")
                .font(.caption)
                .foregroundColor(.secondary)

            // 14-day bar
            HStack(spacing: 2) {
                ForEach(0..<14, id: \.self) { day in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(day < adjustedDays ? Color.green : Color.orange.opacity(0.3))
                        .frame(height: 24)
                }
            }

            Text("Covered for \(adjustedDays) of 14 days")
                .font(.caption)

            // Hours slider (for gig workers)
            HStack {
                Text("Hours this week:")
                Slider(value: $hoursThisWeek, in: 0...60, step: 5)
                Text("\(Int(hoursThisWeek))")
            }
            .font(.caption)

            // Spending mode pills
            HStack {
                ForEach(SpendingMode.allCases, id: \.self) { mode in
                    Button(mode.rawValue) {
                        spendingMode = mode
                    }
                    .buttonStyle(.bordered)
                    .tint(spendingMode == mode ? .accentColor : .gray)
                }
            }

            // Risk indicator
            RiskPill(level: riskLevel)

            Text("Try setting aside $10 to push one more day to green.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    var adjustedDays: Int {
        var days = daysCovered
        days += Int(hoursThisWeek / 10)
        switch spendingMode {
        case .tight: days += 2
        case .normal: break
        case .loose: days -= 2
        }
        return max(0, min(14, days))
    }

    var riskLevel: RiskLevel {
        if adjustedDays >= 10 { return .low }
        if adjustedDays >= 5 { return .medium }
        return .high
    }

    enum SpendingMode: String, CaseIterable {
        case tight = "Tight"
        case normal = "Normal"
        case loose = "Loose"
    }

    enum RiskLevel {
        case low, medium, high
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .red
            }
        }
        var text: String {
            switch self {
            case .low: return "LOW"
            case .medium: return "MEDIUM"
            case .high: return "HIGH"
            }
        }
    }
}
```

### 6. Debt Boss Battle Timeline

Horizontal path showing debt payoff as defeating "bosses."

```swift
struct DebtBossBattleView: View {
    let debts: [DebtBoss]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Debt Boss Battle")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(debts) { debt in
                        DebtBossCard(debt: debt)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct DebtBossCard: View {
    let debt: DebtBoss

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(debt.isDefeated ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: debt.icon)
                    .font(.title)
                    .foregroundColor(debt.isDefeated ? .green : .red)

                if debt.isDefeated {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .offset(x: 20, y: -20)
                }
            }

            Text(debt.name)
                .font(.caption)
                .fontWeight(.semibold)

            ProgressView(value: debt.paidPercent)
                .frame(width: 80)

            Text("\(Int(debt.paidPercent * 100))% defeated")
                .font(.caption2)
                .foregroundColor(.secondary)

            if debt.interestSaved > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "shield.fill")
                        .font(.caption2)
                    Text("Blocked $\(debt.interestSaved, specifier: "%.0f") interest")
                        .font(.caption2)
                }
                .foregroundColor(.green)
            }
        }
    }
}

struct DebtBoss: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let totalAmount: Decimal
    let paidAmount: Decimal
    let interestSaved: Double

    var paidPercent: Double {
        guard totalAmount > 0 else { return 0 }
        return Double(truncating: (paidAmount / totalAmount) as NSNumber)
    }
    var isDefeated: Bool { paidPercent >= 1.0 }
}
```

### 7. FutureSelf Goal Images

Dynamic images that change based on budget status.

```swift
struct FutureSelfView: View {
    @StateObject private var viewModel: FutureSelfViewModel
    @State private var isRefreshing = false

    var body: some View {
        VStack(spacing: 16) {
            if let goal = viewModel.activeGoal {
                Text(goal.name)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(goal.type.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Dynamic image with status-based effects
                ZStack {
                    if let imageURL = goal.imageURL {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .blur(radius: imageBlur)
                                    .saturation(imageSaturation)
                            case .failure:
                                placeholderImage
                            case .empty:
                                ProgressView()
                            @unknown default:
                                placeholderImage
                            }
                        }
                    } else {
                        placeholderImage
                    }

                    VStack {
                        Spacer()
                        StatusBadge(status: viewModel.currentStatus)
                            .padding()
                    }
                }
                .frame(height: 300)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(viewModel.currentStatus.color, lineWidth: 3)
                )

                Text(statusMessage)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: refreshImage) {
                    Label("Refresh Vision", systemImage: "arrow.clockwise")
                }
                .disabled(isRefreshing)

                if let target = goal.targetAmount {
                    ProgressView(value: goal.progress)
                        .padding(.horizontal)
                    Text("$\(goal.currentAmount, specifier: "%.0f") of $\(target, specifier: "%.0f")")
                        .font(.caption)
                }
            } else {
                EmptyStateView(
                    icon: "star.fill",
                    title: "Set Your First Goal",
                    message: "What does your FutureSelf look like?"
                )
            }
        }
        .padding()
        .navigationTitle("Your FutureSelf")
    }

    var imageBlur: CGFloat {
        switch viewModel.currentStatus {
        case .good: return 0
        case .warning: return 2
        case .danger: return 5
        }
    }

    var imageSaturation: Double {
        switch viewModel.currentStatus {
        case .good: return 1.0
        case .warning: return 0.7
        case .danger: return 0.3
        }
    }

    var statusMessage: String {
        switch viewModel.currentStatus {
        case .good: return "Your future is looking bright! Keep it up."
        case .warning: return "A few clouds on the horizon. Small adjustments can clear the way."
        case .danger: return "Your vision is getting foggy. Let's focus on the essentials first."
        }
    }

    var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray))
    }

    func refreshImage() {
        isRefreshing = true
        Task {
            await viewModel.refreshGoalImage()
            isRefreshing = false
        }
    }
}
```

### 8. Story-Based "Future Self" Episodes

Comic-style decision cards showing future scenarios.

```swift
struct StoryEpisodeView: View {
    let episode: StoryEpisode
    @State private var currentCardIndex = 0
    @State private var choices: [Int] = []

    var body: some View {
        VStack(spacing: 16) {
            Text(episode.title)
                .font(.title2)
                .fontWeight(.semibold)

            // Episode illustration
            Image(episode.illustrationName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
                .cornerRadius(12)

            // Decision card
            if currentCardIndex < episode.cards.count {
                let card = episode.cards[currentCardIndex]

                Text(card.scenario)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()

                HStack(spacing: 16) {
                    ForEach(card.choices.indices, id: \.self) { index in
                        Button(action: { makeChoice(index) }) {
                            VStack {
                                Image(systemName: card.choices[index].icon)
                                    .font(.title)
                                Text(card.choices[index].label)
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                }
            } else {
                // Results
                VStack(spacing: 12) {
                    Text("Your FutureSelf Result")
                        .font(.headline)

                    HStack(spacing: 24) {
                        ResultMeter(label: "Savings", before: 20, after: calculatedSavings)
                        ResultMeter(label: "Debt", before: 80, after: calculatedDebt)
                        ResultMeter(label: "Days Safe", before: 5, after: calculatedDaysSafe)
                    }

                    Text("This episode is based on your real numbers today.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }

    func makeChoice(_ index: Int) {
        choices.append(index)
        currentCardIndex += 1
    }

    var calculatedSavings: Double { 40 }  // Based on choices
    var calculatedDebt: Double { 60 }
    var calculatedDaysSafe: Double { 12 }
}

struct StoryEpisode {
    let title: String
    let illustrationName: String
    let cards: [StoryCard]
}

struct StoryCard {
    let scenario: String
    let choices: [StoryChoice]
}

struct StoryChoice {
    let icon: String
    let label: String
    let impact: [String: Double]  // e.g., ["savings": 10, "debt": -5]
}
```

### 9. Community Goal Circles

Anonymous group progress (percentages only, no shame).

```swift
struct GoalCirclesView: View {
    let circleName: String
    let members: [CircleMember]
    let totalProgress: Double
    let totalGoal: Decimal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goal Circle: \(circleName)")
                .font(.headline)

            // Anonymous member avatars
            HStack(spacing: -8) {
                ForEach(members.prefix(6)) { member in
                    Circle()
                        .fill(member.isActive ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text(member.initials)
                                .font(.caption2)
                                .foregroundColor(.white)
                        )
                }
                if members.count > 6 {
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text("+\(members.count - 6)")
                                .font(.caption2)
                                .foregroundColor(.white)
                        )
                }
            }

            HStack {
                ProgressView(value: totalProgress)
                    .progressViewStyle(.linear)
                Text("\(Int(totalProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text("Circle is \(Int(totalProgress * 100))% toward $\(totalGoal, specifier: "%.0f") total buffer")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct CircleMember: Identifiable {
    let id = UUID()
    let initials: String
    let isActive: Bool
}
```

### 10. Triage Mode Overlay

Simplified UI when user is struggling.

```swift
struct TriageModeOverlay: View {
    @Binding var isActive: Bool
    let currentMission: TriageMission

    var body: some View {
        if isActive {
            VStack(spacing: 0) {
                // Banner
                HStack {
                    Image(systemName: "heart.fill")
                    Text("Tough Week Mode: Let's just stabilize")
                        .font(.subheadline)
                    Spacer()
                    Button(action: { isActive = false }) {
                        Image(systemName: "xmark")
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.9))
                .foregroundColor(.white)

                Spacer()

                // Single mission card
                VStack(spacing: 16) {
                    Text("Today's Win")
                        .font(.headline)

                    Text(currentMission.title)
                        .font(.title3)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(currentMission.steps.indices, id: \.self) { index in
                            HStack {
                                Image(systemName: currentMission.completedSteps.contains(index)
                                      ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(currentMission.completedSteps.contains(index)
                                                     ? .green : .gray)
                                Text(currentMission.steps[index])
                            }
                        }
                    }

                    if currentMission.isComplete {
                        Label("Resilience Badge Earned!", systemImage: "shield.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 8)
                .padding()

                Spacer()
            }
        }
    }
}

struct TriageMission {
    let title: String
    let steps: [String]
    var completedSteps: Set<Int>
    var isComplete: Bool { completedSteps.count == steps.count }
}
```

---

## Onboarding Flow

### Screen Flow
```
Welcome → Income Type → Pay Cycle → Goals → Essentials Setup → Bank → Summary
```

### Supportive Copy Examples

| Instead of | Use |
|------------|-----|
| "You overspent by $50" | "You used $50 more than planned. Let's see what we can adjust." |
| "You failed to meet your goal" | "This month was tough. Your goal is still waiting for you." |
| "Budget remaining: $0" | "You've used your full budget. You're covered for essentials." |

**For gig workers:** "Income came in! Let's direct it where it'll help most."

**For family support:** "Supporting family is part of your values. Let's make sure you're covered first."

---

## AI Finance Expert

### System Prompt
```
You are FutureSelf AI, a warm and knowledgeable personal finance coach.

IMPORTANT CONTEXT ABOUT OUR USERS:
- Many have irregular income (gig work, hourly shifts, multiple jobs)
- Many support family members financially
- Many have had negative experiences with banks or financial "advice"
- Many face systemic barriers to wealth-building
- Your job is to EMPOWER, never to shame or lecture

User Financial Context:
- Income Type: {income_type}
- Monthly Income (estimated): {monthly_income}
- Current Month Spending: {current_spending}
- Top Categories: {top_categories}
- Active Goals: {goals_summary}
- Days Safe (emergency buffer): {days_safe}
- Current Streak: {streak_info}

Guidelines:
- Be encouraging but honest about spending patterns
- Acknowledge that sometimes life doesn't go as planned
- Reference their actual data when giving advice
- Keep responses concise (2-3 paragraphs max)
- Use simple language, avoid financial jargon
- Celebrate progress, even small wins
- When things are tough, focus on "next small step"
- Never suggest they "just budget better" or "work harder"
- Understand that "helping family" is a valid expense
```

### Conversation Expiry
- Chat messages expire after 30 days for privacy
- Users can export conversations before expiry
- Financial data summaries retained for context

---

## Cash Flow Analyzer

### Recurring Payments Calendar
```swift
struct RecurringCalendarView: View {
    let payments: [RecurringPayment]
    @State private var selectedDate: Date = Date()

    var body: some View {
        VStack {
            CalendarView(
                selectedDate: $selectedDate,
                markedDates: paymentDates
            )

            if let todayPayments = paymentsOn(selectedDate), !todayPayments.isEmpty {
                ForEach(todayPayments) { payment in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(payment.name).font(.headline)
                            Text(payment.frequency.rawValue.capitalized)
                                .font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("$\(payment.amount, specifier: "%.2f")").font(.headline)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Next 7 Days").font(.headline)
                Text("$\(upcomingTotal, specifier: "%.2f") in bills due")
                    .font(.subheadline).foregroundColor(.secondary)
            }
            .padding()
        }
    }

    var paymentDates: Set<Date> {
        Set(payments.map { Calendar.current.startOfDay(for: $0.nextDueDate) })
    }

    func paymentsOn(_ date: Date) -> [RecurringPayment]? {
        let day = Calendar.current.startOfDay(for: date)
        return payments.filter { Calendar.current.startOfDay(for: $0.nextDueDate) == day }
    }

    var upcomingTotal: Decimal {
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        return payments.filter { $0.nextDueDate <= nextWeek }.reduce(0) { $0 + $1.amount }
    }
}

struct RecurringPayment: Identifiable {
    let id: String
    let name: String
    let amount: Decimal
    let frequency: RecurrenceFrequency
    let nextDueDate: Date

    enum RecurrenceFrequency: String, Codable {
        case weekly, biweekly, monthly, quarterly, annual
    }
}
```

---

## Plaid Integration

### Link Token Flow
```
iOS App                    Azure Functions              Plaid API
   │                            │                          │
   │ 1. Request link token      │                          │
   ├───────────────────────────►│                          │
   │                            │ 2. Create link token     │
   │                            ├─────────────────────────►│
   │                            │ 3. Return link token     │
   │                            │◄─────────────────────────┤
   │ 4. Return link token       │                          │
   │◄───────────────────────────┤                          │
   │                            │                          │
   │ 5. Open Plaid Link UI      │                          │
   │ (User connects bank)       │                          │
   │                            │                          │
   │ 6. Receive public token    │                          │
   ├───────────────────────────►│ 7. Exchange for access   │
   │                            ├─────────────────────────►│
   │                            │ 8. Store access token    │
   │                            │◄─────────────────────────┤
   │ 9. Success                 │                          │
   │◄───────────────────────────┤                          │
```

### Swipe to Categorize
For uncategorized transactions from Plaid:
```swift
struct SwipeCategoryView: View {
    let transaction: Transaction
    @State private var offset: CGFloat = 0
    let onCategorize: (TransactionCategory) -> Void

    var body: some View {
        // Swipe left/right to assign categories
        // Shows AI-suggested category with confidence score
        // User can confirm or override
    }
}
```

---

## API Endpoints

### Authentication
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/refresh
```

### Users
```
GET    /api/users/me
PUT    /api/users/me
DELETE /api/users/me
```

### Envelopes
```
GET    /api/envelopes
POST   /api/envelopes
GET    /api/envelopes/{id}
PUT    /api/envelopes/{id}
DELETE /api/envelopes/{id}
```

### Transactions
```
GET    /api/transactions
POST   /api/transactions
DELETE /api/transactions/{id}
POST   /api/transactions/{id}/categorize
```

### Goals
```
GET    /api/goals
POST   /api/goals
PUT    /api/goals/{id}
DELETE /api/goals/{id}
POST   /api/goals/{id}/activate
POST   /api/goals/{id}/generate-image
```

### Plaid
```
POST   /api/plaid/link-token
POST   /api/plaid/exchange-token
GET    /api/accounts
POST   /api/accounts/sync
```

### AI
```
POST   /api/ai/chat
POST   /api/ai/voice
GET    /api/ai/conversations
DELETE /api/ai/conversations/{id}
```

### Analytics
```
GET    /api/analytics/cashflow
GET    /api/analytics/categories
GET    /api/analytics/trends
GET    /api/recurring
```

### Gamification
```
GET    /api/streaks
GET    /api/achievements
POST   /api/streaks/check-in
```

---

## Development Schedule

### Day 1 (Dec 28): Foundation
| Task | Owner | Details |
|------|-------|---------|
| Azure setup | Backend | Resource group, Functions, Cosmos DB, OpenAI |
| Xcode project | iOS | SwiftUI app, folder structure, AppContainer |
| Auth flow | Both | Basic JWT auth with device ID |
| Models | iOS | All data models from this doc |

### Day 2 (Dec 29): Banking + Core Data
| Task | Owner | Details |
|------|-------|---------|
| Plaid setup | Backend | Developer account, link token flow |
| PlaidLink SDK | iOS | Integrate, handle callbacks |
| Envelope CRUD | Both | API endpoints + iOS views |
| Transaction sync | Backend | Fetch + store from Plaid |

### Day 3 (Dec 30): Onboarding + Dashboard
| Task | Owner | Details |
|------|-------|---------|
| Onboarding flow | iOS | 7-screen wizard |
| Dashboard layout | iOS | Summary cards, quick actions |
| Stability Bar | iOS | Essentials progress widget |
| Days Safe meter | iOS | Emergency fund ring |

### Day 4 (Dec 31): Gamification Widgets
| Task | Owner | Details |
|------|-------|---------|
| Crisis Streak | iOS | No-crisis week tracker |
| Bill Boss | iOS | Thermometer meters |
| Forecast Bar | iOS | 2-week money forecast |
| Streaks API | Backend | Track and update streaks |

### Day 5 (Jan 1): AI + Goals
| Task | Owner | Details |
|------|-------|---------|
| Azure OpenAI | Backend | Chat endpoint, prompt engineering |
| Chat UI | iOS | Message bubbles, context injection |
| FutureSelf view | iOS | Dynamic goal images |
| Goal image generation | Backend | DALL-E integration |

### Day 6 (Jan 2): Voice + Polish
| Task | Owner | Details |
|------|-------|---------|
| Speech Services | Backend | STT + TTS endpoints |
| Voice UI | iOS | Recording button, playback |
| Triage Mode | iOS | Simplified crisis UI |
| Accessibility | iOS | VoiceOver, high contrast |
| UI polish | iOS | Animations, error states |

### Days 7-13 (Jan 3-9): Testing & Demo Prep
- End-to-end testing all flows
- Bug fixes
- Demo script rehearsal
- Presentation materials

---

## Environment Setup

### Required Accounts
- **Azure**: Free tier works for MVP
- **Plaid**: Developer account (sandbox)
- **Apple Developer**: For TestFlight

### Azure Resources
```bash
az group create --name futureself-rg --location eastus

az functionapp create --name futureself-api \
  --resource-group futureself-rg \
  --consumption-plan-location eastus \
  --runtime node --runtime-version 18

az cosmosdb create --name futureself-db \
  --resource-group futureself-rg

az cognitiveservices account create --name futureself-ai \
  --resource-group futureself-rg --kind OpenAI --sku S0

az cognitiveservices account create --name futureself-speech \
  --resource-group futureself-rg --kind SpeechServices --sku S0

az storage account create --name futureselfimages \
  --resource-group futureself-rg --sku Standard_LRS
```

### Environment Variables
```
AZURE_COSMOS_ENDPOINT=https://futureself-db.documents.azure.com:443/
AZURE_COSMOS_KEY=your-key
AZURE_OPENAI_ENDPOINT=https://futureself-ai.openai.azure.com/
AZURE_OPENAI_KEY=your-key
AZURE_OPENAI_DEPLOYMENT=gpt-4
AZURE_SPEECH_KEY=your-key
AZURE_SPEECH_REGION=eastus
PLAID_CLIENT_ID=your-client-id
PLAID_SECRET=your-sandbox-secret
PLAID_ENV=sandbox
JWT_SECRET=your-secret-key
```

---

## Demo Script (5 minutes)

### 1. Introduction (30 sec)
"FutureSelf is a budgeting app built for real life—irregular income, family obligations, and the goal of actually building a future."

### 2. Onboarding (1 min)
- Show income type selection ("We get gig work")
- Quick envelope setup (just 3-4 categories)
- Connect sandbox bank
- "Meet your FutureSelf" animation

### 3. Dashboard Tour (1 min)
- Stability Bar: "See your essentials are 70% covered"
- Days Safe meter: "9 days of buffer built"
- Crisis streak: "3 clean weeks"

### 4. AI Coach (1 min)
- Ask: "How am I doing this month?"
- Show personalized response with their data
- Toggle voice mode, speak a question

### 5. FutureSelf Goal (30 sec)
- Show goal with bright, clear image (good status)
- Explain image changes based on budget behavior

### 6. Close (30 sec)
"FutureSelf: Budget today, become your future self."

---

## Security Notes

- Never expose Plaid access tokens to client
- JWT tokens expire after 1 hour
- Chat messages expire after 30 days
- All API calls over HTTPS
- Rate limiting on all endpoints
- User can delete all data at any time

---

## Future Roadmap (Post-MVP)

### Phase 2: Enhanced Analytics
- Investment advice from AI coaches
- Spending predictions using ML
- Bill negotiation recommendations

### Phase 3: Community Features
- Full Goal Circles implementation
- Anonymous community challenges
- Peer mentoring (opt-in)

### Phase 4: Platform Expansion
- Android app
- Web dashboard
- Family accounts

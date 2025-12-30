# BudgetAI - Smart Budget Tracking App

An iOS budgeting app powered by Azure OpenAI for intelligent transaction categorization and financial insights.

## Features

- Natural language transaction input
- AI-powered transaction categorization
- Budget tracking and insights
- Income tracking
- Financial goal setting
- Conversational FutureSelf assistant

## Setup Instructions

### Prerequisites

- Xcode 14.0 or later
- iOS 16.0 or later
- Azure OpenAI API access

### Configuration

1. Copy the example configuration file:
   ```bash
   cp BudgetAI/BudgetAI/Configuration.plist.example BudgetAI/BudgetAI/Configuration.plist
   ```

2. Edit `BudgetAI/BudgetAI/Configuration.plist` and replace the placeholder values:
   - `APIKey`: Your Azure OpenAI API key
   - `Endpoint`: Your Azure OpenAI endpoint URL (e.g., `https://your-resource.openai.azure.com/`)
   - `DeploymentName`: Your deployment name (default: `gpt-4.1-mini`)

3. **IMPORTANT**: Never commit `Configuration.plist` to version control. It's already in `.gitignore`.

### Running the App

1. Open `BudgetAI/BudgetAI.xcodeproj` in Xcode
2. Select a simulator or device
3. Build and run (⌘R)

## Security Notes

- **Never commit API keys or secrets to GitHub**
- The `Configuration.plist` file is excluded via `.gitignore`
- Use the `Configuration.plist.example` template for reference
- Keep your API keys secure and rotate them regularly

## Project Structure

```
BudgetAI/
├── BudgetAI/
│   ├── Core/
│   │   ├── Data/          # Data models and repositories
│   │   └── Services/      # AI services and utilities
│   ├── Presentation/      # Views and ViewModels
│   └── Configuration.plist  # API keys (NOT committed)
└── Configuration.plist.example  # Template file
```

## License

Private project - All rights reserved

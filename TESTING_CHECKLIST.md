# FutureSelf AI Visualization - Testing Checklist

## MVP Testing Checklist (Jan 5-9, 2026)

### Pre-Testing Setup
- [ ] Clean build folder (⌘+Shift+K)
- [ ] Ensure device/simulator is running iOS 15+
- [ ] Grant camera and photo library permissions when prompted
- [ ] Start with fresh install (delete app and reinstall)

---

## 📱 Phase 1: Onboarding Flow - Basic Navigation

### 1.1 Welcome Screen
- [ ] Welcome screen displays with app introduction
- [ ] "Get Started" button is visible and tappable
- [ ] Button advances to Profile Photo step
- [ ] **Haptic feedback** occurs when tapping button

### 1.2 Profile Photo Capture
- [ ] Two options visible: "Take Photo" and "Choose from Library"
- [ ] **Camera option:**
  - [ ] Tapping "Take Photo" requests camera permission (first time)
  - [ ] Camera opens successfully
  - [ ] Can capture photo
  - [ ] Captured photo displays in circular preview
  - [ ] Photo is reasonably sized (check file size mentally)
- [ ] **Library option:**
  - [ ] Tapping "Choose from Library" requests photo library permission
  - [ ] Photo picker opens
  - [ ] Can select photo
  - [ ] Selected photo displays in circular preview
- [ ] **Large photo test:** Select a photo >5MB
  - [ ] Image loads without crash
  - [ ] Image is compressed to reasonable size
- [ ] "Continue" button is disabled until photo is selected
- [ ] "Continue" button enables after photo selection
- [ ] Can proceed to next step
- [ ] **Haptic feedback** on "Continue"

### 1.3 Goal Type Selection
- [ ] Grid of goal types displays (Travel, Move Out, Emergency Fund, etc.)
- [ ] Goal cards are tappable
- [ ] Selected goal highlights with blue border and background
- [ ] Can select different goal types
- [ ] "Back" button returns to Profile Photo step
- [ ] "Continue" is disabled until goal is selected
- [ ] "Continue" enables after selection
- [ ] Advances to Goal Details
- [ ] **Haptic feedback** on navigation

### 1.4 Goal Details
- [ ] For custom goals: "Goal Name" field is visible and required
- [ ] "Description" field is optional
- [ ] "Target Amount" field is required
- [ ] Can enter dollar amount with decimal
- [ ] "Set Target Date" toggle works
- [ ] When toggled on, date picker appears
- [ ] Can select future date (cannot select past dates)
- [ ] "Back" button works
- [ ] "Continue" is disabled until required fields are filled
- [ ] "Continue" enables when valid
- [ ] Advances to Goal Why questions
- [ ] **Haptic feedback** on navigation

### 1.5 Goal "Why" Questions
- [ ] **Travel goal:** Shows travel-specific questions
  - [ ] "Where do you want to go?"
  - [ ] "What will you do when you get there?"
  - [ ] "How will achieving this trip change your life?"
- [ ] **Move Out goal:** Shows move-out questions
  - [ ] "What kind of place do you want to live in?"
  - [ ] "Where do you imagine living?"
  - [ ] "What will having your own place mean to you?"
- [ ] **Other goals:** Shows generic questions
- [ ] Progress indicator shows current question (3 dots/bars)
- [ ] Text field allows multiline input (3-6 lines)
- [ ] "Back" button works on first question
- [ ] "Next" button disabled until answer is entered
- [ ] Can navigate through all 3 questions
- [ ] Last question shows "Continue" instead of "Next"
- [ ] Location/specific details are extracted (check console/data)
- [ ] Advances to Visualization Generation
- [ ] **Haptic feedback** on navigation

### 1.6 Visualization Generation
- [ ] Loading spinner appears
- [ ] "Creating your FutureSelf vision..." message displays
- [ ] "This may take a moment" subtext visible
- [ ] Waits for ~2 seconds
- [ ] **Success state:**
  - [ ] Green checkmark icon appears
  - [ ] "Your FutureSelf is ready!" message
  - [ ] "Get Started" button visible
  - [ ] Tapping button completes onboarding
  - [ ] App transitions to main ContentView
- [ ] **Error state (simulate by killing app during generation):**
  - [ ] Orange warning icon appears
  - [ ] "Oops! Something went wrong" message
  - [ ] Error description is user-friendly
  - [ ] "Try Again" button works

---

## 🎨 Phase 2: FutureSelf Visualization Display

### 2.1 Navigate to FutureSelf View
- [ ] After onboarding, can navigate to created goal
- [ ] FutureSelf view loads successfully
- [ ] Goal name and description display correctly

### 2.2 Image Display
- [ ] **AI-generated image (or placeholder) displays:**
  - [ ] Image is visible (gradient + icon for MVP)
  - [ ] Image is 300x200 size
  - [ ] Image has rounded corners (16px radius)
  - [ ] No distortion or pixelation
- [ ] **Status badge overlay:**
  - [ ] Badge appears in bottom-right corner
  - [ ] Shows "On Track" with green checkmark (default)

### 2.3 Budget Status Variations
- [ ] **Good status (default):**
  - [ ] Image is clear and bright
  - [ ] No border around image
  - [ ] Status message: "Your future is looking bright..."
- [ ] **Warning status (modify code to set budgetStatus = .warning):**
  - [ ] Image appears slightly blurred
  - [ ] Image is desaturated (less colorful)
  - [ ] Orange border appears
  - [ ] Status badge shows "Watch It" with warning icon
  - [ ] Status message: "A few clouds on the horizon..."
  - [ ] Transition is smooth (0.5s animation)
- [ ] **Danger status (set budgetStatus = .danger):**
  - [ ] Image is heavily blurred
  - [ ] Image is heavily desaturated (grayscale-ish)
  - [ ] Image is dimmer
  - [ ] Red border appears
  - [ ] Status badge shows "Over Budget" with X icon
  - [ ] Status message: "Your vision is getting foggy..."
  - [ ] Transition is smooth

### 2.4 Progress Section
- [ ] Progress bar displays (should be at 0% initially)
- [ ] "Saved" amount shows $0
- [ ] "Goal" amount shows target entered in onboarding
- [ ] "0% Complete" text displays
- [ ] "Remaining" amount matches target

### 2.5 Actions
- [ ] "Add to Goal" button is visible (placeholder action)
- [ ] **"Refresh Vision" button:**
  - [ ] Button is visible and tappable
  - [ ] Tapping shows loading spinner inside button
  - [ ] Button is disabled during loading
  - [ ] Waits ~1 second (mock delay)
  - [ ] Image refreshes (placeholder regenerates)
  - [ ] **Success haptic feedback** occurs
  - [ ] Button re-enables after completion

---

## 🎭 Phase 3: Advanced Features

### 3.1 Accessibility (VoiceOver Testing)
- [ ] Enable VoiceOver on device
- [ ] Navigate to FutureSelf image
- [ ] VoiceOver reads: "Your FutureSelf vision for [Goal Name]"
- [ ] VoiceOver reads status hint:
  - [ ] Good: "You're staying on budget. Your vision is clear and bright."
  - [ ] Warning: "You're approaching your budget limit..."
  - [ ] Danger: "You've exceeded your budget..."
- [ ] All buttons are accessible via VoiceOver

### 3.2 Smooth Transitions
- [ ] **Onboarding page transitions:**
  - [ ] Pages slide from right when advancing
  - [ ] Pages slide from left when going back
  - [ ] Transitions feel smooth and natural (spring animation)
  - [ ] No jarring jumps or glitches
  - [ ] Visualization step has scale transition

### 3.3 Error Handling
- [ ] **Airplane mode test:**
  - [ ] Enable airplane mode
  - [ ] Tap "Refresh Vision"
  - [ ] Error alert appears with user-friendly message
  - [ ] Alert has "OK" button
  - [ ] **Error haptic feedback** occurs
  - [ ] Can dismiss alert
  - [ ] Button re-enables

---

## 🔄 Phase 4: Edge Cases & Stress Testing

### 4.1 Onboarding Interruption & Resume
- [ ] Start onboarding flow
- [ ] Get to Goal Details step
- [ ] Kill app (swipe up from multitasking)
- [ ] Reopen app
- [ ] **Should resume at Goal Details step** (UserDefaults persistence)
- [ ] Can complete onboarding from where you left off

### 4.2 Photo Handling
- [ ] **Very large photo (>10MB):**
  - [ ] Select or capture large photo
  - [ ] App doesn't freeze or crash
  - [ ] Photo is compressed to <500KB
  - [ ] Photo maintains acceptable quality
- [ ] **Portrait vs landscape:**
  - [ ] Try portrait photo → displays correctly
  - [ ] Try landscape photo → displays correctly
  - [ ] Try square photo → displays correctly
- [ ] **Cancel actions:**
  - [ ] Open camera and cancel → returns to onboarding
  - [ ] Open photo library and cancel → returns to onboarding

### 4.3 Multiple Goals
- [ ] Complete onboarding and create first goal
- [ ] Create second goal manually (if supported in app)
- [ ] Each goal should have its own FutureSelf vision
- [ ] Images don't mix between goals

### 4.4 Onboarding Already Complete
- [ ] Complete onboarding fully
- [ ] Close and reopen app
- [ ] **Should skip onboarding** and go to main app
- [ ] Onboarding doesn't show again
- [ ] Reset test: Delete app data and verify onboarding shows

### 4.5 Memory & Performance
- [ ] Complete full onboarding flow without memory warnings
- [ ] Refresh vision 10 times rapidly
  - [ ] No crashes
  - [ ] No memory leaks (check Xcode memory gauge)
- [ ] Navigate back and forth between views
  - [ ] No lag or stuttering
  - [ ] Animations remain smooth

---

## 🐛 Known Issues to Document

### Issue Tracking Template
For any failed tests, document:
1. **What happened:** Describe the bug
2. **Expected behavior:** What should happen
3. **Steps to reproduce:** Exact steps to trigger
4. **Severity:** Critical / High / Medium / Low
5. **Screenshot/Video:** If applicable

---

## ✅ Test Results Summary

**Date Tested:** _____________
**Device/Simulator:** _____________
**iOS Version:** _____________
**Build Number:** _____________

### Phase 1: Onboarding Flow
- [ ] ✅ All tests passed
- [ ] ⚠️ Some issues found (document below)
- [ ] ❌ Critical failures

### Phase 2: Visualization Display
- [ ] ✅ All tests passed
- [ ] ⚠️ Some issues found (document below)
- [ ] ❌ Critical failures

### Phase 3: Advanced Features
- [ ] ✅ All tests passed
- [ ] ⚠️ Some issues found (document below)
- [ ] ❌ Critical failures

### Phase 4: Edge Cases
- [ ] ✅ All tests passed
- [ ] ⚠️ Some issues found (document below)
- [ ] ❌ Critical failures

---

## 📝 Issues Found

### Issue #1
**Title:** _____________
**Description:** _____________
**Severity:** _____________
**Steps to Reproduce:**
1.
2.
3.

### Issue #2
**Title:** _____________
**Description:** _____________
**Severity:** _____________
**Steps to Reproduce:**
1.
2.
3.

---

## 🎯 MVP Success Criteria

All of these must pass for MVP approval:

- [ ] User can complete onboarding without crashes
- [ ] User can capture or select a profile photo
- [ ] User can answer goal "why" questions
- [ ] Visualization generates successfully (even if placeholder)
- [ ] FutureSelf image displays in goal view
- [ ] "Refresh Vision" button works
- [ ] Budget status changes affect image appearance (blur/saturation)
- [ ] No critical bugs or crashes
- [ ] Acceptable performance on target devices
- [ ] Basic accessibility support works

---

## 🚀 Post-MVP Testing (Azure Integration)

When Azure DALL-E 3 is integrated:

- [ ] Real AI-generated images appear (not placeholders)
- [ ] Images are personalized based on user photo
- [ ] Images reflect goal details (location, specific item, etc.)
- [ ] Status variations are AI-generated (not just filters)
- [ ] API errors are handled gracefully
- [ ] Offline behavior works (cached images display)
- [ ] Cost tracking is implemented
- [ ] Weekly regeneration works (background task)

---

## 📞 Escalation

**Critical bugs found?** Document and report immediately.

**Ready to ship?** All MVP Success Criteria must be checked!

---

**Happy Testing! 🧪**

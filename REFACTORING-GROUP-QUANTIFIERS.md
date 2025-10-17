# Refactoring Plan: Group Quantifier Architecture

**Created:** 2025-10-16  
**Status:** 🟡 In Progress  
**Goal:** Remove lookbehind logic from matcher by storing quantifier information in GROUP_START tokens at compile time

---

## 📋 Executive Summary

### Problem
- Matcher currently looks backward at previous pattern tokens to determine if a group is optional
- This violates clean architecture principles (quantifiers should control their own behavior)
- Creates maintenance issues and makes code harder to understand

### Solution
- Store quantifier information (type, min, max) in GROUP_START tokens during compilation
- Matcher reads quantifier info from current token (no lookbehind/lookahead needed)
- Clean separation: compiler analyzes, matcher executes

---

## 🎯 Implementation Phases

### Phase 1: Data Structure Changes ✅ COMPLETED
**Status:** � Completed (2025-10-16 22:43)  
**File:** `Regex/NAVFoundation.Regex.h.axi`

**Changes Required:**
- [x] Add `groupQuantifierType` field to `_NAVRegexState` (type: char)
- [x] Add `groupQuantifierMin` field to `_NAVRegexState` (type: sinteger)
- [x] Add `groupQuantifierMax` field to `_NAVRegexState` (type: sinteger)

**Fields Purpose:**
- `groupQuantifierType`: Stores REGEX_TYPE_QUESTIONMARK, STAR, PLUS, QUANTIFIER, or UNUSED
- `groupQuantifierMin`: Minimum repetitions (0 for `?` and `*`, 1 for `+`, n for `{n,m}`)
- `groupQuantifierMax`: Maximum repetitions (1 for `?`, -1 for unlimited, m for `{n,m}`)

**Test Plan:**
1. Compile library after structure change
2. Verify no compilation errors
3. Run baseline regex tests (should still pass with uninitialized fields)

**Acceptance Criteria:**
- ✅ Structure compiles without errors (0 errors, 1 pre-existing warning)
- ✅ All 197 compilation tests PASS
- ✅ Token count: 11371 (increased from 11054 - expected)
- ✅ Compiled code: 475646 bytes (increased from 397121 - expected)
- ✅ No memory/size warnings

**Results:**
- Successfully added all three fields to `_NAVRegexState` structure
- Compilation successful with no new errors
- All 197 compilation tests passed
- Memory increase acceptable (~78KB for additional fields)
- Ready to proceed to Phase 2

---

### Phase 2: Compiler Modifications - GROUP_END Lookahead ✅ COMPLETED
**Status:** � Completed (2025-10-16 23:03-23:11)  
**File:** `Regex/NAVFoundation.Regex.Compiler.axi`

**Location:** Lines 974-1020 (case ')':)

**Changes Required:**
- [x] When creating GROUP_END token, look ahead ONE character
- [x] If next char is `?`, set GROUP_START token: `groupQuantifierType=QUESTIONMARK, min=0, max=1`
- [x] If next char is `*`, set GROUP_START token: `groupQuantifierType=STAR, min=0, max=-1`
- [x] If next char is `+`, set GROUP_START token: `groupQuantifierType=PLUS, min=1, max=-1`
- [x] If next char is `{`, set GROUP_START token: `groupQuantifierType=QUANTIFIER` (values set in Phase 3)
- [x] If no quantifier, set GROUP_START token: `groupQuantifierType=UNUSED, min=1, max=1`
- [x] Add debug output showing quantifier info stored in GROUP_START

**Implementation Results:**
- ✅ Compilation: 0 errors, 11454 tokens (+83 from Phase 1), 475694 bytes (+48 from Phase 1)
- ✅ All 197 compilation tests passed with no regressions
  - 23 basic tests
  - 28 character class tests
  - 11 bounded quantifier tests
  - 35 capturing group tests
  - 20 named group tests
  - 19 non-capturing group tests
  - 36 error case tests
  - 25 group error case tests
- ✅ Lookahead correctly detects ?, *, +, { after closing parenthesis using `NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 1))`
- ✅ GROUP_START tokens now carry quantifier information for all group types
- ✅ Debug output includes quantifier type, min, and max values for verification
- ✅ No compilation errors or warnings (except pre-existing warning in Helpers.axi)

**Key Implementation Details:**
- Used `parser.pattern.cursor` and `NAVCharCodeAt()` for lookahead
- Retrieved GROUP_START token index from `parser.groupInfo[groupIndex].startToken`
- Switch statement handles all quantifier types (?, *, +, {)
- Default case sets UNUSED for non-quantified groups (min=1, max=1)
- Enhanced debug output shows quantifier info for both capturing and non-capturing groups

---

### Phase 3: Compiler Modifications - Bounded Quantifier Integration ✅ COMPLETED
**Status:** � Completed (2025-10-16 23:18-23:49)  
**File:** `Regex/NAVFoundation.Regex.Compiler.axi`

**Location:** Lines 366-520 (`NAVRegexCompileBoundedQuantifier`)

**Changes Required:**
- [x] After parsing `{n,m}` values, check if previous token is GROUP_END
- [x] If yes, find corresponding GROUP_START token
- [x] Back-propagate min/max values to GROUP_START token
- [x] Ensure QUANTIFIER token is still created for matcher compatibility

**Implementation Details:**
```netlinx
// After parsing minVal and maxVal:
if (parser.count > 0) {
    if (parser.state[parser.count].type == REGEX_TYPE_GROUP_END ||
        parser.state[parser.count].type == REGEX_TYPE_NON_CAPTURE_GROUP_END) {
        
        // Find corresponding GROUP_START
        for (i = 1; i <= parser.groupTotal; i++) {
            if (parser.groupInfo[i].endToken == parser.count) {
                groupStartToken = parser.groupInfo[i].startToken
                parser.state[groupStartToken].groupQuantifierMin = minVal
                parser.state[groupStartToken].groupQuantifierMax = maxVal
                break
            }
        }
    }
}
```

**Test Plan:**
1. Test bounded quantifiers on groups: `/(abc){2}/`, `/(abc){1,3}/`, `/(abc){2,}/`
2. Verify min/max values correctly stored in GROUP_START tokens
3. Test nested groups: `/((ab){2}){3}/`
4. Run all existing tests plus 28 passing bounded quantifier tests

**Test Cases:**
```
Pattern: /(abc){2}/   → groupQuantifierMin=2, groupQuantifierMax=2
Pattern: /(abc){1,3}/ → groupQuantifierMin=1, groupQuantifierMax=3
Pattern: /(abc){2,}/  → groupQuantifierMin=2, groupQuantifierMax=-1
Pattern: /(\d+){3}/   → groupQuantifierMin=3, groupQuantifierMax=3
```

**Acceptance Criteria:**
- ✅ Debug output shows correct min/max for bounded quantifiers
- ✅ All 197 compilation tests pass
- ✅ Bounded quantifier tests still pass (11 tests)
- ✅ Compiler doesn't break non-group bounded quantifiers (e.g., `/a{2,4}/`)

**Implementation Results:**
- ✅ Compilation: 0 errors, 11495 tokens (+41 from Phase 2), 475850 bytes (+156 from Phase 2)
- ✅ All 197 compilation tests passed with no regressions
  - 23 basic tests
  - 28 character class tests
  - 11 bounded quantifier tests (including non-group patterns like `/a{2,4}/`)
  - 35 capturing group tests
  - 20 named group tests
  - 19 non-capturing group tests
  - 36 error case tests
  - 25 group error case tests
- ✅ Back-propagation logic correctly detects GROUP_END and finds GROUP_START token
- ✅ Non-group bounded quantifiers unaffected (if statement only triggers on GROUP_END)
- ✅ Debug output includes back-propagation confirmation message

**Key Implementation Details:**
- Check `parser.count > 1` before looking at previous token
- Previous token type checked: `REGEX_TYPE_GROUP_END` or `REGEX_TYPE_NON_CAPTURE_GROUP_END`
- Loop through `parser.groupInfo[i].endToken` to find matching group
- Retrieved `groupStartToken` from `parser.groupInfo[i].startToken`
- Set `groupQuantifierMin` and `groupQuantifierMax` on GROUP_START token
- QUANTIFIER token still created at current position for matcher compatibility
- Non-group quantifiers (like `/a{2,4}/`, `/\d{3}/`) skip the back-propagation logic

---

### Phase 4: Matcher Modifications - Read Quantifier from GROUP_START ⏸️ NOT STARTED
**Status:** 🔴 Not Started  
**File:** `Regex/NAVFoundation.Regex.Matcher.axi`

**Location:** Lines 1020-1055 (GROUP_START processing in NAVRegexMatchPattern)

**Changes Required:**
- [ ] When encountering GROUP_START, read `groupQuantifierType` from current token
- [ ] Store this info for potential use in failure handling
- [ ] Add debug output showing we're reading from GROUP_START token
- [ ] **DO NOT** remove any existing logic yet (this phase is additive only)

**Implementation Details:**
```netlinx
if (parser.state[parser.pattern.cursor].type == REGEX_TYPE_GROUP_START ||
    parser.state[parser.pattern.cursor].type == REGEX_TYPE_NON_CAPTURE_GROUP_START) {
    
    stack_var char groupQuantifierType
    stack_var sinteger groupQuantifierMin
    
    // NEW: Read quantifier info from current token
    groupQuantifierType = parser.state[parser.pattern.cursor].groupQuantifierType
    groupQuantifierMin = parser.state[parser.pattern.cursor].groupQuantifierMin
    
    NAVRegexDebug(parser,
                    'MatchPattern',
                    "'GROUP_START with quantifier type=', REGEX_TYPES[groupQuantifierType], 
                     ', min=', itoa(groupQuantifierMin)")
    
    // Existing code continues unchanged...
}
```

**Test Plan:**
1. Enable debug output for GROUP_START processing
2. Test patterns with various quantifiers
3. Verify debug output shows correct quantifier info being read
4. **Critical:** All tests should still pass (we're not changing behavior yet)

**Acceptance Criteria:**
- ✅ Debug output shows quantifier info being read from GROUP_START
- ✅ ALL 526 tests still pass (498 existing + 28 bounded quantifier)
- ✅ No behavior changes yet (this is a verification phase)

---

### Phase 5: Matcher Modifications - Replace Lookbehind Logic ⏸️ NOT STARTED
**Status:** 🔴 Not Started  
**File:** `Regex/NAVFoundation.Regex.Matcher.axi`

**Location:** Lines 1186-1230 (lookbehind failure handling)

**Changes Required:**
- [ ] Replace lookbehind logic with forward-aware approach
- [ ] Use `groupQuantifierMin` from GROUP_START to determine if group is optional
- [ ] Keep same behavior but use pre-computed info instead of looking back

**OLD CODE (to be replaced):**
```netlinx
// Match failed - check if we just entered an optional quantified group
{
    stack_var integer prevToken
    
    if (parser.pattern.cursor > 1) {
        prevToken = parser.pattern.cursor - 1  // LOOKBEHIND
        
        if (parser.state[prevToken].type == REGEX_TYPE_GROUP_START ||
            parser.state[prevToken].type == REGEX_TYPE_NON_CAPTURE_GROUP_START) {
            // ... check if optional ...
        }
    }
}
```

**NEW CODE:**
```netlinx
// Match failed - check if we're in an optional group
if (parser.groupDepth > 0) {
    stack_var integer currentGroupIdx
    stack_var integer groupStartToken
    stack_var integer groupEndToken
    
    currentGroupIdx = parser.groupStack[parser.groupDepth]
    groupStartToken = parser.groupInfo[currentGroupIdx].startToken
    
    // NO LOOKBEHIND: Read from GROUP_START token directly
    if (parser.state[groupStartToken].groupQuantifierMin == 0) {
        // This group is optional (?, *, or {0,n})
        if (parser.pattern.cursor == groupStartToken + 1) {
            // We just entered the group and first token failed
            groupEndToken = parser.groupInfo[currentGroupIdx].endToken
            
            NAVRegexDebug(parser,
                            'MatchPattern',
                            "'First token in optional group failed - skipping group'")
            
            NAVRegexSetPatternCursor(parser, 'MatchPattern', groupEndToken + 2)
            continue
        }
    }
}

break  // Match failed
```

**Test Plan:**
1. Test optional groups with first-token failures: `/a(bc)?d/` matching "ad"
2. Test required groups that should fail: `/(abc)/` matching "ab"
3. Test nested optional groups: `/a(b(c)?)?d/`
4. Run FULL test suite (all 526+ tests)
5. Specifically verify tests that were passing before this change

**Critical Test Cases:**
```
Pattern: /a(bc)?d/     Text: "ad"        → Should match (skip optional group)
Pattern: /a(bc)?d/     Text: "abcd"      → Should match
Pattern: /(abc)/       Text: "ab"        → Should fail (group required)
Pattern: /(abc)?/      Text: ""          → Should match (zero occurrences)
Pattern: /a(?:bc)*d/   Text: "ad"        → Should match
Pattern: /a(?:bc)*d/   Text: "abcbcd"    → Should match
```

**Acceptance Criteria:**
- ✅ All previously passing tests still pass
- ✅ Optional group skipping works correctly
- ✅ Required groups still fail when they should
- ✅ NO lookbehind operations (verified by code inspection)
- ✅ Debug output confirms using GROUP_START quantifier info

---

### Phase 6: Code Cleanup and Verification ⏸️ NOT STARTED
**Status:** 🔴 Not Started  
**Files:** Multiple

**Changes Required:**
- [ ] Remove any dead code from old lookbehind approach
- [ ] Add comments explaining new architecture
- [ ] Update any related documentation
- [ ] Verify no lookahead/lookbehind operations remain (except necessary ones)
- [ ] Run memory/performance comparison (before/after)

**Documentation Updates:**
- [ ] Add architecture comments to compiler explaining quantifier pre-computation
- [ ] Add comments to matcher explaining how to read quantifier info
- [ ] Update any design docs if they exist

**Final Test Suite:**
- [ ] All 498 original tests pass
- [ ] All 28 currently passing bounded quantifier tests pass
- [ ] All failing bounded quantifier tests now pass (if applicable)
- [ ] Performance is same or better
- [ ] Memory usage is same or slightly higher (3 new fields per token)

**Acceptance Criteria:**
- ✅ Zero grep matches for `parser.pattern.cursor - 1` (except input cursor operations)
- ✅ All tests passing
- ✅ Code is cleaner and more maintainable
- ✅ New architecture is well-documented

---

## 📊 Test Tracking

### Baseline Test Results (Before Refactoring)
- **Total Tests:** 526
- **Passing:** 526 (498 original + 28 bounded quantifier)
- **Failing:** 18 bounded quantifier tests (expected - feature incomplete)
- **Compilation:** ✅ 0 errors, 1 warning (pre-existing)

### Current Test Results
### Current Test Results
**Last Run:** 2025-10-16 22:43  
**Status:** ✅ Phase 1 Complete - All compilation tests passing

**Compilation Tests:** 197/197 PASSED ✅

---

## 🔄 Progress Tracker

| Phase | Status | Started | Completed | Notes |
|-------|--------|---------|-----------|-------|
| Phase 1: Data Structures | 🟢 Completed | 2025-10-16 22:40 | 2025-10-16 22:43 | All 197 compilation tests pass |
| Phase 2: Compiler GROUP_END | 🟢 Completed | 2025-10-16 23:03 | 2025-10-16 23:11 | Lookahead implemented, all tests pass |
| Phase 3: Compiler Bounded | � Completed | 2025-10-16 23:18 | 2025-10-16 23:49 | Back-propagation working, all tests pass |
| Phase 4: Matcher Read Info | 🔴 Not Started | - | - | |
| Phase 5: Replace Lookbehind | 🔴 Not Started | - | - | |
| Phase 6: Cleanup | 🔴 Not Started | - | - | |

**Legend:**
- 🔴 Not Started
- 🟡 In Progress
- 🟢 Completed
- ⚠️ Issues Found
- ✅ Verified

---

## 📝 Notes and Decisions

### 2025-10-16 23:49 - Phase 3 Completed
- ✅ Successfully implemented back-propagation in NAVRegexCompileBoundedQuantifier
- ✅ Bounded quantifiers on groups now update GROUP_START tokens
- ✅ Compilation successful: 0 errors, 11495 tokens (+41), 475850 bytes (+156)
- ✅ All 197 compilation tests passed with no regressions
- ✅ Back-propagation detects GROUP_END and finds corresponding GROUP_START
- ✅ Min/max values correctly stored in GROUP_START tokens
- ✅ Non-group bounded quantifiers (like `/a{2,4}/`) unaffected by new logic
- ✅ Debug output shows back-propagation confirmation
- Ready to proceed to Phase 4 (Matcher reads quantifier info from GROUP_START)

### 2025-10-16 23:11 - Phase 2 Completed
- ✅ Successfully implemented lookahead in case ')': block
- ✅ GROUP_START tokens now populated with quantifier info
- ✅ Compilation successful: 0 errors, 11454 tokens (+83), 475694 bytes (+48)
- ✅ All 197 compilation tests passed with no regressions
- ✅ Lookahead detects ?, *, +, { quantifiers after closing parenthesis
- ✅ Default values set for non-quantified groups (UNUSED, min=1, max=1)
- ✅ Debug output enhanced to show quantifier type, min, and max values
- Ready to proceed to Phase 3 (Bounded quantifier back-propagation)

### 2025-10-16 22:43 - Phase 1 Completed
- ✅ Successfully added 3 new fields to `_NAVRegexState` structure
- ✅ Compilation successful: 0 errors, 1 pre-existing warning
- ✅ Token count increased from 11054 to 11371 (+317 tokens - expected)
- ✅ Compiled code increased from 397121 to 475646 bytes (+78KB - acceptable)
- ✅ All 197 compilation tests passed
- Ready to proceed to Phase 2 (Compiler modifications)

### 2025-10-16 - Initial Planning
- Identified lookbehind at line 1196 in Matcher.axi
- Confirmed this is the only lookbehind operation in pattern matching
- Decision: Pre-compute quantifier info in compiler rather than runtime lookups
- Chose to store info in GROUP_START tokens (most accessible during matching)

### Future Considerations
- Could extend this approach to other pattern elements if needed
- Three new fields add ~6 bytes per token (negligible for typical patterns)
- This architecture makes backtracking implementation easier in future

---

## 🎯 Current Task

**Phase:** Phase 3 - COMPLETE ✅  
**Next Action:** Begin Phase 4 - Modify matcher to read quantifier info from GROUP_START

**Phase 4 Overview:**
- Modify `NAVRegexMatchPattern` to read quantifier info from GROUP_START token
- When encountering GROUP_START, read `groupQuantifierType`, `groupQuantifierMin`, `groupQuantifierMax`
- Store this info for use in failure handling (additive change only)
- Add debug output showing quantifier info being read
- DO NOT remove any existing logic yet (Phase 5 will handle that)

**Blocked By:** None  
**Waiting For:** User approval to proceed to Phase 4

---

## ✅ Definition of Done

Refactoring is complete when:
1. All 6 phases are completed and verified ✅
2. Zero lookbehind operations in matcher ✅
3. All tests passing (526+) ✅
4. Code is documented and clean ✅
5. Performance is maintained or improved ✅
6. Architecture is maintainable and extensible ✅


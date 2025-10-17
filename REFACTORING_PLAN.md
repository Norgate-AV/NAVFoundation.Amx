# NAVFoundation.Regex.Matcher.axi Refactoring Plan

**Date Started:** October 17, 2025  
**Branch:** `feature/regex`  
**Objective:** Improve code readability, maintainability, and prepare for fixing bounded quantifier group tests

---

## 📊 Current Status

### Baseline Metrics
- **File:** `Regex/NAVFoundation.Regex.Matcher.axi`
- **Total Lines:** 1,372
- **Token Count:** 11,148
- **Compiled Size:** 488,155 bytes
- **Compilation Warnings:** 1 (pre-existing in Helpers.axi:78)

### Test Results (Baseline)
- **Total Tests:** 507
- **Passing:** 489
- **Failing:** 18 (all in NAVRegexMatchBoundedQuantifierGroups)
- **Known Issue:** Test 6 `/(\d+){3}/` matching `"12-34-56"` fails but completes

---

## 🎯 Refactoring Goals

1. **Reduce complexity** in large functions (`NAVRegexMatchPattern`, `NAVRegexMatchQuantifiedGroup`)
2. **Extract boolean expressions** into well-named helper functions
3. **Reduce nesting depth** from 4-5 levels to 2-3 levels
4. **Improve readability** for future maintenance and debugging
5. **Zero regressions** - all 489 passing tests must remain passing

---

## 📋 Implementation Phases

### ✅ Phase 0: Baseline Documentation
- [x] Create refactoring plan document
- [x] Document current metrics
- [x] Run full test suite to establish baseline
- [ ] Commit baseline documentation

---

### 🔄 Phase 1: Token Type Checking Helpers (LOW RISK)

**Objective:** Replace repeated boolean expressions with self-documenting helper functions

**Impact:** Minor token count increase (~50-100 tokens), major readability improvement

#### New Helper Functions

```netlinx
define_function char NAVRegexIsQuantifier(integer tokenType)
define_function char NAVRegexNextTokenIsQuantifier(_NAVRegexParser parser)
define_function char NAVRegexIsGroupStart(integer tokenType)
define_function char NAVRegexIsGroupEnd(integer tokenType)
define_function char NAVRegexIsZeroWidthAssertion(integer tokenType)
```

#### Files to Modify
- `Regex/NAVFoundation.Regex.Matcher.axi`

#### Usage Examples
**Before:**
```netlinx
if (parser.state[parser.pattern.cursor + 1].type == REGEX_TYPE_QUESTIONMARK ||
    parser.state[parser.pattern.cursor + 1].type == REGEX_TYPE_STAR ||
    parser.state[parser.pattern.cursor + 1].type == REGEX_TYPE_PLUS ||
    parser.state[parser.pattern.cursor + 1].type == REGEX_TYPE_QUANTIFIER)
```

**After:**
```netlinx
if (NAVRegexNextTokenIsQuantifier(parser))
```

#### Checklist
- [ ] Add helper functions at end of file (before `#END_IF`)
- [ ] Replace usages in `NAVRegexMatchPattern` (6+ locations)
- [ ] Replace usages in `NAVRegexMatchQuantifiedGroup` (2+ locations)
- [ ] Compile and verify no errors
- [ ] Run full test suite
- [ ] Document token count change
- [ ] Commit Phase 1 changes

#### Success Criteria
- ✅ Compilation successful
- ✅ All 489 passing tests still pass
- ✅ 18 failing tests show same behavior (no new failures)
- ✅ Token count increase < 200

---

### 🔄 Phase 2: State Query Helpers (LOW RISK)

**Objective:** Add semantic wrappers around common parser state queries

**Impact:** Minor token count increase (~100-150 tokens), improved code clarity

#### New Helper Functions

```netlinx
define_function integer NAVRegexGetCurrentTokenType(_NAVRegexParser parser)
define_function char NAVRegexAtEndOfPattern(_NAVRegexParser parser)
define_function char NAVRegexAtEndOfInput(_NAVRegexParser parser)
define_function char NAVRegexCanContinueMatching(_NAVRegexParser parser)
```

#### Usage Examples
**Before:**
```netlinx
if (parser.state[parser.pattern.cursor].type == REGEX_TYPE_UNUSED) {
    return true
}
```

**After:**
```netlinx
if (NAVRegexAtEndOfPattern(parser)) {
    return true
}
```

#### Checklist
- [ ] Add helper functions
- [ ] Replace usages in `NAVRegexMatchPattern` (10+ locations)
- [ ] Replace usages in `NAVRegexMatchCompiled` (3+ locations)
- [ ] Compile and verify no errors
- [ ] Run full test suite
- [ ] Document token count change
- [ ] Commit Phase 2 changes

#### Success Criteria
- ✅ Compilation successful
- ✅ All 489 passing tests still pass
- ✅ 18 failing tests show same behavior
- ✅ Token count increase < 200

---

### 🔄 Phase 3: Group Lookup Helpers (LOW RISK)

**Objective:** Consolidate repeated group lookup logic

**Impact:** Minor token count increase (~50-100 tokens), eliminates code duplication

#### New Helper Functions

```netlinx
define_function integer NAVRegexFindGroupByStartToken(_NAVRegexParser parser, integer startToken)
define_function integer NAVRegexFindGroupByEndToken(_NAVRegexParser parser, integer endToken)
define_function char NAVRegexIsGroupCapturing(_NAVRegexParser parser, integer groupIdx)
```

#### Checklist
- [ ] Add helper functions
- [ ] Replace group lookup loops in `NAVRegexMatchPattern`
- [ ] Replace group lookup loops in `NAVRegexMatchQuantifiedGroup`
- [ ] Compile and verify no errors
- [ ] Run full test suite
- [ ] Document token count change
- [ ] Commit Phase 3 changes

#### Success Criteria
- ✅ Compilation successful
- ✅ All 489 passing tests still pass
- ✅ 18 failing tests show same behavior
- ✅ Token count increase < 150

---

### 🔄 Phase 4: Extract NAVRegexMatchPattern Logic (MEDIUM RISK)

**Objective:** Break down 253-line function into manageable pieces

**Impact:** Moderate token count increase (~300-500 tokens), major readability improvement

#### New Helper Functions

```netlinx
define_function integer NAVRegexHandleGroupStart(_NAVRegexParser parser, _NAVRegexMatchResult match)
define_function integer NAVRegexHandleGroupEnd(_NAVRegexParser parser, _NAVRegexMatchResult match)
define_function char NAVRegexDispatchQuantifier(_NAVRegexParser parser, _NAVRegexMatchResult match)
define_function char NAVRegexHandleSuccessfulMatch(_NAVRegexParser parser, _NAVRegexMatchResult match)
define_function char NAVRegexTrySkipOptionalGroup(_NAVRegexParser parser)
```

#### Expected Line Count Reduction
- **Before:** `NAVRegexMatchPattern` = 253 lines
- **After:** `NAVRegexMatchPattern` = ~60 lines + 5 helpers (~40 lines each)

#### Checklist
- [ ] Extract `NAVRegexHandleGroupStart` (lines 1018-1074)
- [ ] Compile and test
- [ ] Extract `NAVRegexHandleGroupEnd` (lines 1076-1110)
- [ ] Compile and test
- [ ] Extract `NAVRegexDispatchQuantifier` (lines 1112-1150)
- [ ] Compile and test
- [ ] Extract `NAVRegexHandleSuccessfulMatch` (lines 1175-1193)
- [ ] Compile and test
- [ ] Extract `NAVRegexTrySkipOptionalGroup` (lines 1204-1219)
- [ ] Compile and test
- [ ] Refactor main `NAVRegexMatchPattern` body to use helpers
- [ ] Compile and run full test suite
- [ ] Document token count change
- [ ] Commit Phase 4 changes

#### Success Criteria
- ✅ Compilation successful
- ✅ All 489 passing tests still pass
- ✅ 18 failing tests show same behavior
- ✅ `NAVRegexMatchPattern` reduced to < 80 lines
- ✅ Nesting depth reduced from 5 to 2-3 levels

---

### 🔄 Phase 5: Extract NAVRegexMatchQuantifiedGroup Logic (MEDIUM RISK)

**Objective:** Break down 218-line function into manageable pieces

**Impact:** Moderate token count increase (~200-400 tokens), improved maintainability

#### New Helper Functions

```netlinx
define_function char NAVRegexGetQuantifierBounds(_NAVRegexParser parser, 
                                                  integer quantifierType,
                                                  integer minMatches,
                                                  integer maxMatches)
define_function integer NAVRegexMatchGroupRepetitions(_NAVRegexParser parser,
                                                       integer groupStartToken,
                                                       integer groupEndToken,
                                                       integer maxMatches,
                                                       integer firstMatchEnd)
define_function integer NAVRegexCaptureGroupText(_NAVRegexParser parser,
                                                  _NAVRegexMatchResult match,
                                                  integer groupIdx,
                                                  integer lastMatchStart,
                                                  integer lastMatchEnd)
```

#### Expected Line Count Reduction
- **Before:** `NAVRegexMatchQuantifiedGroup` = 218 lines
- **After:** `NAVRegexMatchQuantifiedGroup` = ~100 lines + 3 helpers (~40 lines each)

#### Checklist
- [ ] Extract `NAVRegexGetQuantifierBounds` (lines 816-843)
- [ ] Compile and test
- [ ] Extract `NAVRegexMatchGroupRepetitions` (lines 890-942)
- [ ] Compile and test
- [ ] Extract `NAVRegexCaptureGroupText` (lines 956-979)
- [ ] Compile and test
- [ ] Refactor main `NAVRegexMatchQuantifiedGroup` body to use helpers
- [ ] Compile and run full test suite
- [ ] Document token count change
- [ ] Commit Phase 5 changes

#### Success Criteria
- ✅ Compilation successful
- ✅ All 489 passing tests still pass
- ✅ 18 failing tests show same behavior
- ✅ `NAVRegexMatchQuantifiedGroup` reduced to < 120 lines
- ✅ Nesting depth reduced from 4 to 2-3 levels

---

## 📈 Progress Tracking

### Metrics After Each Phase

| Phase | Token Count | Compiled Size | Line Count (Matcher.axi) | Passing Tests | Failing Tests | Notes |
|-------|-------------|---------------|--------------------------|---------------|---------------|-------|
| Baseline | 11,148 | 488,155 | 1,372 | 489 | 18 | Before refactoring |
| Phase 1 | TBD | TBD | TBD | 489 | 18 | Token type helpers |
| Phase 2 | TBD | TBD | TBD | 489 | 18 | State query helpers |
| Phase 3 | TBD | TBD | TBD | 489 | 18 | Group lookup helpers |
| Phase 4 | TBD | TBD | TBD | 489 | 18 | Extract MatchPattern |
| Phase 5 | TBD | TBD | TBD | 489 | 18 | Extract MatchQuantifiedGroup |

---

## 🎯 Post-Refactoring: Fix Bounded Quantifier Groups

**Only after refactoring is complete and all tests still pass!**

### Known Failing Tests (18 total)
1. Test 6: `/(\d+){3}/` matching `"12-34-56"` - **Priority target**
2. Tests 7-23: Various bounded quantifier group patterns

### Analysis Needed
- [ ] Review refactored code structure
- [ ] Identify where backtracking logic should be added
- [ ] Plan incremental fix approach
- [ ] Test each fix individually

---

## 📝 Notes

### Why This Order?
1. **Phases 1-3** are low-risk additions that don't change control flow
2. **Phase 4** has highest complexity but biggest readability payoff
3. **Phase 5** builds on Phase 4's patterns
4. Each phase is independently valuable and testable

### Rollback Plan
If any phase introduces regressions:
1. Review the git diff for that phase
2. Check for typos or logic errors
3. If unfixable quickly, `git restore` that phase
4. Document the issue
5. Adjust plan if needed

### Token Budget
- **Starting:** 11,148 tokens (5.6% of 200,000 limit)
- **Estimated Final:** ~12,500 tokens (6.25% of limit)
- **Remaining Buffer:** ~187,500 tokens (93.75%)
- **Conclusion:** Plenty of room for improvement

---

## ✅ Completion Checklist

- [ ] All 5 phases completed
- [ ] All 489 passing tests still passing
- [ ] No new test failures introduced
- [ ] Code readability significantly improved
- [ ] Documentation updated
- [ ] Changes committed to feature branch
- [ ] Ready to tackle bounded quantifier group fixes

---

## 🚀 Next Steps After Refactoring

1. **Review refactored code** with fresh perspective
2. **Plan bounded quantifier fix** using new structure
3. **Implement fix incrementally** with testing at each step
4. **Validate all 507 tests pass**
5. **Merge to main branch**

---

**Last Updated:** October 17, 2025  
**Status:** Phase 0 - Ready to begin Phase 1

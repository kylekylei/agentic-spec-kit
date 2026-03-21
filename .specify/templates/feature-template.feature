# Feature Template
# Replace all [PLACEHOLDERS] with actual values

@[FEATURE_TAG] @P[PRIORITY]
Feature: [FEATURE_NAME]
  As a [ACTOR/PERSONA]
  I want [CAPABILITY/ACTION]
  So that [BUSINESS_VALUE/BENEFIT]

  # Background: Common preconditions for all scenarios
  # Uncomment and fill if needed
  # Background:
  #   Given [COMMON_PRECONDITION]
  #   And [ANOTHER_COMMON_PRECONDITION]

  # ============================================================================
  # HAPPY PATH SCENARIOS
  # Primary success paths that deliver core value
  # ============================================================================

  @happy-path @P1
  Scenario: [PRIMARY_SUCCESS_SCENARIO_NAME]
    Given [INITIAL_CONTEXT]
    And [ADDITIONAL_CONTEXT]
    When [ACTION_PERFORMED]
    Then [EXPECTED_OUTCOME]
    And [ADDITIONAL_VERIFICATION]

  @happy-path @P1
  Scenario: [SECONDARY_SUCCESS_SCENARIO_NAME]
    Given [INITIAL_CONTEXT]
    When [ACTION_PERFORMED]
    Then [EXPECTED_OUTCOME]

  # ============================================================================
  # ALTERNATIVE PATH SCENARIOS
  # Valid but non-primary ways to achieve the goal
  # ============================================================================

  @alternative @P2
  Scenario: [ALTERNATIVE_FLOW_NAME]
    Given [ALTERNATIVE_CONTEXT]
    When [ALTERNATIVE_ACTION]
    Then [EXPECTED_OUTCOME]

  # ============================================================================
  # NEGATIVE / ERROR SCENARIOS
  # Invalid inputs, error conditions, and failure handling
  # ============================================================================

  @negative @P2
  Scenario: [ERROR_CONDITION_NAME]
    Given [CONTEXT_THAT_WILL_CAUSE_ERROR]
    When [ACTION_THAT_TRIGGERS_ERROR]
    Then [ERROR_HANDLING_BEHAVIOR]
    And [USER_FEEDBACK_OR_RECOVERY]

  @negative @P2
  Scenario: [VALIDATION_FAILURE_NAME]
    Given [CONTEXT_WITH_INVALID_DATA]
    When [ACTION_WITH_INVALID_INPUT]
    Then [VALIDATION_ERROR_RESPONSE]

  # ============================================================================
  # BOUNDARY / EDGE CASE SCENARIOS
  # Limits, thresholds, and edge conditions
  # ============================================================================

  @boundary @P3
  Scenario: [BOUNDARY_CONDITION_NAME]
    Given [CONTEXT_AT_BOUNDARY]
    When [ACTION_AT_LIMIT]
    Then [EXPECTED_BOUNDARY_BEHAVIOR]

  # ============================================================================
  # DATA-DRIVEN SCENARIOS
  # Same behavior with multiple data sets
  # ============================================================================

  @data-driven @P2
  Scenario Outline: [PARAMETERIZED_SCENARIO_NAME]
    Given [CONTEXT_WITH_PARAMETER] "<parameter1>"
    When [ACTION_WITH_PARAMETER] "<parameter2>"
    Then [OUTCOME_WITH_PARAMETER] "<expected_result>"

    Examples:
      | parameter1 | parameter2 | expected_result |
      | [VALUE_1]  | [VALUE_2]  | [RESULT_1]      |
      | [VALUE_3]  | [VALUE_4]  | [RESULT_2]      |
      | [VALUE_5]  | [VALUE_6]  | [RESULT_3]      |

  # ============================================================================
  # PRINCIPLES BOUNDARY SCENARIOS
  # Behaviors that MUST NOT occur (Negative Prompting)
  # Reference: .specify/memory/principles.md
  # ============================================================================

  @principles @boundary @P1
  Scenario: [PRINCIPLES_VIOLATION_PREVENTION_NAME]
    # This scenario verifies the system respects Principles boundaries
    Given [CONTEXT_THAT_COULD_LEAD_TO_VIOLATION]
    When [ACTION_THAT_COULD_VIOLATE_PRINCIPLE]
    Then [SYSTEM_MUST_PREVENT_VIOLATION]
    And [APPROPRIATE_ALTERNATIVE_BEHAVIOR]

  @principles @boundary @P1
  Scenario: [ANOTHER_PRINCIPLES_BOUNDARY]
    Given [CONTEXT]
    When [POTENTIALLY_VIOLATING_ACTION]
    Then [PRINCIPLES_CONSTRAINT_ENFORCED]

# ============================================================================
# TAG REFERENCE
# ============================================================================
# Priority Tags:
#   @P1 - Critical: Must work for MVP
#   @P2 - Important: Should work for release
#   @P3 - Nice-to-have: Can be deferred
#
# Category Tags:
#   @happy-path   - Primary success scenarios
#   @alternative  - Valid alternate flows
#   @negative     - Error and failure scenarios
#   @boundary     - Edge cases and limits
#   @data-driven  - Parameterized scenarios
#   @principles - Principles boundary enforcement
#
# Custom Tags:
#   @wip          - Work in progress
#   @manual       - Requires manual testing
#   @slow         - Long-running scenario
#   @flaky        - Known intermittent issues
# ============================================================================

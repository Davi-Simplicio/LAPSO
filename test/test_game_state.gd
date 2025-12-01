extends GdUnitTestSuite

func before_test():
	GameState.unlocked_facts = {}

func test_unlock_fact_success():
	var secret_id = "who_killed_laura"
	GameState.unlock_fact(secret_id)
	assert_that(GameState.has_fact(secret_id)).is_true()

func test_check_non_existent_fact():
	assert_that(GameState.has_fact("ghost_sighting")).is_false()

func test_duplicate_unlock_does_not_crash():
	GameState.unlock_fact("clue_1")
	GameState.unlock_fact("clue_1")
	
	assert_that(GameState.has_fact("clue_1")).is_true()
	assert_int(GameState.unlocked_facts.size()).is_equal(1)
